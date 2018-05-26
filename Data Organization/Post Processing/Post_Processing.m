% clear
% 
dataMaster = readtable('2017DataByCensusMaster_estimated_updated.xlsx');
dataAdd = readtable('GroceryLibrary_CensusCounts.xlsx');

dataMasterName = dataMaster.Properties.VariableNames;
dataAddName = dataAdd.Properties.VariableNames;

[n1,m1] = size(dataMaster);
[~,m2] = size(dataAdd);
sm1 = 1:60;
sm2 = 61:m1;
sa = 2:m2;
% 
dataMasterMat = cell2mat(table2cell(dataMaster));
dataAddMat = cell2mat(table2cell(dataAdd));

%libraries and stores sorted in the data master
lib_sto = [];
for rownum1 = 1:n1
    for rownum2 = 1:n1
        if cell2mat(table2cell(dataMaster(rownum1,1))) == ...
            cell2mat(table2cell(dataAdd(rownum2,1)))
            lib_sto = [lib_sto;dataAdd(rownum2,2:end)];
            break
        end
    end
end
        
dataMasterMat = horzcat(dataMasterMat(1:60), lib_sto, dataMasterMat(61,end));
dataMaster1 = array2table(dataMasterMat, 'VariableNames', {dataMasterName{sm1}, ...
    dataAddName{sa}, dataMasterName{sm2}});
