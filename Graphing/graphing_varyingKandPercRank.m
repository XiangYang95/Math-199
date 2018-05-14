%Read data in to a table to make it easy to sort rows
data = readtable('Data2017byCensus_allEstimated.xlsx');

%cars, van and camp data
cars_tent_camp = cell2mat(table2cell(data(:,13:15)));
[n,~] = size(cars_tent_camp(:,1));
ctc = sum(cars_tent_camp,2);

%tent and encamp data
te = cell2mat(table2cell(data(:,16:17)));
te = sum(te,2);

%shelter data 
shelter = cell2mat(table2cell(data(:,19)));

% %Select columns and format
origMat = cell2mat(table2cell(data(:,[32,33,34,28,29,30,31,2,3,22])));
% No added features
origMat1 = origMat;
% Added the number of people who live in cars or vans or campers
origMat2 = horzcat(origMat, ctc);
% Added the number of people who live in tents or encampments
origMat3 = horzcat(origMat, te);
% Added the number of people who live in shelters
origMat4 = horzcat(origMat, shelter);
 
[~,m1] = size(origMat1);
[~,m2] = size(origMat2);
[~,m3] = size(origMat3);
[~,m4] = size(origMat4);

%Normalize, get matrix of form normMat (n x m) H (n x k) and W(k x m)
normMat1 = tiedrank(origMat1) / n;
normMat2 = tiedrank(origMat2) / n;
normMat3 = tiedrank(origMat3) / n;
normMat4 = tiedrank(origMat4) / n;
 
% filename = 'GraphingTopicMatrix1.xlsx';
long_lat = readtable('census_centroids.xlsx');
long_lat_mat = table2cell(long_lat(:,[1,4,5]));
long_lat_mat = cell2mat(long_lat_mat);

%Homeless population
homelesspop = cell2mat(table2cell(data(:,26)));
homelesspop = tiedrank(homelesspop)-1/(n-1);

%designated file name
filename = 'Correlation and topic matrices.xlsx';

%Change the type manually
o = 1;
switch o
    case 1
        disp('Original')
    case 2
        disp('Add people who live in cars or vans or campers');
    case 3
        disp('Add people who live in tents or makeshift shelters');
    case 4
        disp('Add people who live in shelters');
end
        
% Varying k
for k = 3:3
    disp(strcat('No of Topics: ', num2str(k)));
    %NNMF algorithm in Matlab
    [w1,h1] = nnmf(normMat1,k);
    [w2,h2] = nnmf(normMat2,k);
    [w3,h3] = nnmf(normMat3,k);
    [w4,h4] = nnmf(normMat4,k);
    
    %weight matrices
    W1 = cell2mat(table2cell(data(:,1)));
    W1(:,2:(k+1)) = w1;
    W2 = cell2mat(table2cell(data(:,1)));
    W2(:,2:(k+1)) = w2;
    W3 = cell2mat(table2cell(data(:,1)));
    W3(:,2:(k+1)) = w3;
    W4 = cell2mat(table2cell(data(:,1)));
    W4(:,2:(k+1)) = w3;
    
    %putting all the weights together 
    W = {W1 W2 W3 W4};
    w = {w1 w2 w3 w3};
    
    tphpmat = horzcat(w{o},homelesspop);
    %Correlation matrix
    corrMat = corrcoef(tphpmat);
    corrMat = corrMat(1:k,end)';
    corrTab = array2table(corrMat);
    
    %corrTab.Properties.VariableNames{1} = 'Topics';
    for l = 1:k
        corrTab.Properties.VariableNames{l} = strcat('Topic_', num2str(l));
    end
    
    %max correlation, min correlation topics
    indMax = find(corrMat == max(corrMat,[],2));
    indMin = find(corrMat == min(corrMat,[],2));
    
    topic1 = [indMax, indMin];
    %let x, y, z be the longitudes, latitudes, weights       
        for topic = topic1
            x = [];
            y = [];
            z = [];
            for i = 1:n
                %First find the census tract in the weights
                ct = W{o}(i,1);
                
                %using the function to obtain the longitude, latitude and
                %weight
                [long, lat, weight] = get_long_lat_weight(ct,topic,W{o}, long_lat_mat);
                x = horzcat(x,long);
                y = horzcat(y,lat);
                z = horzcat(z,weight);
            end
             
            %Preparing the mesh the data together and then create a grid
            %from the data
             xlin = linspace(min(x), max(x), 500);
             ylin = linspace(min(y), max(y), 500);
             [X,Y]=meshgrid(xlin,ylin);
             Z = griddata(x,y,z,X,Y,'cubic');
                     
            
             figure()
             mesh(X,Y,Z) %interpolated
             axis tight; hold on
             plot3(x,y,z,'.','MarkerSize',1)
             
             if topic == indMax
                 title(strcat('Topic ',num2str(k), ': Highest Positive Correlation'))
             else
                 title(strcat('Topic ',num2str(k), ': Highest Negative Correlation'))
             end
    
             switch o
                 case 1
                    %title(strcat('Topic ', num2str(topic), ' with original features and '...
                    %,num2str(k), 'topics'));
                    %H matrix will be topic matrix
                     H = array2table(h1,'VariableNames',{'CoffeeDensity', ...
                         'RestaurantDensity', 'ShelterDensity','CrimeDensity','HousingDensity',...
                         'BusStopDensity','GenPop2015Density','ZRI','ZHVI','MedHouseholdIncome'});
                     
                 case 2
                    %title(strcat('Topic ', num2str(topic), ' with people who live in cars or vans and ',num2str(k), 'topics'));
                    %H matrix will be topic matrix
                    H = array2table(h2,'VariableNames',{'CoffeeDensity', ...
                         'RestaurantDensity', 'ShelterDensity','CrimeDensity','HousingDensity',...
                         'BusStopDensity','GenPop2015Density','ZRI','ZHVI','MedHouseholdIncome',...
                         'TotalCar+Van+CampersPpl'});
                     
                 case 3
                   % title(strcat('Topic ', num2str(topic), ' with people who live in camps or makeshift shelters and ',num2str(k), 'topics'));
                    H = array2table(h3,'VariableNames',{'CoffeeDensity', ...
                         'RestaurantDensity', 'ShelterDensity','CrimeDensity','HousingDensity',...
                         'BusStopDensity','GenPop2015Density','ZRI','ZHVI','MedHouseholdIncome',...
                         'TotalTent+EncampPpl'});
                     
                 case 4
                    %title(strcat('Topic ', num2str(topic), ' with original features and '...
                    %,num2str(k), 'topics'));
                    %H matrix will be topic matrix
                     H = array2table(h1,'VariableNames',{'CoffeeDensity', ...
                         'RestaurantDensity', 'ShelterDensity','CrimeDensity','HousingDensity',...
                         'BusStopDensity','GenPop2015Density','ZRI','ZHVI','MedHouseholdIncome',...
                         'TotalShelterPpl'});
  
             end
             
             xlabel('Longitude');ylabel('Latitude');zlabel('Weight');
        end
        
      
        disp(corrTab)
        disp('The topic matrix')
        disp(H)
%     %write to excel     
%     formatSpec = 'No. of topics: ';
%     disp(strcat(formatSpec, num2str(k)));
% 
%     xlswrite(filename, {strcat(formatSpec, num2str(k))},k-1,'A1');
%      
%     xlswrite(filename, ...
%     {'The correlation coefficient matrix for all topics+homeless population density'},k-1,'A2');
%      
%     writetable(corrTab,filename,'Sheet',k-1,'Range','A3')
%      
%     disp('The correlation coefficient matrix for all topics+homeless population density');
%     index1 = strcat('A',num2str(k+6));
%     xlswrite(filename, {'The topic matrix'},k-1,index1);
%      
%     index2 = strcat('A',num2str(k+7));
%     writetable(H,filename,'Sheet',k-1,'Range',index2)
%      
%     disp('The topic matrix')
%     index3 = strcat('A',num2str(2*k+10));
%     xlswrite(filename, {'The topic matrix'},k-1,index3);
%      
%     disp(H)
%     index4 = strcat('A',num2str(2*k+11));
%     writetable(H,filename,'Sheet',k-1,'Range',index4)
    
end

