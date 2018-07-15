clear

x = randn(1000,1);
y = x + randn(1000,1);

figure
hold on
scatter(x,y);

x = (x-mean(x))./std(x,1);
y = (y-mean(y))./std(y,1);
data = [x,y];
% do the SVD: the matrix V is the representation of the data
% that maximizes the variance of the data for each
% dimension 1..num_factors
[U, Sigma, V] = svd(data);

% proj is each student data projectedinto a subset of R^4 with
% increasingly greater accuracy
proj = data*V;

% get diagonal of matrix and compute total variance
diagonal = diag(Sigma.^2);
totalVariance = sum(diagonal);

% for each subspace, find how much variance it explains
for i=1:length(diagonal)
   variances_explained(i) = sum(diagonal(1:i))/totalVariance; 
end

j = -4:4;
parameterization = linspace(-5,5)';
pca1 = [parameterization*V(1,1), parameterization*V(2,1)];
p1 = plot(pca1(:,1),pca1(:,2));

parameterization = linspace(-2,2)';
pca2 = [parameterization*V(1,2), parameterization*V(2,2)];
p2 = plot(pca2(:,1),pca2(:,2));

legend([p1,p2],{'First Principal Component', 'Second Principal Component'}, ...
    'Location','northwest');


