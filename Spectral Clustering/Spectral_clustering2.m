clear 

%Read data in to a table to make it easy to sort rows
data = readtable('2017DataByCensusMaster_estimated_updated_yang.xlsx');

origMat = cell2mat(table2cell(data(1:818,[1:33, 43:50, 60:98])));

[n,m] = size(origMat);
 
%Select numTopics, where numTopics is the number of topics
numTopics = 4; 

%NNMF algorithm in Matlab
[w,h] = nnmf(origMat,numTopics);

% %W matrix will be weight matrix
% %Pair tract number with topic
% W = data(:,1);
% W(:,2:(numTopics+1)) = array2table(w);
% for j = 2:numTopics+1
% W.Properties.VariableNames{j} = strcat('Topic',num2str(j-1));
% end
% 
% %H matrix will be topic matrix
% H = array2table(h,'VariableNames',{'CoffeeDensity', 'RestaurantDensity', ...
% 'ShelterDensity','CrimeDensity','HousingDensity', 'BusStopDensity',...
% 'GenPop2015Density','ZRI','ZHVI','MedHouseholdIncome'});

%Let A be the adjacency matrix, with dimensions [n, numTopics]
A =[];

%Variance for each column
varTop = var(w,1,1);

for rownum1 = 1:n
    Arow = [];
    for rownum2 = 1:n
        %Result for each Topic
        resforTopic = ((w(rownum1,:) - w(rownum2,:)).^2)./(2*varTop);
        sum_rowdiffsqr = sum(resforTopic);
        Arow = horzcat(Arow, exp(-sum_rowdiffsqr));
    end
    A = vertcat(A, Arow);
end

A = A - eye(n);

% The diagonal component of D
Ddiag = sum(A);

%D power -0.5
newDdiag =  Ddiag.^(-0.5);

% Let D be the Weight Matrix
D = diag(Ddiag);    
Dnew = diag(newDdiag);

%Let L be the Laplacian matrix
L = D-A;

%normalized Laplacian
normL = Dnew*L*Dnew;

%Obtaining the eigenvalues and eigenvectors of L
[V,E] = eig(normL,'vector');
E20 = E(1:20);
E20 = sortrows(E20, 1);

%Create a plot of eigenvalues on its index
figure()
indE20 = 1:length(E20);
scatter(indE20, E20);
title('Plot of eigenvalue vs its index');
xlabel('index');ylabel('eigenvalue');

%normalized V by column
normV = (V - mean(V))./sqrt(var(V));

%normalized V by row
U = [];
for rownum = 1:n
    Urow = normV(rownum,:)./norm(normV(rownum,:));
    U = vertcat(U,Urow);
end

%%
%number of the clusters
numClus = 15;

%Forming the eigenpair matrix
eigenpairMat = horzcat(E,U');
eigenpairMat = sortrows(eigenpairMat, 1);
eigenpairMat10 = eigenpairMat(1:numClus,:);

%obtain only the eigenvector matrix
eigenvecMat = eigenpairMat10(:,2:end)';
idx = kmeans(eigenvecMat, numClus);

for n = 1:numClus
    display(size(data(idx==n,1)));
end
   
%%
homelesspopden = cell2mat(table2cell(data(:,[1,26])));
homelesspopden = sortrows(homelesspopden, -2);
homelesspopden = homelesspopden(1:50,:);

GroupWithHomeless = [];
for n = 1:numClus
    if  n~= 1 && n~= 7 && n~= 9 && n~= 13
        Lia = ismember(cell2mat(table2cell(data(idx==n,1))), homelesspopden);
        GroupWithHomeless = horzcat(GroupWithHomeless,...
        cell2mat(table2cell(data(Lia,1)))');
    end
end

%write to excel
filename = 'Cluster_Analysis_2_normalizedCol.xlsx';
index = 1;
for n = 1:numClus
    if  n~= 1 && n~= 7 && n~= 9 && n~= 13
        xlswrite(filename, {...
            strcat('Census tracks in cluster_', num2str(n))...
            },1,strcat('A', num2str(index))); 
        dat = data(idx==n,1);
        xlswrite(filename, {...
        strcat('No.tracks:', num2str(length(cell2mat(table2cell(dat)))))...
        },1,strcat('B', num2str(index+1))); 
        writetable(dat,filename,'Sheet',1,'Range',strcat('A', num2str(index+1)))
        index = index + 3+ length(cell2mat(table2cell(dat)));
    end
end

GroupWithHomelessTab = array2table(GroupWithHomeless', 'VariableNames',...
    {'track'});
 xlswrite(filename, {...
        'Overlap between the cluster and the top 50 homeless population density'...
        },1,'D1'); 
writetable(GroupWithHomelessTab,filename,'Sheet',1,'Range','D2')



