clear 

cd 'C:\Users\Xiang\OneDrive\Desktop\Math 199\Spectral Clustering'
%Read data in to a table to make it easy to sort rows
data = readtable('DataByCensusMaster+2yrRatio_succint.xlsx');

origMat = cell2mat(table2cell(data(1:818,[1:6, 37:end])));

[numRows,numCols] = size(origMat);
%%
% % normalized by percentile rank
% normMat1 = (tiedrank(origMat)-1)./(n-1);
% 
% % normalized by percentile rank
% normMat2 = (origMat - mean(origMat))./sqrt(var(origMat));
% 
% %aggregate the normalized matrices together
% normMat = {normMat1 normMat2};

% typeNorm = 1;
%Select numTopics, where numTopics is the number of topics

% drop the column with NAs
origMat(:,44) = [];

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

numOfVectors = 25;
%Projected data
proj_optimal = proj(:,1:numOfVectors);

%%

for numTopics = 4:7

%NNMF algorithm in Matlab
[w,h] = nnmf(proj_optimal, numTopics);

%     %W matrix will be weight matrix
%     %Pair tract number with topic
%     W = data(:,1);
%     W(:,2:(numTopics+1)) = array2table(w);
%     for j = 2:numTopics+1
%     W.Properties.VariableNames{j} = strcat('Topic',num2str(j-1));
%     end
% 
%     %H matrix will be topic matrix
%     H = array2table(h,'VariableNames',{'CoffeeDensity', 'RestaurantDensity', ...
%     'ShelterDensity','CrimeDensity','HousingDensity', 'BusStopDensity',...
%     'GenPop2015Density','ZRI','ZHVI','MedHouseholdIncome'});

%Let A be the adjacency matrix, with dimensions [n, numTopics]
A =[];

%Variance for each column
varTop = var(w,1,1);

%first method:Multiplicative of exponentials
% for rownum1 = 1:numRows
%     Arow = [];
%     for rownum2 = 1:numRows
%         %Result for each Topic
%         resforTopic = ((w(rownum1,:) - w(rownum2,:)).^2)./(2*varTop);
%         sum_rowdiffsqr = sum(resforTopic);
%         Arow = horzcat(Arow, exp(-sum_rowdiffsqr));
%     end
%     A = vertcat(A, Arow);
% end

%Second method:Additive of exponentials
%Take the square difference of the ith row with jth row where j~=i,
%Divide them by 2*variance and exponentiate them to negative [result]
%Take an average of the exponentials for each row
%Then you'll have Aith column
%Do this for i = 1:numRows
for rownum = 1:numRows
    res = exp(-((w-w(rownum,:)).^2)./(2*varTop));
    resOverAll{rownum} = res;
    Acol = mean(res,2);
    A = [A,Acol];
end
        
%%

A = A - eye(numRows);

%The diagonal component of D
Ddiag = sum(A);

% Let D be the Weight Matrix
D = diag(Ddiag);    

%Let L be the Laplacian matrix
L = D-A;

%Obtaining the eigenvalues and eigenvectors of L
[V,E] = eig(L,D,'vector');
E20 = E(1:20);
E20 = sortrows(E20, 1);

%Create a plot of eigenvalues on its index
figure()
indE20 = 1:length(E20);
scatter(indE20, E20);
title('Plot of eigenvalue vs its index');
xlabel('index');ylabel('eigenvalue');


%normalized V
normV = (V - mean(V))./sqrt(var(V));

%normalized V by row
U = [];
for rownum = 1:numRows
    Urow = V(rownum,:)./norm(V(rownum,:));
    U = vertcat(U,Urow);
end


% %number of cluster
numClus = input('Number Of Clusters: ');

%Forming the eigenpair matrix
eigenpairMat = horzcat(E,normV');
eigenpairMat = sortrows(eigenpairMat, 1);
eigenpairMatChosen = eigenpairMat(1:numClus,:);

%obtain only the eigenvector matrix
eigenvecMat = eigenpairMatChosen(:,2:end)';
idx = kmeans(eigenvecMat, numClus);

for n = 1:numClus
    display(size(data(idx==n,1)));
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


%%
% [nA,~] = size(A);
% % conduct a k-nearest neighbor on A
% kforKNN = 400;
% 
% %number of smallest elements
% smallNo = nA-kforKNN;
% 
% A1 = A;
% %first method:make the value 0 if only one of the vertices is not in the
% %top k elements
% smallestInd = 1;
% for rownum = 1:nA
% for noOfElim = 1:smallNo
%     rowOfA = A(rownum,smallestInd:end);
%     [~,ind] = min(rowOfA);
%     A1(rownum,ind+smallestInd-1) = 0;
%     A1(ind+smallestInd-1,rownum) = 0;
%     rowOfA(ind) = [];
% end
%     smallestInd=smallestInd+1;  
% end
% 

