%% This function fixes whenever there is too much movement
% It will default to NaN
% We will use a 2 threshold approach X alone or Y alone and X+Y combined
% This approach it depends on the thresholds whether this makes sense
% 20 px looks like a decent threshold

% UPDATE 
% This function now also looks for high variability points
% It gives you the option to delete chuncks with high variability/false
% positive


function raw_data = fix_diff(raw_data, single_threshold, combined_threshold)

diff_X = [0; diff(raw_data.X)];
diff_Y = [0; diff(raw_data.Y)];

% Big:
% Single axis difference

idx_diff_X = find(abs(diff_X > single_threshold));
idx_diff_Y = find(abs(diff_Y > single_threshold));

% Small:
% Combined difference

combined_diff = find(abs(diff_X) + abs(diff_Y) > combined_threshold);

% Look for high variance points

var_x = movvar(raw_data.X, 60, 'omitnan');
var_y = movvar(raw_data.Y, 60, 'omitnan');

var_to_remove_x = find(var_x > 5000);
var_to_remove_y = find(var_y > 5000);

% Make them unique
rows_to_nan = unique([idx_diff_X; idx_diff_Y; combined_diff; var_to_remove_x; var_to_remove_y]);

raw_data.X(rows_to_nan) = NaN;
raw_data.Y(rows_to_nan) = NaN;


end