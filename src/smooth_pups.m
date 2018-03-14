% Smooth pups

% Pups normally don't move much

function pup_smooth = smooth_pups(data_to_smooth)

% We add a filter with 60 frames (2 seconds) movmedian
pup_smooth = smoothdata(data_to_smooth, 'movmedian', 60);

end