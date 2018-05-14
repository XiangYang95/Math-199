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

%percentile ranked the vectors and combine it with census track
ctc = tiedrank(ctc) / n;
ctc = horzcat(cell2mat(table2cell(data(:,1))), ctc);
te = tiedrank(te) / n;
te = horzcat(cell2mat(table2cell(data(:,1))), te);
shelter = tiedrank(shelter) / n;
shelter = horzcat(cell2mat(table2cell(data(:,1))), shelter);

%Normalize, get matrix of form normMat (n x m) H (n x k) and W(k x m)
normMat1 = tiedrank(origMat1) / n;
normMat2 = tiedrank(origMat2) / n;
normMat3 = tiedrank(origMat3) / n;
normMat4 = tiedrank(origMat4) / n;
 
% filename = 'GraphingTopicMatrix1.xlsx';
long_lat = readtable('census_centroids.xlsx');
long_lat_mat = table2cell(long_lat(:,[1,4,5]));
long_lat_mat = cell2mat(long_lat_mat);

%Homeless Population Density
origHomelessPopDen = cell2mat(table2cell(data(:,26)));
homelesspop = tiedrank(origHomelessPopDen)/n;
homelesspop_mat = horzcat(cell2mat(table2cell(data(:,1))), homelesspop);

%Homeless Population 
origHomelessPopDen = cell2mat(table2cell(data(:,20)));
homelesspop = tiedrank(origHomelessPopDen)/n;
homelesspop1_mat = horzcat(cell2mat(table2cell(data(:,1))), homelesspop);

%aggregate 
agg = {ctc te shelter homelesspop_mat homelesspop1_mat};

filename = 'Correlation and topic matrices.xlsx';
for j = 4:4
    x = [];
    y = [];
    z = [];
    for i = 1:n
        %First find the census tract in the weights
        ct = agg{j}(i,1);

        %using the function to obtain the longitude, latitude and
        %weight
        [long, lat, weight] = get_long_lat_weight(ct,1,agg{j}, long_lat_mat);
        x = horzcat(x,long);
        y = horzcat(y,lat);
        z = horzcat(z,weight);
    end
    figure();
    %Preparing the mesh the data together and then create a grid
    %from the data
     xlin = linspace(min(x), max(x), 1500);
     ylin = linspace(min(y), max(y), 1500);
     [X,Y]=meshgrid(xlin,ylin);
     Z = griddata(x,y,z,X,Y,'cubic');

     mesh(X,Y,Z) %interpolated
     axis tight; hold on
     plot3(x,y,z,'.','MarkerSize',1)
     xlabel('Longitude');ylabel('Latitude');zlabel('Weight');
    
      switch j
         case 1
            title('Cars, Van, Camp');   
         
         case 2
            title('Tent, Encamp');   
         
         case 3
            title('Shelter');  
         
         case 4
            title('Homeless Population Density'); 
            
          case 5
              title('Homeless Population'); 
         
         otherwise
             error('Something is wrong with the indexing');
     end
end
