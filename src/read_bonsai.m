%% This function reads .csv data from Bonsai

function raw_data = read_bonsai()

[baseName, folder] = uigetfile({'*.csv'}, 'Select a csv file with positions');
fullFileName = fullfile(folder, baseName);

% Check if the video file actually exists in the current folder or on the search path.
if ~exist(fullFileName, 'file')
    % File doesn't exist -- didn't find it there.  Check the search path for it.
    % fullFileNameOnSearchPath = baseFileName; % No path this time.
    % if ~exist(fullFileNameOnSearchPath, 'file')
    % Still didn't find it.  Alert user.
    errorMessage = sprintf('Error: %s does not exist in the search path folders.', fullFileName);
    uiwait(warndlg(errorMessage));
    return;
    % end
    
end


%% Format for each line of text:
delimiter = ' '; % space delimited
startRow = 2; % (header = T in R) 
formatSpec = '%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(fullFileName,'r');

%% Read columns of data according to the format.

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, ...
                     'MultipleDelimsAsOne', true, 'TextType', 'string', ...
                     'EmptyValue', NaN, 'HeaderLines' ,startRow-1, ...
                     'ReturnOnError', false, 'EndOfLine', '\r\n');

%% Close the text file.
fclose(fileID);

%% Create output variable
raw_data = table(dataArray{1:end-1}, 'VariableNames', {'X','Y','Orientation','MinorAxis','MajorAxis'});

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

end