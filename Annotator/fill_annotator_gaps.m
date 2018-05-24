function filled_data = fill_annotator_gaps(annotated)

% Make a copy of the input table
filled_data = annotated.final_data;

non_empty = find(strlength(annotated.final_data.behavior) > 0);

empty_values = find(strlength(annotated.final_data.behavior) == 0);

for ii = 1:length(empty_values)

% Look for the closest non empty index
empty_val = empty_values(ii);

[min_dist, min_filled_idx] = min(abs(empty_val - non_empty));

% Get the actual table index from the non_empty ones
min_idx = non_empty(min_filled_idx);

    % If min_dist is too big, do nothing
    if (min_dist > 10)

        % do nothing
    else
     % Annotate with the closest
     % sprintf('Replacing %s with %s', filled_data.behavior(empty_val), filled_data.behavior(min_idx))
     
     filled_data.behavior(empty_val) = filled_data.behavior(min_idx);
    end
    
  
end



end