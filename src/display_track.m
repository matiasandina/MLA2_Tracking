

function display_track(centroids, startFrame, stopFrame)

% Initialize video
if (~exist('videoObject'))
[videoObject, numberOfFrames] = initialize_video;
end


figure_1 = subplot(1,1,1);

for k = startFrame : numberOfFrames

% Read one frame
  % maybe grayscale is is better for performance?      

 thisFrame=rgb2gray(read(videoObject,k)); % DO NOT change to readFrame!

  
  if k==startFrame
         
  hImage = imshow(thisFrame, 'Parent' ,figure_1);
  hold on
  plot(centroids(k,1),centroids(k,2), 'rx', 'markers',12)
          
   else
  % RGB figure_1
  set(hImage,'CData', thisFrame);
    
  % plot only every 2nd position
  if (rem(k, 2)==0)
  
  plot(centroids(k,1),centroids(k,2), 'rx', 'markers',12)    
  
  pause(0.1)
  end
  
  drawnow;
       
  end
  
  % Adding a 'stop' here
   if (k == stopFrame)
       
    sprintf('finishing at stopFrame %d', stopFrame)   
       return
   end
   

end





end