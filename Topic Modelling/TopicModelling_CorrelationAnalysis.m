%Read data in to a table to make it easy to sort rows
data = readtable('Data2017byCensus_allEstimated.xlsx');

format long
%Select columns and format
origMat = cell2mat(table2cell(data(:,[32,33,34,28,29,30,31,2,3,22, 26])));
[n,m] = size(origMat);
 
%Normalize, get matrix of form normMat (n x m) H (n x k) and W(k x m)
normMat = tiedrank(origMat) / n;

%Select k
k = 3; 
 
%NNMF algorithm in Matlab
[w,h] = nnmf(normMat,k);
 
%M matrix will be the normalized matrix table paired with tracts
M = data(:,1);
M(:,2:(m+1)) = array2table(normMat);
M.Properties.VariableNames = {'Tract','CoffeeDensity', 'RestaurantDensity', 'ShelterDensity','CrimeDensity','HousingDensity', 'BusStopDensity','GenPop2015Density','ZRI','ZHVI','MedHouseholdIncome','HomelessPopDensity'};
 
%W matrix will be weight matrix
%Pair tract number with topic
W = data(:,1);
W(:,2:(k+1)) = array2table(w);
W.Properties.VariableNames{2} = 'Var1';
W.Properties.VariableNames{3} = 'Var2';
W.Properties.VariableNames{4} = 'Var3';
 
%H matrix will be topic matrix
H = array2table(h,'VariableNames',{'CoffeeDensity', 'RestaurantDensity', 'ShelterDensity','CrimeDensity','HousingDensity', 'BusStopDensity','GenPop2015Density','ZRI','ZHVI','MedHouseholdIncome','HomelessPopDensity'});

%Inspect top 10 rows sorted by each topic
W = sortrows(W,'Var1','descend');
W = sortrows(W,'Var2','descend');
W = sortrows(W,'Var3','descend');
 
%Inspect top 10 
M = sortrows(M,'HomelessPopDensity','descend');

%homelesspop = W(2:k+1).h(:,11);
homelesspop = table2array(M(:,end));

coorany = {};
for j = 2:k+1
    Wj = table2array(W(:,j));
    coorany{j} = corrcoef(Wj,homelesspop);
end

disp(strcat("Correlation coefficients with percentile ranks when k=3")
for i = 1:k
    disp(strcat("For topic ", num2str(i)))
    disp(coorany{i+1})
end



