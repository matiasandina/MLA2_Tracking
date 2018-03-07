%% extra stuff


    if(k == startFrame)
    % if first frame we have to define safe area
    % We should also be able to give safe area in function call alberto
    
    figure(1);
    imshow(thisFrame);
    safe_area = round(getrect) + 1 ; % +1 in case round goes to 0
    close(1);
    
    canvas = zeros(size(thisFrame,1), size(thisFrame,2));
    
    canvas(safe_area(1):(safe_area(1)+safe_area(3)), safe_area(2):safe_area(2)+safe_area(4)) = 1 ;
    
    % Get the safe zone
    canvas_region = regionprops('table', canvas, 'Centroid');
    canvas_centroid = canvas_region.Centroid;
    
    end
    
    
    % we now have all the blobs
    % to prevent for false detections
    % we are going to use the old position (exists for all but 1st frame)
    % we will mask the blobs around that
    
    if (exist('Rat_old_position', 'var'))
    
     min_x = int64(Rat_old_position(:,1)-150);
     min_y = int64(Rat_old_position(:,2)-150);
     
     max_x = int64(Rat_old_position(:,1)+150);
     max_y = int64(Rat_old_position(:,2)+150);
   
      
    % assign all values outside rectangle to 0 in blob mask
    blobMask(1:min_x, 1:min_y) = 0;
%    blobMask(max_x:size(blobMask,1), max_y:size(blobMask,2))=0; % creates problems in bottom right corner!
    end
    
    
  
    
           % Calculate Euclidean distance
        
       %  total_movement = sqrt(sum((Rat_new_position - Rat_old_position).^2));
        
       % if(total_movement > 300) % Parametrize threshold as Movement_threshold
            
            %sprintf('total movement > 300: %d', total_movement)
            
            % This probably means that a biggest blob is being wrongly recognized
            % This could also mean that the blob is no longer there
            % % In that case, we have to avoid propagating noise detection
            
            % We could go findthing the closest, but didn't work well
            
            % dist_from_old = sqrt(sum((stat.Centroid - Rat_old_position).^2, 2));
            %[~, BlobNumber] = min(dist_from_old); % ~ is a place holder for MinDiff...if needed put MinDiff back in
            % BlobNumber is conserved because of sorting
            % Rat_new_position = centroids(BlobNumber,:);
            
            
            % We will use the old centroid
                                             
        %    Rat_new_position = Rat_old_position;
            
            
        %    frame_comments(k) = 'Too much movement. Using previous blob position.';
            
        %else     
        
        frame_comments(k) = 'Real movement detected. Using new blob.';
        %end

        
        
        
        
        
        
        
        
        
        
            % if there's no previous position go to middle of the box
        % Hopefully should never happen (it only would happen in start frame)
        if (~exist('Rat_old_position', 'var'))
            
            % The center is approx
            % also bear in mind that images have different axis
            % axis 1 is height
            % axis 2 is width
            
           center_y = size(thisFrame, 1)/2;
           center_x = size(thisFrame, 2)/2;
           Rat_new_position = [center_x center_y];
           frame_comments(k) = 'Blob empty. Using center.';
        
        % Now we have to decide if we go to safe zone or use previous
        else
            
            
            if(sqrt(sum((Rat_old_position - canvas_centroid).^2)) > 100)
               
            % sprintf('using safe area')
                   
            Rat_new_position = canvas_centroid;
            Rat_old_position = Rat_new_position; % update old
            
            frame_comments(k) = 'Blob empty. Safe Area.';
            
            else
            
            % Keep using the previous position
            % Add noise towards general direction of movement
            
            general_movement = (Rat_new_position - Rat_old_position);
            
            Rat_new_position = Rat_old_position + general_movement;
            Rat_old_position = Rat_new_position; % update old
            
            frame_comments(k) = 'Blob empty. Using previous blob position.';
            end
        end

    