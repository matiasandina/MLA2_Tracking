function [centroid_final] = hsv_transform(plotMe, startFrame, saveMe)

tic

clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures if you have the Image Processing Toolbox.
clearvars -except plotMe startFrame saveMe;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;

% Initialize video with helper function
[videoObject, numberOfFrames] = initialize_video;

% Alocate space
centroid_final(numberOfFrames, 2) = 0;
% area_final(numberOfFrames) = 0;
frame_comments = strings(1,numberOfFrames);


textprogressbar('calculating position: ');

% Read one frame at a time, and find specified color.
for k = startFrame : numberOfFrames
    
    progress_percent = round(k/numberOfFrames * 100, 3);
    
    % Display progress with helper
    textprogressbar(progress_percent)
    
       
    % Read one frame
    thisFrame=read(videoObject,k); % DO NOT change to readFrame!
    
    % HSV transformation
    % create_RatMask is a helper function (already has HSV values!!!)
    
    [BW,~] = create_RatMask(thisFrame); % Second argument MaskedImage not needed
    
    % Fix image
    
    % A bit of erosion
    se = strel('rectangle',[5 5]);
    blobMask = imerode(BW, se);
    
    % Filter out small blobs.
    blobMask = bwareaopen(blobMask, 500);
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
        
        if (k == startFrame)
        Rat_old_position = Rat_new_position; % update old
        end
           
         
    end
    
    % If it actually lost track it will find nothing
    % especially because we masked it to zero
    % we default to last position
    % we also have area filter
    
    if (isempty(stat) | max_area < 3000)
     
    sprintf('Empty or Area is small!')

    % default to NaN
    % We will post-process
      
    Rat_new_position = [NaN NaN];
        
    end    
            
    % we need for plot
    centroids = Rat_new_position;  
        
    % Save the centroid values
    
    centroid_final(k, :) = Rat_new_position;
          
    % Only plot if necesary (slows code down a lot!)
    
    if (plotMe == 1)
 
     flag_running = 1;
     
        % Display frames
        
        if k==startFrame
            
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
            
            % This format has issues with cData because to move them around you 'make them active'
            %      figure;
            %      figure_1 = subplot(1,1,1);
            %
            %      figure;
            %      figure_2 = subplot(1,1,1);
            %
            %      figure;
            %      figure_3 = subplot(1,1,1);
            %
            %      figure;
            %      figure_4 = subplot(1,1,1);
            
            
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


%% Save the stuff

if(saveMe)

    % position
    csvwrite('position.csv', centroid_final);

    % frame_comments
    fid = fopen('frame_comments.txt','wt');
    fprintf(fid, '%s\n\r', frame_comments);
    fclose(fid);

end

textprogressbar('Finished!');

toc
end