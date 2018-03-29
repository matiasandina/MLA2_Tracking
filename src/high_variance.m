function [raw_data] = high_variance(raw_data, startFrame)

frameID = 1:length(raw_data.X);

% Look for high variance points

var_x = movvar(raw_data.X, 60, 'omitnan');
var_y = movvar(raw_data.Y, 60, 'omitnan');

var_to_remove_x = find(var_x > 5000);
var_to_remove_y = find(var_y > 5000);

% plot for debug
% figure;
% subplot(2,1,1)
% plot(frameID, raw_data.X, '-o');
% hold on
% plot(frameID(var_to_remove_x), raw_data.X(var_to_remove_x), 'ro')
% subplot(2,1,2)
% plot(frameID, raw_data.Y, '-o');
% hold on
% plot(frameID(var_to_remove_y), raw_data.Y(var_to_remove_y), 'ro')


%% Go to fix the video

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

[row, ~] = unique([var_to_remove_x; var_to_remove_y]);
       
figure_2 = subplot(1,1,1);

    for ii=1:2:length(row)
  
          sprintf('Reading frame %d', ii + startFrame)  

          % startFrame = 0 if video not cut
          % startframe = 371 if test start was selected at frame 371
          
          frame_to_read = row(ii) + startFrame;

          % Read the frame and display
          thisFrame = read(videoObject, frame_to_read);

          if (ii==1)

          hImage = imshow(thisFrame, 'Parent' ,figure_2);
          hold on
          h1 = plot(raw_data.X(frame_to_read - startFrame), raw_data.Y(frame_to_read - startFrame), 'rx', 'MarkerSize', 12);
                 
          % prompt user to identify frame 
          answer = MFquestdlg([ 0.6 , 0.1 ], 'Is the frame correctly identified?', ...
                            'Identify frame', ...
                            'Yes','No','Cancel', 'No');
        % Handle response
        switch answer
            case 'Yes'
                continue
            case 'No'
          
            % get user input for that frame
            [x,y] = ginput(1);
            case 'Cancel' 
                error('Process Cancelled, start over.')
        end


          else

          set(hImage,'CData', thisFrame);
          delete(h1)
          hold on
          h1 = plot(raw_data.X(frame_to_read - startFrame), raw_data.Y(frame_to_read - startFrame), 'rx', 'MarkerSize', 10);
                    
           % prompt user to identify frame 
          answer = MFquestdlg([ 0.6 , 0.1 ], 'Is the frame correctly identified?', ...
                            'Identify frame', ...
                            'Yes','No','Cancel', 'No');
        % Handle response
        switch answer
            case 'Yes'
                continue
            case 'No'
          
            % get user input for that frame
            [x,y] = ginput(1);
            case 'Cancel' 
                error('Process Cancelled, start over.')
            end

          % Otherwise it goes too fast and you can't see it
          pause(0.01)
          end

         % modify original data  
         % startFrame has to be subtracted here
         
         raw_data.X(frame_to_read - startFrame) = x;
         raw_data.Y(frame_to_read - startFrame) = y;

    end
    
    sprintf('Finished!!')
    close(1)
 


end