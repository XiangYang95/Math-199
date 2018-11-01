clear
% 
dataMaster = readtable('2017DataByCensusMaster_estimated_updated.xlsx');
dataAdd1 = readtable('GroceryLibrary_CensusCounts.xlsx');
dataAdd2 = readtable('alldata_with_distancesNEW.xlsx');
dataAdd3 = readtable('census_centroids.xlsx');
%%
dataMasterName = dataMaster.Properties.VariableNames;
dataAdd1Name = dataAdd1.Properties.VariableNames;
dataAdd2Name = dataAdd2.Properties.VariableNames;
dataAdd3Name = dataAdd3.Properties.VariableNames;

[n1,m1] = size(dataMaster);
[~,m2] = size(dataAdd1);

sm1 = 2:51;
sm2 = 52:60;
sm3 = 61:m1;
sa1 = 2:m2;
sa2 = 6:8;
sa3 = 4:5;

dataMasterMat = cell2mat(table2cell(dataMaster));
dataAdd1Mat = cell2mat(table2cell(dataAdd1));
dataAdd2Mat = cell2mat(table2cell(dataAdd2(:,1:17)));
dataAdd3Mat = cell2mat(table2cell(dataAdd3));
%%
%libraries and stores sorted in the data master
lib_sto = [];

%the lattitudes and longitudes and its nearest distance
wholeFood_latlongdis = [];

%census centroids
cenCentroid = [];

for rownum1 = 1:n1
    for rownum2 = 1:n1
        if dataMasterMat(rownum1,1) == dataAdd1Mat(rownum2,1)
            lib_sto = [lib_sto;dataAdd1Mat(rownum2,sa1)];
            break
        end
    end
    
    for rownum3 = 1:n1
        if dataMasterMat(rownum1,1) == dataAdd2Mat(rownum3,1)
            wholeFood_latlongdis = [wholeFood_latlongdis;...
                dataAdd2Mat(rownum3,sa2)];
            break
        end
    end
    
    for rownum4 = 1:n1
        if dataMasterMat(rownum1,1) == dataAdd3Mat(rownum4,1)
            cenCentroid  = [cenCentroid ;...
                dataAdd3Mat(rownum4,sa3)];
            break
        end
    end
end
        
dataMasterMat1 = horzcat(dataMasterMat(:,1), cenCentroid,...
dataMasterMat(:,2:51), wholeFood_latlongdis,...
dataMasterMat(:,52:60), lib_sto, dataMasterMat(:,61:end));
%%
nameOfVariables = {'Track','Centroid_Latitude', 'Centroid_Latitude',...
    dataMasterName{sm1},dataAdd2Name{sa2}, dataMasterName{sm2},...
    dataAdd1Name{sa1}, dataMasterName{sm3}};
dataMastertab = array2table(dataMasterMat1, 'VariableNames', nameOfVariables);
%%
filename = '2017DataByCensusMaster_updated1.xlsx';
writetable(dataMastertab, filename);