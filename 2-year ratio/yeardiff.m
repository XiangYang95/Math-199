% clear
% 
% cd 'C:\Users\Xiang\OneDrive\Desktop\Math 199\2-year ratio';
% data = readtable('DataByCensusMaster.xlsx');
% 
% origMat = table2array(data(1:818,[45:52,79:end]));
% 
% ZRI1614 = origMat(:,3)./origMat(:,1);
% ZRI1715 = origMat(:,4)./origMat(:,2);
% ZRVI1614 = origMat(:,7)./origMat(:,5);
% ZRVI1715 = origMat(:,8)./origMat(:,6);
% HousingUnit1614 = origMat(:,29)./origMat(:,9);
% TotVacantUnit1614 = origMat(:,30)./origMat(:,10);
% UR1614 = origMat(:,31)./origMat(:,11);
% BPR1614 = origMat(:,32)./origMat(:,12);
% MRAPGI1614 = origMat(:,33)./origMat(:,13);
% TotPop1614 = origMat(:,34)./origMat(:,14);
% MedHouseInc1614 = origMat(:,35)./origMat(:,15);
% MedRent1614 = origMat(:,36)./origMat(:,16);
% MedVal1614 = origMat(:,37)./origMat(:,17);
% MedMonthlyHouCost1614 = origMat(:,38)./origMat(:,18);
% [n1,~] = size(data);
% 
% newDataMat = [ZRI1614, ZRI1715, ZRVI1614, ZRVI1715, HousingUnit1614,...
%     TotVacantUnit1614, UR1614, BPR1614, MRAPGI1614,TotPop1614,...
%     MedHouseInc1614,MedRent1614,MedVal1614,...
%     MedMonthlyHouCost1614];
% 
% [n2,m] = size(newDataMat);
% N = NaN([n1-n2,m]) ;
% newDataMat = [newDataMat;N];
% 
% newDataTab = array2table(newDataMat, 'VariableNames', {'ZRI1614',...
%     'ZRI1715', 'ZRVI1614','ZRVI1715', 'AffordableHousingUnit1614',...
%     'TotVacantUnit1614','UnemploymentRate1614','BelowPovertyRate1614',...
%     'MedRentAsPercentGrossIncome1614','TotPopulation1614',...
%     'MedHouseholdIncome1614','MedRent1614','MedValue1614',...
%     'MedMonthlyHouingCost1614'});
% 
% newData = horzcat(data, newDataTab);

filename = 'DataByCensusMaster+2yrRatio.xlsx';
writetable(newData, filename)