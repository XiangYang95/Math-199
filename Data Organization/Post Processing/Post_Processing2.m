clear
% 
dataMaster = readtable('2017DataByCensusMaster_updated1.xlsx');
dataAdd1 = readtable('census_centroids.xlsx');

%%
dataMasterName = dataMaster.Properties.VariableNames;
dataAdd1Name = dataAdd1.Properties.VariableNames;

[n1,m1] = size(dataMaster);

sm1 = 2:m1;
sa = 4:5;

dataMasterMat = cell2mat(table2cell(dataMaster));
dataAddMat = table2array(dataAdd1);

%%

%census centroids
cenCentroid = [];

for rownum1 = 1:n1
    for rownum2 = 1:n1
        if dataMasterMat(rownum1,1) == dataAddMat(rownum2,1)
            cenCentroid  = [cenCentroid ;...
                dataAddMat(rownum2,sa)];
            break
        end
    end
end
        
dataMasterMat1 = horzcat(dataMasterMat(:,1), cenCentroid,...
dataMasterMat(:,2:end));
%%
nameOfVariables = {'Track','Centroid_Latitude', 'Centroid_Longitude',dataMasterName{sm1}};
dataMastertab = array2table(dataMasterMat1);
dataMastertab.Properties.VariableNames = nameOfVariables;
%%
filename = '2017DataByCensusMaster_updated2.xlsx';
writetable(dataMastertab, filename);