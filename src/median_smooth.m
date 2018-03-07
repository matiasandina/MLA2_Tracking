%% Median Smooth

function median_smooth (variable, span , method)


variable_smooth = smooth(variable, span, method);

plot(variable,variable_smooth)

end