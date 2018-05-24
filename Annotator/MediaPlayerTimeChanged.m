%% Display running time in application title 

    function MediaPlayerTimeChanged(varargin) 
   hFigure = findobj('tag', 'VideoPlay'); 
   outputdata = guidata(hFigure); 
    
   myframe = outputdata.vlc.input.Time;
   
   set(hFigure, 'name', [outputdata.filepath ' ; ' num2str(myframe/1000) ' sec.']);

    end