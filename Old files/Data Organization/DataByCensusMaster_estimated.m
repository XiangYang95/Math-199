% clear
% 
% % Reading in the data
% dataCity1 = readtable('2017CityDatabyCensus_Estimated.xlsx');
% dataCityACS1 = readtable('CityDatabyCensus.xlsx');
% dataCounty1 = readtable('Data2017byCensus_allEstimated.xlsx');
% dataStores_library1 = readtable('alldata_with_distances.xlsx');
% dataLAHSA1 = readtable('LAHSA_DatabyCensusYearly.xlsx');
% dataZillowCounty1 = readtable('zillow_averaged.xlsx');
% 
% %excluding the zip codes
% dataCity1 = dataCity1(:,[1 8:end]);
% dataCityACS1 = dataCityACS1(:,[1 10:end]);
% 
% % Obtain the variable names
% dataCityACSName = dataCityACS1.Properties.VariableNames;
% dataCountyPartialName = dataCounty1.Properties.VariableNames;
% dataLAHSAName = dataLAHSA1.Properties.VariableNames;
% dataZillowName = dataZillowCounty1.Properties.VariableNames;
% dataStoreLibName = dataStores_library1.Properties.VariableNames;
% 
% % convert table to matrix
% dataCity = cell2mat(table2cell(dataCity1));
% dataCityACS = cell2mat(table2cell(dataCityACS1));
% dataCounty = cell2mat(table2cell(dataCounty1));
% dataLAHSA = cell2mat(table2cell(dataLAHSA1));
% dataZillowCounty = cell2mat(table2cell(dataZillowCounty1));
% 
% % Obtain only the stores and libraries related values
% % and then convert them
% dataStores_libraryInfo = dataStores_library1(:,[1 6:14]);
% dataStores_libraryInfo = cell2mat(table2cell(dataStores_libraryInfo));

% Obtain the size
% [n1, m1] = size(dataCity);
% [n2, m2] = size(dataCityACS);
% [n3, m3] = size(dataCounty);
% [n4, m4] = size(dataStores_libraryInfo);
% [n5, m5] = size(dataLAHSA);
% [n6, m6] = size(dataZillowCounty);
% 
% % Sorting them by the ascending census tracks
% dataCity = sortrows(dataCity, 1);
% dataCityACS = sortrows(dataCityACS, 1);
% dataCounty = sortrows(dataCounty, 1);
% dataLAHSA = sortrows(dataLAHSA, 1);
% dataStores_libraryInfo = sortrows(dataStores_libraryInfo, 1);
% dataZillowCounty = sortrows(dataZillowCounty, 1);
% 
% % Obtaining the city without ACS and variables without ACS and variables
% % without ACS
% Lia = ismember(dataCity(:,1), dataCityACS(:,1));
% dataCityNonACS = dataCity(Lia==0,:);
% 
% %Working only with county
% Lia = ismember(dataZillowCounty(:,1), dataCounty(:,1));
% dataZillowCountyTrue = dataZillowCounty(Lia,:);
% 
% dataCountyFinal = horzcat(dataCounty, dataLAHSA(:,2:end), ...
% dataZillowCountyTrue(:,2:end));
% 
% stores_libraries = [];
% for i = 1:n3
%     for j = 1:n3
%         if dataStores_libraryInfo(i,1) == dataCountyFinal(j,1)
%             stores_libraries = vertcat(stores_libraries, ...
%             dataStores_libraryInfo(i,2:end));
%         break
%         end
%     end
% end
% 
% dataCountyFinal = horzcat(dataCountyFinal,stores_libraries);
% 
% %Working on city with ACS
% City_ACS = ismember(dataCountyFinal(:,1), dataCityACS(:,1));
% 
% dataCityACSFin = dataCountyFinal(City_ACS, :);
% 
% dataCityACS = sortrows(dataCityACS, 1);
% dataCityACSFin = sortrows(dataCityACSFin, 1);
% 
% dataCityACSFin = horzcat(dataCityACSFin, dataCityACS(:,[23:28 30:end]));
% 
% % %Working on city without ACS
% CityOnly = ismember(dataCountyFinal(:,1), dataCityNonACS(:,1));
% dataCityOnlyFin = dataCountyFinal(CityOnly, :);
% 
% dataCityOnlyFin = sortrows(dataCityOnlyFin, 1);
% dataCityNonACS = sortrows(dataCityNonACS, 1);
% 
% dataCityOnlyFin = horzcat(dataCityOnlyFin, dataCityNonACS(:,24:29));
% 
% % Working on county only data
% NotCountyOnly = ismember(dataCountyFinal(:,1), dataCity(:,1));
% dataFinal = dataCountyFinal(NotCountyOnly ==0,:);
% 
% emptys1 = NaN([116 117-87], 'distributed');
% emptys1 = gather(emptys1);
% 
% emptys2 = NaN([1226 117-81], 'distributed');
% emptys2 = gather(emptys2);
% 
% dataCityOnlyFin = horzcat(dataCityOnlyFin, emptys1);
% dataFinal = horzcat(dataFinal, emptys2);
% 
% dataFinal = vertcat(dataCityACSFin, dataCityOnlyFin, dataFinal);
 
% allName = horzcat(dataCountyPartialName, dataLAHSAName(2:end), dataZillowName(2:end), ...
%     dataStoreLibName(6:14), dataCityACSName([23:28 30:end]));
% 
% dataFinalTab = array2table(dataFinal, 'VariableNames', allName);
% 
% filename = '2017DataByCensusMaster_estimated.xlsx';
% writetable(dataFinalTab, filename);



