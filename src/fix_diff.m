%% This function fixes whenever there is too much movement
% It will default to NaN
% We will use a 2 threshold approach X alone or Y alone and X+Y combined
% This approach it depends on the thresholds whether this makes sense
% 20 px looks like a decent threshold


function raw_data = fix_diff(raw_data)

diff_X = [0; diff(raw_data.X)];
diff_Y = [0; diff(raw_data.Y)];

% Big:
% Single axis difference

idx_diff_X = find(abs(diff_X > 20));
idx_diff_Y = find(abs(diff_Y > 20));

% Small:
% Combined difference

combined_diff = find(abs(diff_X) + abs(diff_Y) > 20);

% Make them unique
rows_to_nan = unique([idx_diff_X; idx_diff_Y; combined_diff]);

raw_data.X(rows_to_nan) = NaN;
raw_data.Y(rows_to_nan) = NaN;

end