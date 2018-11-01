clear 

%Set the working directory
cd 'C:\Users\Xiang\OneDrive\Desktop\Math 199\Correlation Analysis'

%obtain the data by importing the master data file from excel
data = readtable('DataByCensusMaster_new.xlsx');


namesTBC = {'Coffee','RestaurantCount','AffordableHousingUnits',...	
'PumaMedFamilyIncome2016','PumaMedHouseholdIncome2016',...	
'PumaMedGrossRent2016','PumaNotLaborForceRate2016',...	
'PumaPctIns2016','PumaPctMilNotActive2016','PumaPctMilNatGuard2016',...	
'PumaPctMilNever2016','PumaMedFamilyIncome2015','PumaMedHouseholdIncome2015',...
'PumaMedGrossRent2015','PumaNotLaborForceRate2015','PumaPctIns2015',...
'PumaPctMilNotActive2015','PumaPctMilNatGuard2015',...
'PumaPctMilNever2015','x2017ParkingCitationCount',...
'x2016ParkingCitationCount','x2015ParkingCitationCount',...
'x2017CrimeCount','x2016CrimeCount','x2015CrimeCount',...
'TotalVacantUnits2015','BelowPovertyRate2015','MedHouseholdIncome2015',...
'MedRent2015','MedMonthlyHousingCosts2015','TotalVacantUnits2016',...
'BelowPovertyRate2016',	'MedHouseholdIncome2016',...
'MedRent2016',	'MedMonthlyHousingCosts2016'};
%%
index = find(strcmp(namesTBC, 'MedRent2016'));
namesTBC(index) = [];

data1 = data(1:875, namesTBC);
mat = cell2mat(table2cell(data1));

R0 = corrcoef(mat); % correlation matrix
V = diag(inv(R0));

%%
nameTab = cell2table(namesTBC',...
    'VariableNames',{'Name'});

matTab = table(V,...
    'VariableNames',{'Value'});

totTab = [nameTab, matTab];

%%