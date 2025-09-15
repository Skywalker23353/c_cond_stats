function DF = remove_zero_near_centerline(DF)
    for i = 1:size(DF,1)
        non_zero_val_idx = find(DF(i,:) > 0,1);
        if non_zero_val_idx > 1
            DF(i,1:non_zero_val_idx-1) = DF(i,non_zero_val_idx);
        end
    end
end
