    
    function outputdata = myRadio(RadioH, EventData)
        outputdata = guidata(RadioH);
        otherRadio = outputdata.radio(outputdata.radio ~= RadioH);
        set(otherRadio, 'Value', 0);
        set(outputdata.hAnnotateButton, 'Value', 0);
        outputdata.Behavior = RadioH.String; %%%% NOT REALLY WORKING!
        sprintf('Switching to...%s', outputdata.Behavior)
        guidata(outputdata.hFigure, outputdata)
        
        display('updating GUI data')
    end 