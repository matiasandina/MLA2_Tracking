    function TogglePlayPause(varargin) 
        % Toggle Play/Pause 
        hFigure = findobj('tag', 'VideoPlay'); 
        outputdata = guidata(hFigure); 
        outputdata.vlc.playlist.togglePause(); 
    end