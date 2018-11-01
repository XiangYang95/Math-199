clear
cd 'C:\Users\Xiang\OneDrive\Desktop\Math 199\Local Variance'

%Read data in to a table to make it easy to sort rows
data = readtable('DataByCensusMaster_withPUMA_2yrRatio_succint.xlsx');
origMatName = data(1:818, [1,5:7, 39:40,43:44,84:end]).Properties.VariableNames;
origMat = cell2mat(table2cell(data(1:818, [5:7, 39:40,43:44,84:end])));
origMat = (origMat-mean(origMat))./std(origMat,1);
% 
%homeless population density
homelesspop_mat = cell2mat(table2cell(data(1:818,38)))./...
cell2mat(table2cell(data(1:818,4)));
homelesspop_mat = log(homelesspop_mat+0.25);
% homelesspop_mat = sqrt(homelesspop_mat);
homelesspop_mat = horzcat(cell2mat(table2cell(data(1:818,1))),homelesspop_mat);
homelesspop_mat = sortrows(homelesspop_mat, -2);
homelesspoptab = array2table(homelesspop_mat, 'VariableNames',...
    {'Census_track', 'ka'});
%%
[n,m] = size(origMat);

%standardizing all the original matrices
normMat1 = (tiedrank(origMat)-1)/(n-1);
normMat2 = (origMat-mean(origMat))./std(origMat,1);

%Getting back the tracks
normMat1 = horzcat(cell2mat(table2cell(data(1:818,1))), normMat1);
normMat2 = horzcat(cell2mat(table2cell(data(1:818,1))), normMat2);

normMat = {normMat1 normMat2};

long_lat = readtable('DataByCensusMaster_onlyLongLat.xlsx');
long_lat_mat = cell2mat(table2cell(long_lat(1:818,:)));


%%

%type of normalization
typeNorm = 2;

%lat, long and the loc_var vectors
x = [];
y = [];
z = [];
sub_origMat = {};
%Local Variance Matrix
loc_var_mat = [];  

for i  = 1:n
    [ct, local_var, sub_orig] = local_variance_2(normMat{typeNorm}(i,1),...
    long_lat_mat, normMat{typeNorm});
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

x2 = [];
y2 = [];
z2 = [];
for i = 1:n
    %First find the census tract in the weights
    ct = homelesspop_mat(i,1);
    %using the function to obtain the longitude, latitude and
    %weight
    [long, lat, weight] = get_long_lat_weight(ct,1,homelesspop_mat, long_lat_mat);
    x2 = horzcat(x2,long);
    y2 = horzcat(y2,lat);
    z2 = horzcat(z2,weight);
end

%Preparing the mesh the data together and then create a grid
%from the data
xlin = linspace(min(x), max(x), 500);
ylin = linspace(min(y), max(y), 500);
[X,Y]=meshgrid(xlin,ylin);
Z = griddata(x,y,z,X,Y,'cubic');
 
x2lin = linspace(min(x2), max(x2), 500);
y2lin = linspace(min(y2), max(y2), 500);
[X2,Y2]=meshgrid(x2lin,y2lin);
Z2 = griddata(x2,y2,z2,X2,Y2,'cubic');

figure()
%figure('name', strcat('Type: ', num2str(o), 'No.Topic ', num2str(k), ': Topic', ...
%num2str(topic)) ,'NumberTitle','off');
mesh(X,Y,Z) %interpolated
axis tight; hold on
plot3(x,y,z,'.','MarkerSize',1)
hold off
xlabel('Longitude');ylabel('Latitude');zlabel('Local_Variance');
colorbar
title(colorbar, 'Local Variance');
% title('Local Variance 2')

figure()
mesh(X2,Y2,Z2) %interpolated
axis tight; hold on
plot3(x2,y2,z2,'.','MarkerSize',1)
hold off
xlabel('Longitude');ylabel('Latitude');zlabel('Homeless Pop density');
colorbar
title(colorbar, 'Homeless Population Density');
% title('Homeless Population density')

%%
%Local Variance table
loc_var_tab = array2table(cell2mat(loc_var_mat(:,1:2)),...
'VariableNames',{'census_track', 'local_variance'});
% 
%find the max and min 10 census tracks and its corresponding table form
loc_var_mat_max = sortrows(loc_var_mat, 2, 'descend');
loc_var_mat_min = sortrows(loc_var_mat, 2);
% 
loc_var_tab_max = array2table(loc_var_mat_max(:,1:2),...
     'VariableNames',{'census_track', 'local_variance'});
loc_var_tab_min = array2table(loc_var_mat_min(:,1:2),...
     'VariableNames',{'census_track', 'local_variance'});

 
%write to excel
filename = 'Local_Variance_2_feat_final.xlsx';

xlswrite(filename, {...
'Top 10 census tracks with the highest homeless population density'...
},1,'E1'); 
writetable(homelesspoptab(1:5,1),filename,'Sheet',1,'Range','E2')
writetable(homelesspoptab(6:10,1),filename,'Sheet',1,'Range','F2')

xlswrite(filename, {...
    'Top 5 census tracks with maximum local variance'...
    },1,'A1'); 
writetable(loc_var_tab_max(1:5,:),filename,'Sheet',1,'Range','A2')

top1 = loc_var_mat_max(1,3);
top1tab = array2table(top1{1}, 'VariableNames', origMatName);
top2 = loc_var_mat_max(2,3);
top2tab = array2table(top2{1}, 'VariableNames', origMatName);
top3 = loc_var_mat_max(3,3);
top3tab = array2table(top3{1}, 'VariableNames', origMatName);
top4 = loc_var_mat_max(4,3);
top4tab = array2table(top4{1}, 'VariableNames', origMatName);
top5 = loc_var_mat_max(5,3);
top5tab = array2table(top5{1}, 'VariableNames', origMatName);
writetable(top1tab,filename,'Sheet',1,'Range','A9')
writetable(top2tab,filename,'Sheet',1,'Range','A18')
writetable(top3tab,filename,'Sheet',1,'Range','A27')
writetable(top4tab,filename,'Sheet',1,'Range','A36')
writetable(top5tab,filename,'Sheet',1,'Range','A45')
% 
xlswrite(filename, {...
    'Top 5 census tracks with the minimum local variance'...
    },1,'A53'); 
writetable(loc_var_tab_min(1:5,:),filename,'Sheet',1,'Range','A54')

btm1 = loc_var_mat_min(1,3);
btm1tab = array2table(btm1{1}, 'VariableNames', origMatName);
btm2 = loc_var_mat_min(2,3);
btm2tab = array2table(btm2{1}, 'VariableNames', origMatName);
btm3 = loc_var_mat_min(3,3);
btm3tab = array2table(btm3{1}, 'VariableNames', origMatName);
btm4 = loc_var_mat_min(4,3);
btm4tab = array2table(btm4{1}, 'VariableNames', origMatName);
btm5 = loc_var_mat_min(5,3);
btm5tab = array2table(btm5{1}, 'VariableNames', origMatName);
writetable(btm1tab,filename,'Sheet',1,'Range','A62')
writetable(btm2tab,filename,'Sheet',1,'Range','A71')
writetable(btm3tab,filename,'Sheet',1,'Range','A80')
writetable(btm4tab,filename,'Sheet',1,'Range','A89')
writetable(btm5tab,filename,'Sheet',1,'Range','A98')

writetable(loc_var_tab_max,filename,'Sheet',2,'Range','A1')
writetable(loc_var_tab_min,filename,'Sheet',2,'Range','B1')
writetable(homelesspoptab,filename,'Sheet',2,'Range','C1')



