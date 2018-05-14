%Read data in to a table to make it easy to sort rows
data = readtable('Data2017byCensus_allEstimated.xlsx');
 
%Select columns and format
origMat = cell2mat(table2cell(data(:,[32,33,34,28,29,30,31,2,3,22])));
[n,m] = size(origMat);


%Normalize, get matrix of form normMat (n x m) H (n x k) and W(k x m)
normMat = tiedrank(origMat) / n;
 
%Select k
for k = 2:10 
 
    %NNMF algorithm in Matlab
    [w,h] = nnmf(normMat,k);

    %M matrix will be the normalized matrix table paired with tracts
    M = data(:,1);
    M(:,2:(m+1)) = array2table(normMat);
    M.Properties.VariableNames = {'Tract','CoffeeDensity', 'RestaurantDensity', 'ShelterDensity','CrimeDensity','HousingDensity', 'BusStopDensity','GenPop2015Density','ZRI','ZHVI','MedHouseholdIncome'};

    %W matrix will be weight matrix
    %Pair tract number with topic
    W = data(:,1);
    W(:,2:(k+1)) = array2table(w);
    for j = 2:k+1
        W.Properties.VariableNames{j} = strcat('Var',num2str(j));
    end

    %H matrix will be topic matrix
    H = array2table(h,'VariableNames',{'CoffeeDensity', 'RestaurantDensity', 'ShelterDensity','CrimeDensity','HousingDensity', 'BusStopDensity','GenPop2015Density','ZRI','ZHVI','MedHouseholdIncome'});

    %Inspect top 10 rows sorted by each topic
    for j = 2:k+1
        W = sortrows(W,strcat('Var',num2str(j)),'descend');
    end

    %Inspect top 10 
   % M = sortrows(M,'HomelessPopDensity','descend');
    %disp(M(1:5,:));
   
    %Correlation analysis
    homelesspop = cell2mat(table2cell(data(:,26)));
    tphpmat = horzcat(w,homelesspop);
    corrMat = corrcoef(tphpmat);
    covMat = cov(tphpmat);
    
    A = num2str(k);
    formatSpec = "Correlation coefficients when k= ";
    disp(strcat(formatSpec, A));

    disp("The correlation coefficient matrix for all topics+homeless population");
    disp(corrMat);
    disp("The covariance matrix for all topics+homeless population");
    disp(covMat);

end




  