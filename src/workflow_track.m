%% Workflow for tracking


% Read rat data

rat_raw_data = read_bonsai();

% pup data

% pup1, pup2,...

% Fix differences too big

diff_filtered = fix_diff(rat_raw_data);

% Fix manual
% the fixed data will have manual input
% the rows will be useful for further smoothing

[fixed_data, row] = fix_manual(diff_filtered); 

% Reinterpolate and Smooth

rloess_smooth = smooth_track(fixed_data);

