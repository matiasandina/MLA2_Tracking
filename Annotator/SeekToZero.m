    function SeekToZero(varargin) 
        % Seek to begining of file 
        hFigure = findobj('tag', 'VideoPlay'); 
        outputdata = guidata(hFigure); 
        outputdata.vlc.input.Time = 0; 
    end
        