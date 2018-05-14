function [long,lat, weight] = get_long_lat_weight(ct, topic, weightMat, long_lat_mat)
    sz = length(long_lat_mat(:,1));
    for i = 1:sz
        if long_lat_mat(i,1) == ct
            long = long_lat_mat(i,3);
            lat = long_lat_mat(i,2);
            break;
        end
    end
    
    sz1 = length(weightMat(:,1));
    for i = 1:sz1
        if weightMat(i,1) == ct
            weight = weightMat(i, topic+1);
            break;

        end
    end
    

end