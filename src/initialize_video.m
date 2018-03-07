function [videoObject, numberOfFrames] = initialize_video

[baseName, folder] = uigetfile({'*.avi', '*.mp4'}, 'Select a video file');
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

% Instantiate a video reader object for this video.
videoObject = VideoReader(fullFileName);

% Setup other parameters
numberOfFrames = videoObject.NumberOfFrame;


end