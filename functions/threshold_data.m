function field = threshold_data(data,alpha)
    threshold = alpha*max(max(data.DF));
    field = data.DF;
    field(find(field <= threshold)) = 0;
end