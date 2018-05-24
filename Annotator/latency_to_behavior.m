function [latencies] = latency_to_behavior(annotated_animal_data)
    
    % Get data from the structure
    RatID = annotated_animal_data.RatID;
    filled_data = annotated_animal_data.filled_data;
    Behavior_List = annotated_animal_data.Behavior_List;

    for behavior = 1:numel(Behavior_List)

    % Look for the behavior    
    k = strfind(filled_data.behavior, Behavior_List{behavior});
    
    % strfind gives a cell with [] and [1]
    % we want the non-empty
    % Find patterns
    pattern_matches = find(~cellfun('isempty', k));
    
    % The length of this vector gives us the total duration
    latencies.duration{behavior, 1} = length(pattern_matches);
    
    % Get the first match 
    latencies.latency{behavior, 1} = min(pattern_matches);
    
    if (isempty(latencies.latency{behavior}))
        latencies.latency{behavior} = NaN;
    end
          
    end
    
          
    % Prepare the fields for the table, mind the cell2mat
    latencies.behavior = Behavior_List;    
    latencies.latency = cell2mat(latencies.latency);
    latencies.duration = cell2mat(latencies.duration);
    latencies.RatID = string(repelem(RatID, numel(Behavior_List), 1)); 
    
    % Get things on a table and out
    latencies = struct2table(latencies);

    
end


