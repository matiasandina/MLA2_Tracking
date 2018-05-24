 %% Not annotate, basic placeholder to not annotate   
    
    function NotAnnotate(varargin)    
        hFigure = findobj('tag', 'VideoPlay');
        outputdata = guidata(hFigure);
        
        % change value of the orther button to 0
        set(outputdata.hAnnotateButton, 'Value', 0);
    end
            