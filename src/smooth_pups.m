% Smooth pups

% Pups normally don't move much

function pup_smooth = smooth_pups(data_to_smooth)

% We add a filter with 60 frames (2 seconds) movmedian
% This will impact some retrievings
% It might be difficult to filter out noise from retrieving
% Retrieving looks a lot like noise but with pup/mom movement being
% highly correlated

pup_smooth = smoothdata(data_to_smooth, 'movmedian', 30);

end