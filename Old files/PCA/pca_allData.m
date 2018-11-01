close all;
clear;
% This loads data and performs PCA on it 

%Only necessary if using Octave (otherwise omit this line)
%pkg load io
%pkg load mapping

% read in the data - will ignore the headers!
%Must input file names here:
allData = xlsread('Data2017byCensus_allEstimated.xlsx');
data = allData(:,[2:3,5:7, 21:25, 20]);

num_tracts = size(data,1);
num_factors = size(data,2);

%Turn counts into densities by dividing by zip code areas (first converting to sq. miles)
census_tracts = allData(:,1);
load('LA_tracts.mat');
shapefileTracts = 2345;
lahsaTracts = 2160; %length(census_tracts);

for i = 1:shapefileTracts
  S(i).CT10 = str2double(S(i).CT10);
end

[C, IA, IB] = intersect([S.CT10], census_tracts);

tract_areas = zeros(size(allData,1), 1);
for i = 1:length(C)
  tract_areas(i) = S(IA(i)).Shape_area;
end

%%Convert areas to square miles and get population density
tract_sq_miles = tract_areas./(5280*5280);
data_density = data(:,[3:7, 9:11])./tract_sq_miles;
combined_data = [data(:,[1:2, 8]), data_density];

% for each column, set mean to 0, normalize by unbiased estimator of standard deviation
norm_data = (combined_data - mean(combined_data))./std(combined_data);

% do the SVD: the matrix V is the representation of the data
% that maximizes the variance of the data for each
% dimension 1..num_factors
[U, Sigma, V] = svd(norm_data);

% proj is each tract data projected into a subset of R^num_factors with
% increasingly greater accuracy
proj = norm_data*V;

% get diagonal of matrix and compute total variance
diagonal = diag(Sigma.^2);
totalVariance = sum(diagonal);

% for each subspace, find how much variance it explains
for i=1:length(diagonal)
   variances_explained(i) = sum(diagonal(1:i))/totalVariance; 
end

%plot some data

% labels for axes
PCA1 = strcat( 'R <', mat2str(V(:,1)', 3), '>');

PCA2 = strcat( 'R <', mat2str(V(:,2)', 3), '>');

PCA3 = strcat( 'R <', mat2str(V(:,3)', 3), '>');
    
% plots with first component only
figure(1);
plot(proj(:,1),0*data(:,1),'x');
title('Census tract factors projected in first principal component');
xlabel(PCA1);
legend(strcat( 'Explains fraction', ...
    num2str(variances_explained(1)), 'of variance'));

print('allData_PC1.png','-dpng');


figure(2);
plot(proj(:,1),proj(:,2),'x');
title('Census tract factors projected in first two principal components');
xlabel(PCA1);
ylabel(PCA2);
legend(strcat( 'Explains fraction', ...
    num2str(variances_explained(2)), 'of variance'));

print('allData_PC2.png','-dpng');
    
    
figure(3);
scatter3(proj(:,1),proj(:,2),proj(:,3));
title('Census tract factors projected in first three principal components');
xlabel('PC1');
ylabel('PC2');
zlabel('PC3');
legend(strcat( 'Explains fraction', ...
    num2str(variances_explained(3)), 'of variance'));

print('allData_PC3.png','-dpng');

%some interpretations/analyses:

