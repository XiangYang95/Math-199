function [err,clusters,mus,Xis] = Hfun(params,points,K,dim,lam)
% function HFUN computes the error in the clustering
% params are the parameters to be used, first the means, then the
% covariance matrices: diagonal first, then the 
% correlations to get off-diagonal covariances
% points are the data row by row
% K is the number of clusters
% dim is the dimension in which the points live
% lam is the penalty

num_points = size(points,1);

clusters = zeros(size(points,1),1);

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

for i=1:num_points % for each data point
    % we will try to find the value that minimizes the G
    
    kmin = 1; % best cluster
    bestG = Inf; % best value so far
    
    for k=1:K % look at all clusters        
        % find the G if i belongs to cluster k
        Gnew = G( points(i,:)', mus(:,k), Xis(:,:,k));
        if( Gnew < bestG ) % if we have a new smallest
            kmin = k; % update best cluster and G
            bestG = Gnew;
        end    
        
    end
    
    clusters(i) = kmin;    
end


% now we know the cluster so we can compute more...

err = 0;

for i=1:num_points % add the "errors" for all data
   err = err + 0.5*log(det(Xis(:,:,clusters(i)))) + ...
       G( points(i,:)', mus(:,clusters(i)), Xis(:,:,clusters(i)));    
end

for k=1:K % look at each cluster
    kcount = 0; % count how many points belong to it
    for i=1:num_points % by counting all points belonging to it
        kcount = kcount + ( k==clusters(i));
    end
    err = err + lam*kcount^2;
end

err