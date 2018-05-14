function loc_var = loc_var_mean(matrix)
    [n,m] = size(matrix);

    S = [];
    for colnum = 1:m
        sum_row = [];
        for rownum = 1:n
            k = (matrix(rownum,colnum)-mean(matrix(:,colnum)))^2;
            sum_row = [sum_row k];
        end
        summed_row = sum(sum_row);
        S = [S summed_row];
    end
    loc_var = sqrt(sum(S));