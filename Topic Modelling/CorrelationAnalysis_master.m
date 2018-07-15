clear 

cd 'C:\Users\Xiang\OneDrive\Desktop\Math 199\Topic Modelling\New Results'
%Read data in to a table to make it easy to sort rows
data = readtable('DataByCensusMaster_withPUMA_2yrRatio_succint.xlsx');

origMatName = data(1:818, [4:6, 38:end]).Properties.VariableNames;
origMat = cell2mat(table2cell(data(1:818,[4:6, 38:end])));

[n,m] = size(origMat);

normMat = (origMat - mean(origMat))./std(origMat,1);

%homeless population density
homelesspop_mat = cell2mat(table2cell(data(1:818,37)))./...
    cell2mat(table2cell(data(1:818,2)));

%%

for numTopics = 20:30
  display(numTopics);
[w,h] = nnmf(normMat, numTopics, 'options', statset('display','final'));

tphpmat = horzcat(w,homelesspop_mat);
%Correlation matrix
corrMat = corrcoef(tphpmat);
corrMat = corrMat(1:numTopics,end)';
corrTab = array2table(corrMat);


for l = 1:numTopics
    corrTab.Properties.VariableNames{l} = strcat('Topic_', num2str(l));
end

H = array2table(h, 'VariableNames', origMatName);

%max correlation, min correlation topics
indMax = find(corrMat == max(corrMat));
indMin = find(corrMat == min(corrMat));

topics = [indMax, indMin];
Hhighlow = {H(indMax,:), H(indMin,:)};
Hcells{numTopics-19} = Hhighlow;
end
