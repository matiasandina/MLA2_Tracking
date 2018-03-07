%% This function plots all we need for evaluating the actual smoothing

function plot_interpolation(raw_data, fixed_data, interpolated_data)

x = 1:length(raw_data.X);

subplot(2,2,1);
plot(x, raw_data.X, 'bo', x, fixed_data.X, 'rx')  
subplot(2,2,2)
plot(x, raw_data.Y, 'bo', x, fixed_data.Y, 'rx')
subplot(2,2,3)
plot(raw_data.X, raw_data.Y, 'bo', interpolated_data.X, interpolated_data.Y, 'rx')
hSub = subplot(2,2,4);
plot(1, nan, 1, nan, 'r'); set(hSub, 'Visible', 'off');
legend(hSub, 'raw data', 'fix and interpolated', 'Location', 'east');



end
