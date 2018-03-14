%% This function will manually fix the rat position when lost
% The output is called raw_data but it's actually a fixed version of it
% We call it the same to avoid duplication of the matrix

function [raw_data, row] = fix_manual(raw_data, startFrame, manual_interpolation)


Variables = {'videoObject'};
allVariables = whos;

Video_loaded = ismember(Variables,{allVariables.name});

% Initialize video
if (Video_loaded == 0)
    [videoObject, numberOfFrames] = initialize_video;
end


% Raw data expected to be position table
% We need a raw_data.X and raw_data.Y

% This will give you the indices 
[row, ~] = find(isnan(raw_data.X));

switch manual_interpolation
    case 'coarse'
        my_frame_jump = 30;
    case 'fine'
        my_frame_jump = 15;
    otherwise
        error('Expecting "coarse" or "fine" for my_frame_jump')
end
        
figure_1 = subplot(1,1,1);
        
    for ii=1:my_frame_jump:length(row)
  
          sprintf('Reading frame %d', ii + startFrame)  

          % startFrame = 0 if video not cut
          % startframe = 371 if test start was selected at frame 371
          
          frame_to_read = row(ii) + startFrame;

          % Read the frame and display
          thisFrame = read(videoObject, frame_to_read);

          if (ii==1)

          hImage = imshow(thisFrame, 'Parent' ,figure_1);

          % get user input for that frame
          [x,y] = ginput(1);

          else

          set(hImage,'CData', thisFrame);

          % get user input for that frame
          [x,y] = ginput(1);

          % Otherwise it goes too fast and you can't see it
          pause(0.1)
          end

         % modify original data  
         % startFrame has to be subtracted here
         
         raw_data.X(frame_to_read - startFrame) = x;
         raw_data.Y(frame_to_read - startFrame) = y;

    end
    
    sprintf('Finished!!')
    close(1)
    
end

