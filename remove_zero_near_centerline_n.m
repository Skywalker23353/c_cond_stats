function DF = remove_zero_near_centerline_n(DF)
    % Get size of matrix
    [nrows, ncol] = size(DF);
    
    % Loop over each column
    for i = 1:nrows
        first_nonzero = 0; % Initialize tracker
        for j = 1:ncol
            if DF(i,j) > 0
                first_nonzero = DF(i,j);  % update first nonzero
%             else
                DF(i,1:j-1) = first_nonzero;  % replace zero with first nonzero
                break;
            end
        end
    end
end
