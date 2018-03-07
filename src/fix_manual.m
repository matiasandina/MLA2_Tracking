%% This function will manually fix the rat position when lost
% The output is called raw_data but it's actually a fixed version of it
% We call it the same to avoid duplication of the matrix

function [raw_data, row] = fix_manual(raw_data)


% Initialize video
if (~exist('videoObject'))
[videoObject, numberOfFrames] = initialize_video;
end

% Raw data expected to be position table
% We need a raw_data.X and raw_data.Y

% This will give you the indices 
[row, ~] = find(isnan(raw_data.X));

% We want to read every 15 frames until we have enough for interpolation

figure_1 = subplot(1,1,1);

    for ii=1:15:length(row)
  
          sprintf('Reading frame %d', ii)  

          frame_to_read = row(ii);

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
         
         raw_data.X(frame_to_read) = x;
         raw_data.Y(frame_to_read) = y;

    end
    
    sprintf('Finished!!')
    close(1)
    
end

