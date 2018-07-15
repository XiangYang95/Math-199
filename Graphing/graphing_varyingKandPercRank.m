clear

cd 'C:\Users\Xiang\OneDrive\Desktop\Math 199\Graphing'
%Read data in to a table to make it easy to sort rows
data = readtable('DataByCensusMaster_withPUMA_2yrRatio_succint.xlsx');
%just to get the trackSqMile
dataSqMile = readtable('DataByCensusMaster_withPUMA.xlsx');
%Select columns and format
origMatName = data(1:818, [4:6, 38:39, 42:43, 83:end]).Properties.VariableNames;
origMat = cell2mat(table2cell(data(1:818,[4:6, 38:39, 42:43, 83:end])));
[n,m] = size(origMat);

%Normalize, get matrix of form normMat (n x m) H (n x k) and W(k x m)
normMat1 = (tiedrank(origMat)-1) / (n-1);
%%
long_lat_mat = table2cell(data(:,1:3));
long_lat_mat = cell2mat(long_lat_mat);

%%
%Homeless population density
homelesspop = cell2mat(table2cell(data(1:818,37)));

homelesspop = homelesspop./cell2mat(table2cell(dataSqMile(1:818,10)));
homelesspop = (tiedrank(homelesspop)-1)/(n-1);
    
% Varying k
for k = 3:5
    disp(strcat('No of Topics: ', num2str(k)));
    %NNMF algorithm in Matlab
    [w,h] = nnmf(normMat1,k,'options', statset('display','final'));

    
    %weight matrices
    W = cell2mat(table2cell(data(1:818,1)));
    W = horzcat(W,w);
    
    tphpmat = horzcat(w,homelesspop);
    %Correlation matrix
    corrMat = corrcoef(tphpmat);
    corrMat = corrMat(1:k,end)';
    corrTab = array2table(corrMat);
    
    %corrTab.Properties.VariableNames{1} = 'Topics';
    for l = 1:k
        corrTab.Properties.VariableNames{l} = strcat('Topic_', num2str(l));
    end
    
    %max correlation, min correlation topics
    indMax = find(corrMat == max(corrMat,[],2))
    indMin = find(corrMat == min(corrMat,[],2))
    display(strcat('topic', num2str(k)));
    
    topic1 = [indMax, indMin];
    %let x, y, z be the longitudes, latitudes, weights       
    for topic = topic1
        x = [];
        y = [];
        z = [];
        for i = 1:n
            %First find the census tract in the weights
            ct = W(i,1);

            %using the function to obtain the longitude, latitude and
            %weight
            [long, lat, weight] = get_long_lat_weight(ct,topic,W, long_lat_mat);
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
         colorbar
         title(colorbar, 'Weight');

%          if topic == indMax
%              title(colorbar, '');
%          else
%              title(strcat('Topic ',num2str(k), ': Highest Negative Correlation'))
%          end
        
       

        %H matrix will be topic matrix
         H = array2table(h,'VariableNames',origMatName);

         xlabel('Longitude');ylabel('Latitude');zlabel('Weight');
    end
       
%write to excel
filename = 'Topic Matrix_final.xlsx';
formatSpec = 'No. of topics: ';
disp(strcat(formatSpec, num2str(k)));

xlswrite(filename, {strcat(formatSpec, num2str(k))},k-2,'A1');

xlswrite(filename, ...
{'The correlation for all topics+homeless population density'},k-2,'A2');

writetable(corrTab,filename,'Sheet',k-2,'Range','A3')

disp('The correlation coefficient matrix for all topics+homeless population density');
xlswrite(filename, {'The topic matrix'},k-2,'A6');

writetable(H,filename,'Sheet',k-2,'Range','A7')
   
end
%%

%Plotting for homeless population
homelesspop = horzcat(cell2mat(table2cell(data(1:818,1))), homelesspop);
x = [];
y = [];
z = [];
for i = 1:n
%First find the census tract in the weights
ct = homelesspop(i,1);

%using the function to obtain the longitude, latitude and
%weight
[long, lat, weight] = get_long_lat_weight(ct,1,homelesspop, long_lat_mat);
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
% title('Homeless Population Density')
xlabel('Longitude');ylabel('Latitude');zlabel('Weight');
colorbar
title(colorbar, 'Homeless Population Density');




