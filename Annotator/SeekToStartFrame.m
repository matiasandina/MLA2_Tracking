
    function SeekToStartFrame(varargin) 
        % Seek StartFrame of file 
        hFigure = findobj('tag', 'VideoPlay'); 
        outputdata = guidata(hFigure); 
        outputdata.vlc.input.Time = StartFrame; 
    end