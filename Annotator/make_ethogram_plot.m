function make_ethogram_plot(datastructure)

fig = findobj(0, 'Name', 'My_gramm_ethogram');

if(isempty(fig))
   % If the figure doesn't exists create it
    fig = figure('Name', 'My_gramm_ethogram');
    p1 = uipanel('Parent',fig,'BackgroundColor',[1 1 1],'BorderType','none');
    g = gramm('x', datastructure.final_data.frameID, 'color', categorical(datastructure.final_data.behavior));
    g.geom_raster();
    g.set_parent(p1);
    g.draw()
    
else
    
    % delete old
    p1 = fig.Children;
    delete(p1)
    % get it again
    p1 = uipanel('Parent',fig,'BackgroundColor',[1 1 1],'BorderType','none');
    g = gramm('x', datastructure.final_data.frameID, 'color', categorical(datastructure.final_data.behavior));
    g.geom_raster();
    g.set_parent(p1);
    g.draw()

end


% If this is called from the gui
% we want to have the gui being the current active grafics

gui_VideoPlay = findobj(0, 'Tag', 'VideoPlay');

% giving control didn't work very well either
 if ~isempty(gui_VideoPlay)
     % Give back control to the video player
     figure(gui_VideoPlay)
 end

end