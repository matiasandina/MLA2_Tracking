

function display_track(centroids, startFrame)

% Initialize video with helper function
[videoObject, numberOfFrames] = initialize_video;

for k = startFrame : numberOfFrames

% Read one frame
  % maybe grayscale is is better for performance?      

 thisFrame=rgb2gray(read(videoObject,k)); % DO NOT change to readFrame!

  
   if k==startFrame
         
  figure_1 = subplot(1,1,1);     
  hImage = imshow(thisFrame, 'Parent' ,figure_1);
  hold on
  plot(centroids(k,1),centroids(k,2), 'rx', 'markers',12)
          
   else
  % RGB figure_1
  set(hImage,'CData', thisFrame);
  
  
  % erase old points
  % dataH = get(gca, 'Children');

  
  if (rem(k, 10)==0)
  
  plot(centroids(k,1),centroids(k,2), 'rx', 'markers',12)    
      
  % erase_until = k-20 ;
  % erase_from = length(dataH) - 1;  

  % Seems counter intuitive but it's because later frames get put on top
  % set(dataH(erase_until:erase_from), 'visible', 'off');
  end
  
  drawnow;
       
   end
   
   
   

end





end