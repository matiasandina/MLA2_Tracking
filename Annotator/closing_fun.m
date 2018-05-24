    function closing_fun(varargin)
    
    % nasty fucking bullshit that still hunts you to death
    % thank you for scoping bullshit all around matlab! 
    
    my_inputs = evalin('base', 'outputdata');

    % Get filepath
    filepath = my_inputs.RatID;
    
    filepath = fullfile('data', strcat(filepath,'_annotated_behavior', '.mat'));
    
    allPlots = findall(0, 'Type', 'figure');
        
    please.save = MFquestdlg ( [ 0.6 , 0.1 ] , 'Do you want to save the data' , 'Save?');
    
    switch please.save
        case 'Yes'
    
    % Remove all the figure stuff
    fields_to_remove = my_inputs.fields_to_remove;
    my_inputs = rmfield(my_inputs, fields_to_remove);        
            
    % Close will throw recursive warning, use delete
   % delete(allPlots) >>> deletes only the video part, not the rest, hangs
   % MATLAB 
    
   save(filepath, 'my_inputs')
   
   sprintf('Data was saved!')
    
     close all

        case 'No'
   
   sprintf('Data was not saved to file (But it is on the workspace!!!)')
   
   close all

   % Close will throw recursive warning, use delete
   % delete(allPlots) >>> deletes only the video part, not the rest, hangs
   % MATLAB
        otherwise      
   % do nothing 
    end