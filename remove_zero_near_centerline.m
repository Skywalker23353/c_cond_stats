function DF = remove_zero_near_centerline(DF)
    % Get size of matrix
    [nrows, ncol] = size(DF);
    eps = 1e-16;
    
    % Loop over each column
    for j = 1:ncol
        last_nonzero = 0; % Initialize tracker
        for i = 1:nrows
            if DF(i,j) < eps
                last_nonzero = DF(i-1,j);  % update last nonzero
%             else
                DF(i:end,j) = last_nonzero;  % replace zero with last nonzero
                break;
            end
        end
    end
end
