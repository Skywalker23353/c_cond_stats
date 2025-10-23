function DF = remove_zero_near_centerline(DF)
    % Get size of matrix
    [m, n] = size(DF);
    
    % Loop over each column
    for j = 1:n
        last_nonzero = 0; % Initialize tracker
        for i = 1:m
            if DF(i,j) ~= 0
                last_nonzero = DF(i,j);  % update last nonzero
            else
                DF(i,j) = last_nonzero;  % replace zero with last nonzero
            end
        end
    end
end
