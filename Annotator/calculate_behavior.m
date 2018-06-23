% This function will receive the annotated data from AnnotateVideo
% The idea is that it will pass that structure to a series of functions
% We will output the data with filled gaps and summary stats

clear all


filelist = list_files('Dirname', 'data', 'FullPath', true, ...
                      'Pattern', {'_annotated_behavior.mat'});

% Create a data_list to store stuff

data_list{numel(filelist), 1} = {};

% Read designated files
% Do math
% Append

for file_to_read = 1:numel(filelist)

% If we really wanted to get the raw data in
% data_list{file_to_read} = load(filelist{file_to_read});

load(filelist{file_to_read});

% Cut the data using startFrame and endFrame

my_inputs.final_data = my_inputs.final_data(my_inputs.startFrame:my_inputs.endFrame, :);

% Fill gaps
filled_data.filled_data = fill_annotator_gaps(my_inputs);
filled_data.RatID = my_inputs.RatID;
filled_data.Behavior_List = my_inputs.Behavior_List;

% append to list
data_list{file_to_read} = filled_data;

end


%% Bind the big list and save

% initiate df
filled_behavior = data_list{1}.filled_data;

filled_behavior.RatID = string(repelem(data_list{1}.RatID, ...
                                  size(filled_behavior, 1), 1));

for ii=2:numel(data_list)

   
   pre_df =  data_list{ii}.filled_data; 
   
   pre_df.RatID = string(repelem(data_list{ii}.RatID, ...
                                  size(pre_df, 1), 1));

   
   filled_behavior = vertcat(filled_behavior, pre_df);
   
    
end

% save
writetable(filled_behavior, 'data\filled_behavior_df.csv')


%% Compute Latencies and Duration

my_latencies = cellfun(@latency_to_behavior, data_list, 'UniformOutput', false);


% initiate df
df = my_latencies{1};

for ii=2:numel(my_latencies)

   df = vertcat(df, my_latencies{ii});
    
end


key = readtable('C:\Users\Matias\Desktop\MLA2_Tracking\src\MLA_Animal_Video_Key.csv', 'Delimiter', ',');

% Fix RatID column
df.RatID = {df.RatID{:}}';

% Join stuff
df = outerjoin(df,key,'MergeKeys',true);

writetable(df, 'data\df.csv')



