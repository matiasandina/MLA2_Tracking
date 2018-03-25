%% Norm Filter

% this filter will walk every xy dot from begining to end
% for frame in frames will check
    % 1) Check if next is within threshold norm
    % 2) if it is move on
    % 3) if it isn't >> check if frame + 2 is below 2 * treshold
    % 3b) leave everything as is if that's the case
    % 3c) Remove frame + 1, replace using specific case
    
    
    
    
    function [smooth_data] = norm_filter(data_to_smooth, v_threshold)
   
    
    smooth_data = data_to_smooth;
    
    X = data_to_smooth.X;
    Y = data_to_smooth.Y;
    
    
    % calculate moving variance
    % the median of the moving variance should give an estimate of how much
    % we expect the animal to move
    
    movvar_x = median(movvar(data_to_smooth.X, 5));
    movvar_y = median(movvar(data_to_smooth.Y, 5));

    max_iter = 100;
    iter_num = 1;
    minimize_variance = true;
    
    sum_vars(max_iter) = 0;
    
    
    while minimize_variance
    
    
    for frame = 1:length(data_to_smooth.X)
        

        
        % Strongly dependent on having the first 2 frames correctly identified
        if frame < 2
           % Get xy position
            past_frame = [X(frame) Y(frame)]; 
            continue
        end
        
        
     present_frame = [X(frame) Y(frame)];
     
     % Calculate velocity
     v_xy = norm(past_frame - present_frame); 
     
     if(v_xy < v_threshold)
     % if we are moving within range, assign present to past and continue
        past_frame = present_frame; 
        continue 
     else
     
       if (frame==length(data_to_smooth.X))
           % last frame, get out, do nothing
           continue
       end
       
       % let's look at the next frame
       second_frame = [X(frame+1) Y(frame+1)];
     
        v_2_frames = norm(past_frame - second_frame);
        
        % if the change was fairly big but mantains linear movement
        if(v_2_frames < 2 * v_threshold)
        % it means we are fairly moving within range, continue
            past_frame = present_frame; 
            continue    
        else
        % Here we remove stuff
        
        X(frame) = NaN;
        Y(frame) = NaN;
        
        % case median (?)
        % window of the past measurements
        % X(frame) = median(X(frame-6: frame-1));
        % Y(frame) = median(Y(frame-6: frame-1));
        
        
           if (frame<10)
                  sprintf('Frame is small: %d', frame)
                  frames_to_include = 1:(frame + 9);
                 
           elseif frame >= (length(data_to_smooth.X) - 9)
                     sprintf('Frame is big: %d', frame)
                  frames_to_include = frame:length(data_to_smooth.X);
                  
                  
           else       
                %   sprintf('Frame in the middle: %d', frame)
                  frames_to_include = (frame - 10):(frame + 10);
                  
                  
           end    
        
        
        % Get the polynomial regression coeff
        % polyfit explodes
        
        % [coefs_x,~,mu_x] = polyfit(frames_to_include', X(frames_to_include), 3);
        %[coefs_y, ~, mu_y] = polyfit(frames_to_include', Y(frames_to_include), 3);
         
                      
        % calculate new value
        
        % new_X = polyval(coefs_x, frame, [], mu_x);
        % new_Y = polyval(coefs_y, frame, [], mu_y);
        
          
        % Spline explodes
        % Rloess
        
        %new_X = interp1(frames_to_include,X(frames_to_include), frame,'pchip');
        %new_Y = interp1(frames_to_include,Y(frames_to_include), frame,'pchip');
       
        [fill_X, Idx_X]= fillmissing(X(frames_to_include), 'movmedian', 20);
        [fill_Y, Idx_Y]= fillmissing(Y(frames_to_include), 'movmedian', 20);
                
        new_X = fill_X(Idx_X);
        new_Y = fill_Y(Idx_Y);
        
        % Assign values to current frame
        
        X(frame) = new_X;
        Y(frame) = new_Y;
        
        past_frame = [new_X new_Y]; 
        
     
     
        end
     end
     
    end
    
    
    movvar_x
    movvar_y
    
    % Once the loop is over
    % calculate the change in variance after replacement
     movvar_x = median(movvar(X, 5), 'omitnan') - movvar_x;
     movvar_y = median(movvar(Y, 5), 'omitnan') - movvar_y;
     
     sprintf('X changed %d', movvar_x)
     sprintf('Y changed %d', movvar_y)
     
 
     % We allow 10^3 times higher variance than what would be expected
     
     if (movvar_x + movvar_y < 0.005)
         minimize_variance = false; % exit while loop
         sprintf('Convergence reached in iter_num %d', iter_num)
     end
     
     if iter_num == max_iter
         sprintf('Max iteration number reached %d', max_iter)
         minimize_variance = false; % exit while loop
     end
     
     
     sum_vars(iter_num) = movvar_x + movvar_y;

     sprintf('sum of change is %d', movvar_x + movvar_y)
   
    
     iter_num = iter_num + 1;
              
     % adjust threshold to make the cuts more stringent (prevent oscillations ?)
     v_threshold = v_threshold - 0.5;
     
    % pause()
    end
    
    figure;
    plot(sum_vars, '-x')
    
    
    % Assign the new values
     smooth_data.X = X;
     smooth_data.Y = Y;
     
end