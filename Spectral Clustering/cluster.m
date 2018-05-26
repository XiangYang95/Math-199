    % a simple example of the penalized log-likelihood
% clustering algorithm

% it seems to do all right at clustering, with some spurious
% classifications
% but for some reason the covariances are not in agreement with the ground
% truth. The means do converge pretty well so maybe the covariance is
% just slow to converge

% hyper-parameters
K=2; % clusters
dim=2; % dimension of points to cluster
lam = 0.25; % penalty - doesn't need to be too big

% set options for fminsearch it runs a lot to get good estimates
run_times = 800*K*dim*(dim+3)/2; % run for 800 times as many values to fit
options = optimset('MaxFunEvals',run_times);

% random vectors
x1 = 2 + 0.5*randn(200,1);
y1 = 2*x1 + randn(200,1);
x2 = 2*randn(200,1);
y2 = -6 + 3*randn(200,1);

% our data vectors
x = [x1;x2];
y = [y1;y2];

% all points together
points = [x,y];

% objective is to minimize the smoothed version
obj = @(params) Hfun_smooth(params,points,K,dim,lam);

% initial guess
% first come the means, cluster by cluster
% then come the variances and correlations, cluster by cluster
guess = [2 ,0, ... % cluster 1 mean components
     1,2, ... % cluster 2 mean components
     log(0.8), log(1.5), pi/4, ... %cluster 1: 2-diagonal entries + correlation
     log(1), log(4), pi/2]; % cluster 2: 2-diagonal entries + correlation


% the best parameters found
best = fminsearch(obj,guess,options);

% error and info from the smoothed function
[err_smooth,delta_k_cj,mus_smooth,...
    Xis_smooth] = Hfun_smooth(best,points,K,dim,lam);

% error and info from the hard threshold version
[err,clus,mus,Xis] = Hfun(best,points,K,dim,lam);

% all entries classified as cluster 1
clus1 = (clus==1);
clus2 = ~clus1; % and 2

% plots of the ground truth and clustered results assuming K=2...

figure(1);
plot(x1,y1,'gx',x2,y2,'ko');
title('truth');

figure(2);
plot(points(clus1,1),points(clus1,2),'gx',...
    points(clus2,1),points(clus2,2),'ko');
counts = sprintf(' %i in cluster 1 and %i in cluster 2',sum(clus1),sum(clus2));
title(strcat('clustered', counts));
legend('cluster 1', 'cluster 2','Location','northwest');