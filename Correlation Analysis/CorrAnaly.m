clear 

%Set the working directory
cd 'C:\Users\Xiang\OneDrive\Desktop\Math 199\Correlation Analysis'

%obtain the data by importing the master data file from excel
data = readtable('DataByCensusMaster_new.xlsx');

%%
%Split the data into static, dynamic, change of dynamic, 
%homeless population and change in the population variables
static = data(1:875, [7,9,11,13,59:62,103,105]);
homelessPop = data(1:875, [19:22,27:30,35:38]);
dynamic = data(1:875, [39:46,63:102,107:139]);
ChgHomelessPop = data(1:875, 140:151);
ChgDynamic = data(1:875, 152:end);

%Obtain the name of the variables
staticName = static.Properties.VariableNames;
dynamicName = dynamic.Properties.VariableNames;
homelessPopName = homelessPop.Properties.VariableNames;
ChgHomelessPopName = ChgHomelessPop.Properties.VariableNames;
ChgDynamicName = ChgDynamic.Properties.VariableNames;

%name of Excel file to be exported to
filename = "CorrelationAnalysis1.xlsx";

%%
%For static analysis
%First put together the static, dynamic and homeless population
%variables
staticHP = [homelessPop static dynamic];

%convert table to matrix and then run a correlation coefficient 
%analysis
staticHPMat = cell2mat(table2cell(staticHP));
corrStatic = corrcoef(staticHPMat);

%convert the correlation matrix to a table
corrStaticTab = array2table(corrStatic);
corrStaticTab.Properties.VariableNames = [homelessPopName staticName,...
    dynamicName];

%Add another column to the beginning of the table to indicate what 
%are the variables
nameColTab = cell2table([homelessPopName staticName dynamicName]',...
    'VariableNames',{'Name'});
corrStaticTab = [nameColTab corrStaticTab];

%Print to excel
%writetable(corrStaticTab(:,1:13),filename,'Sheet',1,'Range','A1');

%%
%For dynamic analysis
%First put together the static, dynamic, change of dynamic and homeless population
%variables
dynamicHP = [ChgHomelessPop static dynamic ChgDynamic];

%convert table to matrix and then run a correlation coefficient 
%analysis
dynamicHPMat = cell2mat(table2cell(dynamicHP));
corrDynamic = corrcoef(dynamicHPMat);

%convert the correlation matrix to a table
corrDynamicTab = array2table(corrDynamic);
corrDynamicTab.Properties.VariableNames = [ChgHomelessPopName staticName,...
    dynamicName, ChgDynamicName];

%Add another column to the beginning of the table to indicate what 
%are the variables
nameColTab = cell2table([ChgHomelessPopName staticName dynamicName ChgDynamicName]',...
    'VariableNames',{'Name'});
corrDynamicTab = [nameColTab corrDynamicTab];

%Print to excel
%writetable(corrDynamicTab(:,1:length(ChgHomelessPopName)+1),filename,'Sheet',2,'Range','A1');

%%
