    function SeekToEndFrame(EndFrame) 
        % Seek to EndFrame of file 
        hFigure = findobj('tag', 'VideoPlay'); 
        outputdata = guidata(hFigure); 
        outputdata.vlc.input.Time = EndFrame;
     end