%% This function plots all we need for evaluating the actual smoothing

function plot_interpolation(fixed_data, interpolated_data)

x = 1:length(fixed_data.X);

subplot(2,2,1);
plot(x, fixed_data.X, 'bo', x, interpolated_data.X, 'rx')  
subplot(2,2,2)
plot(x, fixed_data.Y, 'bo', x, interpolated_data.Y, 'rx')
subplot(2,2,3)
plot(fixed_data.X, fixed_data.Y, 'bo', interpolated_data.X, interpolated_data.Y, 'rx')
hSub = subplot(2,2,4);
plot(1, nan, 1, nan, 'r'); set(hSub, 'Visible', 'off');
legend(hSub, 'raw and manual fix', 'interpolated', 'Location', 'east');



end
