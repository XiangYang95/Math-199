function loc_var = loc_var_mean(matrix)
    [~,m] = size(matrix);
    S = [];
    for colnum = 1:m
        sum_row = (matrix(:,colnum)-mean(matrix(:,colnum))).^2;
        summed_row = sum(sum_row);
        S = [S summed_row];
    end
    
    assert(isnan(sqrt(sum(S))) == 0);
    
    loc_var = sqrt(sum(S));
        