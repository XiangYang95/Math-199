close all;
clear;

% This loads data from a class, with about 10-30% of data points
% randomnly removed to prevent any possible identification
% with a specific course. There are 4 columns: the final exam grade,
% the midterm grade, the homework grade, and the participation grade

% read in the data - will ignore the headers!
data = xlsread('PCA_Marks.xlsx');

% students are the rows and the 4 factors are the columns
num_students = size(data,1);
num_factors = size(data,2);

% for each column, set mean to 0, normalize by "standard deviation"
for i=1:num_factors
   colMean(i) = sum(data(:,i))/num_students;
   colSTD(i) = sqrt( sum( (data(:,i)-colMean(i)).^2) / num_students);
   data(:,i) = (data(:,i) - colMean(i))/colSTD(i);
end

% do the SVD: the matrix V is the representation of the data
% that maximizes the variance of the data for each
% dimension 1..num_factors
[U, Sigma, V] = svd(data);

% proj is each student data projected into a subset of R^4 with
% increasingly greater accuracy
proj = data*V;


% labels for axes
PCA1 = strcat( 'R <', num2str(V(1,1)), ', ', num2str(V(2,1)), ', ', ...
    num2str(V(3,1)), ', ', num2str(V(4,1)), '>');

PCA2 = strcat( 'R <', num2str(V(1,2)), ', ', num2str(V(2,2)), ', ', ...
    num2str(V(3,2)), ', ', num2str(V(4,2)), '>');

PCA3 = strcat( 'R <', num2str(V(1,3)), ', ', num2str(V(2,3)), ', ', ...
    num2str(V(3,3)), ', ', num2str(V(4,3)), '>');

% get diagonal of matrix and compute total variance
diagonal = diag(Sigma.^2);
totalVariance = sum(diagonal);

% for each subspace, find how much variance it explains
for i=1:length(diagonal)
   variances_explained(i) = sum(diagonal(1:i))/totalVariance; 
end

% plots with first component only
figure(1);
plot(proj(:,1),0*data(:,1),'x');
xlabel(PCA1);
legend(strcat( 'Explains fraction', ...
    num2str(variances_explained(1)), 'of variance'));


figure(2);
plot(proj(:,1),proj(:,2),'x');
xlabel(PCA1);
ylabel(PCA2);
legend(strcat( 'Explains fraction', ...
    num2str(variances_explained(2)), 'of variance'));

figure(3);
scatter3(proj(:,1),proj(:,2),proj(:,3));
xlabel(PCA1);
ylabel(PCA2);
zlabel(PCA3);
legend(strcat( 'Explains fraction', ...
    num2str(variances_explained(3)), 'of variance'));

figure(4);
sizes = 36;

% the colours add another dimension: low participation = black, high =
% white
colours = 0.25 + 0.5*[(data(:,4) - min(data(:,4)))./(max(data(:,4)) - min(data(:,4))), ...
    (data(:,4) - min(data(:,4)))./(max(data(:,4)) - min(data(:,4))), ...
    (data(:,4) - min(data(:,4)))./(max(data(:,4)) - min(data(:,4)))];

scatter3(data(:,1), data(:,2), data(:,3), sizes, colours);

xlabel('FE');
ylabel('MT');
zlabel('HW');
legend('P');

hold on;

% now we add the component axes

parameterization = linspace(-3,3)';
pca1 = [parameterization*V(1,1), parameterization*V(2,1), ...
    parameterization*V(3,1), parameterization*V(4,1)];
colours1 = 0.25 + 0.25*(1+pca1(:,4));
scatter3(pca1(:,1), pca1(:,2), pca1(:,3), sizes, colours1);

xlabel('FE');
ylabel('MT');
zlabel('HW');
legend('P');


title('With PC1');

pause(3)
pca2 = [parameterization*V(1,2), parameterization*V(2,2), ...
    parameterization*V(3,2), parameterization*V(4,2)];
colours2 = 0.25 + 0.25*(j1+pca2(:,4));
scatter3(pca2(:,1), pca2(:,2), pca2(:,3), sizes, colours2);

xlabel('FE');
ylabel('MT');
zlabel('HW');
legend('P');


title('With PC1, PC2');

pause(3);

pca3 = [parameterization*V(1,3), parameterization*V(2,3), ...
    parameterization*V(3,3), parameterization*V(4,3)];
colours3 = 0.25 + 0.25*(1+pca3(:,4));
scatter3(pca3(:,1), pca3(:,2), pca3(:,3), sizes, colours3);

xlabel('FE');
ylabel('MT');
zlabel('HW');
legend('P');

title('With PC1, PC2, PC3');