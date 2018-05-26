clear
cd 'C:\Users\Xiang\OneDrive\Desktop\Math 199\Local Variance'
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
 
%standardizing all the original matrices
normMat1 = zscore(origMat1);
normMat2 = zscore(origMat2);
normMat3 = zscore(origMat3);
normMat4 = zscore(origMat4);

%Get back the census tracks
normMat1 = horzcat(cell2mat(table2cell(data(:,1))), normMat1);
normMat2 = horzcat(cell2mat(table2cell(data(:,1))), normMat2);
normMat3 = horzcat(cell2mat(table2cell(data(:,1))), normMat3);
normMat4 = horzcat(cell2mat(table2cell(data(:,1))), normMat4);

%Putting all the normalized matrices together
normMat = {normMat1 normMat2 normMat3 normMat4};

%Putting all the matrices together+census tracks
origMat = {origMat1 origMat2 origMat3 origMat4};

% filename = 'GraphingTopicMatrix1.xlsx';
long_lat = readtable('census_centroids.xlsx');
long_lat_mat = table2cell(long_lat(:,[1,4,5]));
long_lat_mat = cell2mat(long_lat_mat);

%homeless population density
homelesspop_mat = cell2mat(table2cell(data(:,[1,26])));
homelesspop_mat = sortrows(homelesspop_mat, -2);
homelesspoptab = array2table(homelesspop_mat, 'VariableNames',...
    {'Census_track', 'ka'});

filename = 'Local_Variance_1_feat.xlsx';
for type = 1:4
    %lat, long and the loc_var vectors
    x = [];
    y = [];
    z = [];
          
    %Local Variance Matrix
    loc_var_mat = [];  

    for i  = 1:n
        [ct, local_var, sub_orig] = local_variance_1(normMat{type}(i,1) , long_lat_mat, normMat{type}, type);
        loc_var_mat = vertcat(loc_var_mat, [ct, local_var, {sub_orig}]);
    end

    for j = 1:n
        %First find the census tract in the weights
        ct = cell2mat(loc_var_mat(j,1));
        %using the function to obtain the longitude, latitude and
        %weight
        [long, lat, loc_var] = get_long_lat_weight(ct,1,cell2mat(loc_var_mat(:,1:2)), long_lat_mat);
        x = horzcat(x,long);
        y = horzcat(y,lat);
        z = horzcat(z,loc_var);
    end
    %Preparing the mesh the data together and then create a grid
    %from the data
     xlin = linspace(min(x), max(x), 500);
     ylin = linspace(min(y), max(y), 500);
     [X,Y]=meshgrid(xlin,ylin);
     Z = griddata(x,y,z,X,Y,'cubic');
     
     figure()
     %figure('name', strcat('Type: ', num2str(o), 'No.Topic ', num2str(k), ': Topic', ...
     %num2str(topic)) ,'NumberTitle','off');
     mesh(X,Y,Z) %interpolated
     axis tight; hold on
     plot3(x,y,z,'.','MarkerSize',1)
     xlabel('Longitude');ylabel('Latitude');zlabel('Local_Variance');

     
     switch type
         case 1
             title('Local Variance 1:Original')
         case 2
             title('Local Variance 1:Car/Van/Campers')
         case 3
             title('Local Variance 1:Tents/Encampments')
         case 4
             title('Local Variance 1:Shelter')
     end

    %Local Variance table
    loc_var_tab = array2table(cell2mat(loc_var_mat(:,1:2)),...
    'VariableNames',{'census_track', 'local_variance'});
    
    %find the max and min 5 census tracks and its corresponding table form
    loc_var_mat_max = sortrows(loc_var_mat, -2);
    loc_var_mat_min = sortrows(loc_var_mat, 2);
    
    loc_var_tab_max = array2table(loc_var_mat_max(:,1:2),...
         'VariableNames',{'census_track', 'local_variance'});
    loc_var_tab_min = array2table(loc_var_mat_min(:,1:2),...
         'VariableNames',{'census_track', 'local_variance'});
    
    %write to excel
    xlswrite(filename, {...
    'Top 10 census tracks with the highest homeless population density'...
    },type,'E1'); 
    writetable(homelesspoptab(1:5,1),filename,'Sheet',type,'Range','E2')
    writetable(homelesspoptab(6:10,1),filename,'Sheet',type,'Range','F2')

    xlswrite(filename, {...
        'Top 5 census tracks with maximum local variance'...
        },type,'A1'); 
    writetable(loc_var_tab_max(1:5,:),filename,'Sheet',type,'Range','A2')
    
    top1 = loc_var_mat_max(1,3);
    top2 = loc_var_mat_max(2,3);
    top3 = loc_var_mat_max(3,3);
    top4 = loc_var_mat_max(4,3);
    top5 = loc_var_mat_max(5,3);
    writetable(top1{1},filename,'Sheet',type,'Range','A9')
    writetable(top2{1},filename,'Sheet',type,'Range','A18')
    writetable(top3{1},filename,'Sheet',type,'Range','A27')
    writetable(top4{1},filename,'Sheet',type,'Range','A36')
    writetable(top5{1},filename,'Sheet',type,'Range','A45')
    
    xlswrite(filename, {...
        'Top 5 census tracks with the minimum local variance'...
        },type,'A53'); 
    writetable(loc_var_tab_min(1:5,:),filename,'Sheet',type,'Range','A54')

    btm1 = loc_var_mat_min(1,3);
    btm2 = loc_var_mat_min(2,3);
    btm3 = loc_var_mat_min(3,3);
    btm4 = loc_var_mat_min(4,3);
    btm5 = loc_var_mat_min(5,3);
    writetable(btm1{1},filename,'Sheet',type,'Range','A62')
    writetable(btm2{1},filename,'Sheet',type,'Range','A71')
    writetable(btm3{1},filename,'Sheet',type,'Range','A80')
    writetable(btm4{1},filename,'Sheet',type,'Range','A89')
    writetable(btm5{1},filename,'Sheet',type,'Range','A98')

end


