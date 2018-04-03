%% Smooth


function fixed_data = smooth_track(fixed_data)



% find breakpoints that where we need to replace
% replacing there will be greedy (old values will be overwritten)

% breakpoints = find(diff(rows) > 5);

% we will smooth locally
% we do this because we added ground truth elements manually

    % all the operations are in array so convert entry data to array
    data = table2array(fixed_data);
    
    % logical telling us where the NaNs are
    nanData = isnan(data);
    % indexing on all the elements of the array 
    index   = 1:numel(data);
    % duplicate data
    data2   = data;
    
    % this will be the tamplate we use for interpolation
    nonNan = data(~nanData);

    
    % data2 will be the interpolated data
    % method nearest seems to work pretty well with what we want
    
    data2(nanData) = interp1(index(~nanData), nonNan, index(nanData), 'nearest');


    % we add a 'rloess' smoothing to that
    
    rloess_smoothing = smoothdata(data2(:,1:2), 'rloess');
    
    % we will substitute the ones that were NA
    
    fixed_data.X(nanData(:,1)) = rloess_smoothing(nanData(:,1),1);
    fixed_data.Y(nanData(:,2)) = rloess_smoothing(nanData(:,2),2);
    
    % We add a smoothing portion with movmedian
    % This reduces unnecessary noise (also makes the path fit the animal real position less)
    
    fixed_data.X = smoothdata(fixed_data.X, 'movmedian', 15);
    fixed_data.Y = smoothdata(fixed_data.Y, 'movmedian', 15);
    
end