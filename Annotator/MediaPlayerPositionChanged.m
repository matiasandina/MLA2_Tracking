 function outputdata = MediaPlayerPositionChanged(varargin)
   hFigure = findobj('tag', 'VideoPlay');
   outputdata = guidata(hFigure);
   
   % Get position
   outputdata.mypos = outputdata.vlc.input.Position;
   
   % Get frame
   outputdata.myframe = outputdata.vlc.input.Time;
   
   % If position is changing AND annotate button is 'ON' (value == 1)
   % Annotate
   will_annotate = get(outputdata.hAnnotateButton, 'Value');
  
   if(will_annotate)
   outputdata = Annotate;
   end
   
   end