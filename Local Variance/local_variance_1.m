function [ct, local_var] = local_variance_1(ct, long_lat_mat, normMat)
    %first find the 5 closest census tracts around our original census
    %track
    [n,~] = find(long_lat_mat == ct);
    
    %latitude and longitude of the current census track
    coor = long_lat_mat(n, 2:3);
    
    [rownum,~] = size(long_lat_mat);
    
    %distance matrix that contains the distance between the given census
    %track and all the other census tracks. First column is the census tracks
    %and the second column is the distance
    distMat = [];
    for i = 1:rownum
        coor_compare = long_lat_mat(i, 2:3);
        distdiff = coor-coor_compare;
        dist = norm(distdiff);
        distArr = horzcat(long_lat_mat(i,1), dist);
        distMat = vertcat(distMat, distArr);
    end
   
    %sort the rows according to distance in an ascending order
    distMat = sortrows(distMat, 2);

    %Getting the 6 census tracks with the closest distance to the original
    %census track
    cts = distMat(1:6,1);

    %subset of the normalized matrix
    [log, ~] = ismember(normMat(:,1), cts);
    sub_orig = normMat(log,:);
    
    %Get the local variance
    local_var = norm(sub_orig(:,2:end), 'fro');
end