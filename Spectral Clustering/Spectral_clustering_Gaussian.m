clear 

cd 'C:\Users\Xiang\OneDrive\Desktop\Math 199\Spectral Clustering'
%Read data in to a table to make it easy to sort rows
data = readtable('DataByCensusMaster+2yrRatio_succint.xlsx');

origMat = cell2mat(table2cell(data(1:818,[3:4,46,47,55:58, 65:68, 69, 71])));
HomePop15 = cell2mat(table2cell(data(1:818, [1,16])));
HomePop16 = cell2mat(table2cell(data(1:818, [1,26])));
HomePop17 = cell2mat(table2cell(data(1:818, [1,36])));

[n,m] = size(origMat);
%%
% normalized by percentile rank
normMatPR = (tiedrank(origMat)-1)./(n-1);

% normalized by percentile rank
normMatZ = (origMat - mean(origMat))./sqrt(var(origMat,1,1));

% Conduct PCA
% for each column, set mean to 0, normalize by unbiased estimator of standard deviation
norm_data = (origMat - mean(origMat))./sqrt(var(origMat,1,1));

% do the SVD: the matrix V is the representation of the data
% that maximizes the variance of the data for each
% dimension 1..num_factors
[U, Sigma, V] = svd(norm_data);

% proj is each tract data projected into a subset of R^num_factors with
% increasingly greater accuracy
proj = norm_data*V;

% get diagonal of matrix and compute total variance
diagonal = diag(Sigma.^2);
totalVariance = sum(diagonal);

% for each subspace, find how much variance it explains
for i=1:length(diagonal)
   variances_explained(i) = sum(diagonal(1:i))/totalVariance; 
end

numOfVectors =7;
%Projected data
proj_optimal = proj(:,1:numOfVectors);


%%
%Select numTopics, where numTopics is the number of topics
for numTopics = 3:5

    %NNMF algorithm in Matlab
    [w,h] = nnmf(normMatZ,numTopics);

    %Let A be the adjacency matrix, with dimensions [n, numTopics]
    A =[];

    type =4;
    
    switch type
        case 1
            data_used = origMat;
            %Variance for each column
            varTop = var(origMat,1,1);
        
        case 2
            data_used = normMatPR;
            %Variance for each column
            varTop = var(normMatPR,1,1);
        
        case 3
            data_used = normMatZ;
            %Variance for each column
            varTop = var(normMatZ,1,1);
        
        case 4
            data_used = proj_optimal;
            %Variance for each column
            varTop = var(proj_optimal,1,1);
        case 5
            data_used = w;
            %Variance for each column
            varTop = var(w,1,1);
    end

    for rownum1 = 1:n
        Arow = [];
        for rownum2 = 1:n
            %Result for each Topic
            resforTopic = ((data_used(rownum1,:) - data_used(rownum2,:)).^2)./(2*varTop);
            sum_rowdiffsqr = sum(resforTopic);
            Arow = horzcat(Arow, exp(-sum_rowdiffsqr));
        end
        A = vertcat(A, Arow);
    end

    %%
    A = A - eye(n);

    % The diagonal component of D
    Ddiag = sum(A);

    % Let D be the Weight Matrix
    D = diag(Ddiag);    

    %Let L be the Laplacian matrix
    L = D-A;

    %Obtaining the eigenvalues and eigenvectors of L
    [V,E] = eig(L,D,'vector');
    E20 = E(1:20);
    E20 = sortrows(E20, 1);
%%
    %Create a plot of eigenvalues on its index
    figure()
    indE20 = 1:length(E20);
    scatter(indE20, E20);
    title('Plot of eigenvalue vs its index');
    xlabel('index');ylabel('eigenvalue');


    %normalized V
    normV = (V - mean(V))./sqrt(var(V,1,1));

    %%
    %number of cluster
    numClus = input('Number of Clusters: ');


%     %use the Gaussian Mix distribution to cluster
%     GMModel = fitgmdist(data_used,numClus,'Options',...
%         statset('Display','final','MaxIter',1500,'TolFun',1e-5));
%     idx = cluster(GMModel, data_used);
%     data_used = horzcat(cell2mat(table2cell(data(1:818,1))), data_used);

    % use the eigenvectors
    % Forming the eigenpair matrix
    eigenpairMat = horzcat(E,normV');
    eigenpairMat = sortrows(eigenpairMat, 1);
    eigenpairMatChosen = eigenpairMat(1:numClus,:);

    % obtain only the eigenvector matrix
    eigenvecMat = eigenpairMatChosen(:,2:end)';
    idx = kmeans(eigenvecMat, numClus);
    data_used = horzcat(cell2mat(table2cell(data(1:818,1))), data_used);

    figure
    hold on
    plot(data_used(idx==1,1),'xr')
    plot(data_used(idx==2,1), 'xb')
    plot(data_used(idx==3,1), '+g')
    plot(data_used(idx==4,1), '+y')
    plot(data_used(idx==5,1), '*c')
    plot(data_used(idx==6,1), 'pm')
    plot(data_used(idx==7,1), 'dk')
    plot(data_used(idx==8,1), '<r')
    plot(data_used(idx==9,1), '>b')
    plot(data_used(idx==10,1), '.m')
    hold off
    xlabel('Number of tracks in a cluster');ylabel('Track');

    display('Cluster size for each clusters');
    for hj = 1:numClus
        display(size(data(idx==hj,1)));
    end
    figure
    histogram(HomePop15(idx==1,2))
    figure
    histogram(HomePop15(idx==2,2))
    figure
    histogram(HomePop15(idx==3,2))
    if type ~= 5
        break
    end

end

%%
% homelesspopden = cell2mat(table2cell(data(:,[1,26])));
% homelesspopden = sortrows(homelesspopden, -2);
% homelesspopden = homelesspopden(1:50,:);
% 
% GroupWithHomeless = [];
% for n = 2:numClus
%     dat1 = cell2mat(table2cell(data(idx==n,1)));
%     for rownum1 = 1:length(dat1)
%         for rownum2 = 1:length(homelesspopden(:,1))
%             if dat1(rownum1,1) == homelesspopden(rownum2,1)
%                 GroupWithHomeless = horzcat(GroupWithHomeless,...
%                     dat1(rownum1,1));
%                 break;
%             end
%         end
%     end
%    
% end
% 
% %%
% %write to excel
% filename = 'Cluster_Analysis_unnormalizedLapl_zscore.xlsx';
% index = 1;
% for n = 2:numClus
%     xlswrite(filename, {...
%         strcat('Census tracks in cluster_', num2str(n))...
%         },1,strcat('A', num2str(index))); 
%     dat = data(idx==n,1);
%      xlswrite(filename, {...
%         strcat('No.tracks:', num2str(length(cell2mat(table2cell(dat)))))...
%         },1,strcat('B', num2str(index+1))); 
%     writetable(dat,filename,'Sheet',1,'Range',strcat('A', num2str(index+1)))
%     index = index + 3+ length(cell2mat(table2cell(dat)));
% end
% 
% %%
% GroupWithHomelessTab = array2table(GroupWithHomeless', 'VariableNames',...
%     {'track'});
%  xlswrite(filename, {...
%         'Overlap between the cluster and the top 50 homeless population density'...
%         },1,'D1'); 
% writetable(GroupWithHomelessTab,filename,'Sheet',1,'Range','D2')
