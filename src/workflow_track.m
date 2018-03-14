%% Workflow for tracking

clear all

format long g

%% Read rat data

uiwait(msgbox('Select Rat position raw_file (white_centroids.csv)'))

[rat_raw_data, fullFileName]= read_bonsai();

% Extract between the mother folder data and the filename (folder name is RatID)
RatID = char(extractBetween(fullFileName,'data\', '\'));
% Extract file timestamp

timestamp = char(extractBetween(fullFileName,'centroids', '.csv'));

% For saving data
basedir = fullfile('data', RatID);

% pup data

[red_pup, green_pup, blue_pup] = read_pups(basedir, timestamp);

% Check what video you should be reading

animal_list = readtable('MLA_Animal_Video_Key.csv', 'Delimiter', ',');

% find the animal's position in the list
anim = find(strcmpi(animal_list.RatID, RatID));

video_to_load = char(animal_list.raw_video(anim));

%% Cut all data to correct number of frames
% Rat will be standard, pup follow startFrame and endFrame

uiwait(msgbox(sprintf('Select video %s for cutting frames', video_to_load)))

[cut_data, startFrame, endFrame, video_path, videoObject] = data_cutter(rat_raw_data);

% cut the pups to the same length as the mom
red_pup = red_pup(startFrame:endFrame, :);
green_pup = green_pup(startFrame:endFrame, :);
blue_pup = blue_pup(startFrame:endFrame, :);

metadata = cell2table({video_path, startFrame, endFrame, fullFileName},...
    'VariableNames',{'vide_path' 'starFrame' 'endFrame' 'rat_centroid'});

% Generate names for saving
cut_data_name = strcat(RatID, 'frame_adjusted', timestamp,'.csv');
metadata_name = strcat(RatID, 'metadata', timestamp, '.csv');

writetable(cut_data, fullfile(basedir, cut_data_name))
writetable(metadata, fullfile(basedir, metadata_name))

%% Everyone into an array of tables
% Further processing will be 

to_fix_diff = repmat({struct('myfield',{})}, 4, 1);
to_fix_diff{1} = cut_data;
to_fix_diff{2} = red_pup;
to_fix_diff{3} = green_pup;
to_fix_diff{4} = blue_pup;


%% Filter out data if differences too big

diff_filtered = cellfun(@fix_diff, to_fix_diff, 'UniformOutput', false);

% diff_filtered = fix_diff(rat_raw_data);
% red_pup = fix_diff(rat_pup);
% green_pup = fix_diff(green_pup);
% blue_pup = fix_diff(blue_pup);


%% Fix manual NA values
% The fixed data will have manual input
% The rows will be useful for further smoothing

% [fixed_data, row] = fix_manual(diff_filtered); 

uiwait(msgbox('Begin Manual Fix for rat position'))

fixed_data{1} = fix_manual(diff_filtered{1}, startFrame, 'fine');

uiwait(msgbox('Begin Manual Fix for pup position. Pup order red, green, blue'))

fixed_data(2:4) = cellfun(@(Q) fix_manual(Q, startFrame, 'coarse'), diff_filtered(2:4), 'UniformOutput', false);

% Save manual fix

Save_Tracking(fixed_data, 'manual', basedir, RatID, timestamp, '.csv')


%% Reinterpolate and Smooth

rloess_smooth = cellfun(@smooth_track, fixed_data, 'UniformOutput', false);

rloess_smooth(2:4) = cellfun(@(Q) smooth_pups(Q), rloess_smooth(2:4), 'UniformOutput', false);

% save reinterpolation

Save_Tracking(rloess_smooth, 'smooth', basedir, RatID, timestamp, '.csv')


