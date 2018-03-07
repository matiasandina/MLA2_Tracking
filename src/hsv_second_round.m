% We will use hsv again
% We will probe with the manual values

function centroid_final = hsv_second_round(fixed_data, plotMe)

% Initialize video
if (~exist('videoObject'))
[videoObject, numberOfFrames] = initialize_video;
end

% we find the NAs

myNA = find(isnan(fixed_data.X));

% find the complete values

complete_values = find(~isnan(fixed_data.X));

% Alocate space
centroid_final(numberOfFrames, 2) = 0;

textprogressbar('calculating position: ');

% Read one frame at a time, and find specified color.
for k = 1:length(myNA)
    
    progress_percent = round(k/numberOfFrames * 100, 3);
    
    % Display progress with helper
    textprogressbar(progress_percent)
    
    frame_to_read = myNA(k);
    
    % Read one frame
    thisFrame=read(videoObject,frame_to_read); % DO NOT change to readFrame!
    
    % find the closest non empty frame
    closest_nonempty_indx = abs(min(myNA(k) - complete_values));

    closest_nonempty = round(table2array(fixed_data(closest_nonempty_indx,1:2)));
    
    % make the boundaries
    
    xmin = int64(max(closest_nonempty(1,1) - 100, 1));
    ymin = int64(max(closest_nonempty(1,2) - 100, 1));
    xmax = int64(min(xmin + 200, size(thisFrame,2)));   
    ymax = int64(min(ymin + 200, size(thisFrame,1)));
    
       
    % HSV transformation
    % create_RatMask is a helper function (already has HSV values!!!)
    
    
    % user defined parameters not really useful...a lot of noise
%     % Define thresholds for channel 1 based on histogram settings
%     channel1Min = 0.330;
%     channel1Max = 0.644;
% 
%     % Define thresholds for channel 2 based on histogram settings
%     channel2Min = 0.000;
%     channel2Max = 0.116;
% 
%     % Define thresholds for channel 3 based on histogram settings
%     channel3Min = 0.609;
%     channel3Max = 1.000;
%     
    
%     [BW,~] = create_RatMask_defined(thisFrame, channel1Min, channel1Max, ...
%                                                channel2Min, channel2Max, ...
%                                                channel3Min, channel3Max); % Second argument MaskedImage not needed
    

    [BW,~] = create_RatMask(thisFrame);

    % Fix image
  
    % create 'zero padding' inside the image, remove noise from border
    
    BW(1:60,:) = 0;
    BW(end-60:end,:) = 0;
    BW(:,1:60) = 0;
    BW(:,end-60:end) = 0;
    
    % Create the binary mask, remember xy are reverted
    CERO = zeros(size(BW));
    
    % Flip desired values to 1
    CERO(ymin:ymax, xmin:xmax) = 1;
    
    % apply mask
    
    blobMask = CERO .* BW;
    
    
    % A bit of erosion
    % se = strel('rectangle',[5 5]);
    % blobMask = imerode(BW, se);
    
    % Filter out small blobs.
    % blobMask = bwareaopen(blobMask, 500);
    % Fill holes
    blobMask = imfill(blobMask, 'holes');
            
    % Get Region properties Area and Centroids

    stat = regionprops('table', blobMask, 'Centroid','Area');
    
    % if we detected something

    if(~isempty(stat))

    max_area = max(stat.Area);
    
    % sort: biggest things on top
    stat = sortrows(stat, 'Area', 'descend');
           
        % Centroids
        
        centroids = stat.Centroid;
        
        % Rat position should be biggest blob here
          
        Rat_new_position = centroids(1,:);
        
        if (k == 1)
        Rat_old_position = Rat_new_position; % update old
        end
           
         
    end
    
  % In this case we don't want an area filter (we are forcing to detect almost anything!)
    
    if (isempty(stat))
     
    sprintf('Empty!')

    % default to NaN
    % We will post-process
      
    Rat_new_position = [NaN NaN];
        
    end    
            
    % we need for plot
    centroids = Rat_new_position;  
    
    % modify fixed_data (this will ease the search process)
    
    fixed_data.X(frame_to_read) = Rat_new_position(:,1);
    fixed_data.Y(frame_to_read) = Rat_new_position(:,2);
    
    % Save the centroid values
    
    centroid_final(k, :) = Rat_new_position;
          
    % Only plot if necesary (slows code down a lot!)
    
    if (plotMe == 1)
 
     flag_running = 1;
     
        % Display frames
        
        if k==1
            
            % hAxes = subplot(1,1,1);
            %   hImage = imshow('pout.tif','Parent',hAxes);
            % Once you have created an HG image in a given axes using imshow, you can now refresh the 'CData' of the image object.
            %   set(hImage,'CData',rand(200,200,3));
            
            
            figure_1 = subplot(2,2,1);
            figure_2 = subplot(2,2,2);
            figure_3 = subplot(2,2,3);
            figure_4 = subplot(2,2,4);
            set(gca,'XLim',[0 size(thisFrame, 2)], 'YLim',[0 size(thisFrame,1)]);
            set(gca, 'YDir', 'reverse')
            
            hImage = imshow(thisFrame, 'Parent' ,figure_1);
            iImage = imshow(BW, 'Parent', figure_2);
            jImage = imshow(blobMask, 'Parent', figure_3);
            
            
        else
            
            
            % control for closing figure
            % closing figure ends the loop!
            if ~ishghandle(figure_1)
                    flag_running = 0;
                   break
            end   
     
            
            % RGB figure_1
            set(hImage,'CData', thisFrame);
            % HSV Binary mask figure_2
            set(iImage,'CData', BW);
            % Filter
            
            set(jImage, 'CData', blobMask);
           
            % centroids in 4th position
            % figure_4 = subplot(2,2,4);
            plot(centroids(:,1), centroids(:,2), 'rx');
            set(gca,'XLim',[0 size(thisFrame, 2)], 'YLim',[0 size(thisFrame,1)]); % prevents axis from changing
            set(gca, 'YDir', 'reverse')
            
            drawnow;
            
        end


    end
end





end