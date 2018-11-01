function [err,delta_k_cj,mus,Xis] = Hfun_smooth(params,points,K,dim,lam)
% function HFUN_SMOOTH computes the error in the clustering
% params are the parameters to be used, first the means, then the
% covariance matrices: diagonal first, then the
% correlations to get off-diagonal covariances
% points are the data row by row
% K is the number of clusters
% dim is the dimension in which the points live
% lam is the penalty

num_points = size(points,1);

mus = zeros(dim,K); % means
Xis = zeros(dim,dim,K); % covariance matrices

ind = 1; % index of params

for k=1:K % for each cluster
    for j=1:dim % and each component
        mus(j,k) = params(ind);
        ind = ind+1;
    end
end

% just read in the upper triangular part
for k=1:K
    for i=1:dim % the row and col same along diagonal
        Xis(i,i,k) = exp(params(ind));
        ind = ind+1;
    end
    
    for i=1:dim % for each row
        for j=i+1:dim % and each col past the row index
            % ensure entry is <= sig1 sig2
            Xis(i,j,k) = sqrt( Xis(i,i,k) * Xis(j,j,k) ) * ...
                cos(params(ind));
            ind = ind+1;
        end
    end
end

% now set the matrices
for k=1:K
    for i=1:dim
        for j=1:i-1
            Xis(i,j,k) = Xis(j,i,k);
        end
    end
end


% the argument of the exponential
G = @(x,mu,Xi) 0.5*(x-mu)'*(Xi\(x-mu));

% set matrix of G(xj, muk Xik) to all 0's initially
% rows are the points, cols for the clusters
Gmat = zeros(size(points,1),K);

% the kroncker-delta for the data point of column j
% belonging to cluster k
% initialized to all 0's initially
delta_k_cj = Gmat';

for i=1:size(Gmat,1) % for each row, the data point
    for j=1:size(Gmat,2) % for each col, the cluster
        Gmat(i,j) = G( points(i,:)', mus(:,j), Xis(:,:,j) );
    end
end

for k=1:size(delta_k_cj,1) % for each cluster
    for j=1:size(delta_k_cj,2) % and point
        
        % find the minimum of that row:
        % this helps avoid all numbers being exponentially small
        % and ensures the dominant entry doesn't get numerically
        % founded to 0...
        the_min = min(Gmat(j,:));
        
        % shift the numerator and denominator exp arguments by this amount
        delta_k_cj(k,j) = ...
            exp(-(Gmat(j,k) - the_min))/...
            sum( exp(-(Gmat(j,:) - the_min)) );
    end
end

% error in model
err = 0;

for k=1:K % consider each cluster
    for i=1:num_points % add likelihood error of point i
        err = err + delta_k_cj(k,i)*( log(det(Xis(:,:,k))) + ...
            G( points(i,:)', mus(:,k), Xis(:,:,k)) );
    end
end

for k=1:K % consider each cluster
    kcount = 0; % count how many are in each cluster
    for i=1:num_points % by adding the delta contributions of each point
        kcount = kcount + delta_k_cj(k,i);
    end
    err = err + lam*kcount^2;
end

err

end
