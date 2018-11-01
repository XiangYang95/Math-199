clear

cd 'C:\Users\Xiang\OneDrive\Desktop\Math 199\Topic Modelling\New Results'
%Read data in to a table to make it easy to sort rows
data = readtable('DataByCensusMaster_withPUMA_2yrRatio_succint.xlsx');
% 
origMatName = data(1:818, [4:7, 38:end]).Properties.VariableNames;
origMat = cell2mat(table2cell(data(1:818,[4:7, 38:end])));

homelesspop = cell2mat(table2cell(data(1:818,[17, 27,37])));
homelesspopName = data(1:818, [17,27,37]).Properties.VariableNames;
origMat = horzcat(homelesspop,origMat);

overallName = [homelesspopName, origMatName];

corrMat = corrcoef(origMat);
corrTab = array2table(corrMat, 'VariableNames', overallName);
corrTab = corrTab(1:3,:);

