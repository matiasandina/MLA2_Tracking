% Function to select the correct number of frames
% We assume framerate to be fairly good (Bonsai does a good job at 30fps)

% We read an animal,
% We are shown the video
% We are asked to select a start point
%

function [cut_data, startFrame, endFrame, video_path, videoObject] = data_cutter(raw_data)

Variables = {'videoObject'};
allVariables =  evalin('base', 'whos');

Video_loaded = ismember(Variables,{allVariables.name});

% Initialize video
if (Video_loaded == 0)
    [videoObject, numberOfFrames] = initialize_video;
else
    videoObject = evalin('base','videoObject');
    numberOfFrames = videoObject.NumberOfFrame;
end

% Get video data
video_data = videoObject.findobj;

video_path = fullfile(video_data.Path, video_data.Name);

startFrame = [];
endFrame = [];

desired_frames = videoObject.FrameRate * 60 * 5; % fps * 5 min recording

% We want to read every 10

figure_1 = subplot(1,1,1);

% Add message about what clicking does and what Enter or Space bar does

ii = 1;

while ii < numberOfFrames
    
    sprintf('Reading frame %d of %d. Desired frame gap is %d, around %d ', ii, numberOfFrames, desired_frames, startFrame + desired_frames)
    
    % Read the frame and display
    thisFrame = read(videoObject, ii);
    
    if (ii==1)
        
        hImage = imshow(thisFrame, 'Parent' ,figure_1);
      
        % get user input for that frame
        % we don't care about the mouse click keyboard matters
        [~,~ , ~] = ginput(1);
        
        ii = ii + 10;
        
    else
        
        
        set(hImage,'CData', thisFrame);
        
        % get user input for that frame
        % we don't care about the mouse click keyboard matters
        [~, ~, button] = ginput(1);
        
        % 32 is spacebar ; empty is Enter >> jump to "end"
        % anything else will advance the frame
        if (isempty(button)| button == 32)
            
            % If we have no start frame put it there
            if(isempty(startFrame))
                
                startFrame = ii;
                
                % Jump to end!
                ii = numberOfFrames - 2000;
                
            else
                
                endFrame = ii;
                
                % check endFrame - startFrame ~= 5 min
                % tolerance 2 frameRates
                
                % lower limit < total frames & ...
                % total frames < upper limit
                
                desired_frames_check = desired_frames - video_data.FrameRate < endFrame-startFrame & ...
                    endFrame-startFrame < desired_frames + video_data.FrameRate;
                
                if (~desired_frames_check)
                    
                    error('Selected frames are incorrect: %d , target is around %d', ...
                        endFrame - startFrame, desired_frames);
                end
                
                % given everything is OK we break the loop
                % break the loop
                
                break
                
            end
            
        else
            
            % go on searching
            
            ii = ii + 10;
                        
            
            % Otherwise it goes too fast and you can't see it
            pause(0.1)
        end
        
    end
    
    
end

% The window is narrow enough that
% we trust the start, and modify the end to fit perfect to the desired

endFrame = floor(startFrame + desired_frames);

% modify original data

cut_data = raw_data(startFrame:endFrame,:);

sprintf('Finished!!')
close(1)

end

