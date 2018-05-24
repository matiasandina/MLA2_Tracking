%% Annotate is the working Function
% called when position is changed and annotate button
% It will update the outputdata

        function outputdata = Annotate(varargin)

            hFigure = findobj('tag', 'VideoPlay');
            outputdata = guidata(hFigure);
          
            % change value of the orther button to 0
            set(outputdata.hNotAnnotateButton, 'Value', 0);
                    
            % Get behavior to be annotated from radio buttons
            
            outputdata.radioActive = get(outputdata.radio, 'Value');
            
            % Get behavior index for the active 
            behavior_idx = find(cell2mat(outputdata.radioActive));
            
            % Get the behavior name by subsetting the element on the
            % behavior list
            behavior = outputdata.Behavior_List{behavior_idx};
            
            % Calculate frame
            % Frame is estimated, position change jumps ~ 8 frames each time
            % we will fill the gaps later
            
            myframe = ceil(outputdata.vlc.input.Time/1000 * outputdata.frameRate) - 1;
            
            outputdata.final_data.behavior(myframe) = behavior;
 
            display(outputdata.final_data(myframe, :))
            
            guidata(outputdata.hFigure, outputdata)
            display('updating GUI data')
            
            % Get the things out of the function into base workspace!
            assignin('base','outputdata',outputdata)
            
           % Check if package is available <<<<<< This is nasty!
         %  if(isdir('gramm-master'))
         %   if (mod(myframe, 30) < 5) % to make it approx 1 Hz   
         %   make_ethogram_plot(outputdata)
         %   end
         %  end
            
        end