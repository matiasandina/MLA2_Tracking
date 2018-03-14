% Wrapper for read_bonsai for pups

function [red_pup, green_pup, blue_pup] = read_pups(basedir, timestamp)

% get files in dir
d=dir(basedir);

% get rid of the stupid dots matlab adds to dir
d=d(~ismember({d.name},{'.','..'}));

% match the files with timestamp in dir.name
red_match = regexpi({d.name}, strcat('red_centroids',timestamp), 'match', 'once');
green_match = regexpi({d.name}, strcat('green_centroids',timestamp), 'match', 'once');
blue_match = regexpi({d.name}, strcat('blue_centroids',timestamp), 'match', 'once');

% find the idx
red_idx = find(~cellfun(@isempty, red_match));
green_idx = find(~cellfun(@isempty, green_match));
blue_idx = find(~cellfun(@isempty, blue_match));


% red
red_name = fullfile(d(red_idx).folder, d(red_idx).name);
% green
green_name = fullfile(d(green_idx).folder, d(green_idx).name);
% blue
blue_name = fullfile(d(blue_idx).folder, d(blue_idx).name);

red_pup = read_bonsai(red_name);
green_pup = read_bonsai(green_name);
blue_pup = read_bonsai(blue_name); 

end