%Read data in to a table to make it easy to sort rows
data = readtable('Data2017byCensus_allEstimated.xlsx');
 
%Select columns and format
origMat = cell2mat(table2cell(data(:,[32,33,34,28,29,30,31,2,3,22])));
[n,m] = size(origMat);


fileid = fopen('CorrAnalyRes.txt','w');

%Normalize, get matrix of form normMat (n x m) H (n x k) and W(k x m)
normMat = [];
for j = 1:m % go through columns
    minX = min(origMat(:,j));
    maxX = max(origMat(:,j));
    for i = 1:n % go through rows
        norm_data = (origMat(i,j) - minX) / ( maxX - minX);
        normMat(i,j) = norm_data;
    end
end
 
 
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
        %W.Properties.VariableNames{3} = 'Var2';
        %W.Properties.VariableNames{4} = 'Var3';
    end

    %H matrix will be topic matrix
    H = array2table(h,'VariableNames',{'CoffeeDensity', 'RestaurantDensity', 'ShelterDensity','CrimeDensity','HousingDensity', 'BusStopDensity','GenPop2015Density','ZRI','ZHVI','MedHouseholdIncome'});

    %Inspect top 10 rows sorted by each topic
    for j = 2:k+1
        W = sortrows(W,strcat('Var',num2str(j)),'descend');
%     W = sortrows(W,'Var2','descend');
%     W = sortrows(W,'Var3','descend');
    end

    %Inspect top 10 
    %M = sortrows(M,'HomelessPopDensity','descend');
   
    %Correlation analysis
    homelesspop = cell2mat(table2cell(data(:,20)));
    coorany = {};
    for j = 2:k+1
        Wj = table2array(W(:,j));
        coorany{j} = corrcoef(Wj,homelesspop);
    end
    
    A = num2str(k);
    formatSpec = "Correlation coefficients when k= ";
    disp(strcat(formatSpec, A));
    disp("The topic matrix is")
    disp(H)
    for i = 1:k
        %B = num2str(i);
        formatSpec1 = "For topic ";
        disp(strcat(formatSpec1, num2str(i)));
        %formatSpec2 = "%f %5f %5f %5f\n";
        disp(coorany{i+1});
    end
end




  