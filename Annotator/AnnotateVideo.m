function AnnotateVideo

    uiwait(msgbox('Chose data folder with Rat metadata to analyze'))
    basedir = uigetdir();

    % get files in dir
d=dir(basedir);

    % Get RatID
    [root_folder, RatID] = fileparts(basedir);

% get rid of the stupid dots matlab adds to dir
d=d(~ismember({d.name},{'.','..'}));

% match the files with timestamp in dir.name
metadata_match = regexpi({d.name}, 'metadata', 'match', 'once');

metadata_idx = find(~cellfun(@isempty, metadata_match));

    metadata_filepath = fullfile(d(metadata_idx).folder, d(metadata_idx).name);
    
    my_metadata = readtable(metadata_filepath);
    
       
    % Save animal name into outputdata
    
    outputdata.basedir = basedir;
    outputdata.RatID = RatID;
    
    % Get the start and end frame for the cuts
    outputdata.startFrame = my_metadata.startFrame;
    outputdata.endFrame = my_metadata.endFrame;
         
    % filepath will be on my_metadata.video_path
    % It might well be that the folder got moved/deleted/watever
    % But the name of the raw_video should be the same!
    % so we try to read it, else we catch to user input
    
    try
       filepath = char(my_metadata.video_path);
       raw_video_name = char(regexp(my_metadata.video_path, 'Raw.+', 'once', 'match'));
       v = VideoReader(filepath);
    catch
      uiwait(msgbox(sprintf('%s Video cannot be located. Please select video folder', raw_video_name)))
      video_basedir = uigetdir();
      filepath = fullfile(video_basedir, raw_video_name);   
      v = VideoReader(filepath);
    end    
    
    % Video path will be kept on handle
    outputdata.filepath = filepath; 
    
    % Get file duration
    outputdata.duration = v.Duration;
    outputdata.frameRate = v.FrameRate;
    delete(v)
    
    total_frames = ceil(outputdata.duration * outputdata.frameRate) - 1;
    
        
    %% Make some variables
    
     outputdata.final_data.frameID = (1:total_frames)';
     outputdata.final_data.behavior = strings(total_frames, 1);
     
     % change format to table
     outputdata.final_data = struct2table(outputdata.final_data);
    
   
    %% Build the Figure/GUI


    % Create figure to receive activex 
    outputdata.hFigure = figure('position', [50 50 1300 560], ...
                             'menubar', 'none', 'numbertitle', 'off', ...
                             'name', ['Video: ' filepath],...
                             'tag', 'VideoPlay', 'resize', 'on'); 
                         
    % Create play/pause and seek to 0 button 
    outputdata.hTogglePlayButton = uicontrol(outputdata.hFigure, ...
                                          'position', [0 540 80 21], ...
                                          'string', 'play/pause', 'callback',...
                                          @TogglePlayPause); 
    outputdata.hSeekToZeroButton = uicontrol(outputdata.hFigure, ...
                                          'position', [81 540 80 21], ...
                                          'string', 'begining', 'callback',...
                                          @SeekToZero); 
    
    outputdata.hGoToStartFrameButton = uicontrol(outputdata.hFigure, ...
                                          'position', [161 540 80 21], ...
                                          'string', 'StartFrame', 'callback',...
                                          @SeekToStartFrame);   
    
    outputdata.hGoToEndFrameButton = uicontrol(outputdata.hFigure, ...
                                          'position', [241 540 80 21], ...
                                          'string', 'EndFrame', 'callback',...
                                          @SeekToEndFrame); 
                                      
                                      
%% Annotate button

    outputdata.hAnnotateButton = uicontrol(outputdata.hFigure, ...
                                          'Style', 'radiobutton', ...
                                          'position', [980 320 100 41], ...
                                          'String', 'Annotate', 'callback',...
                                          {@Annotate, outputdata});
   outputdata.hNotAnnotateButton = uicontrol(outputdata.hFigure, ...
                                       'Style', 'radiobutton', ...
                                       'position', [1100 320 100 41], ...
                                       'String', 'Not-Annotate', ...
                                       'Value', 1, ...
                                       'callback', @NotAnnotate);

                                      
                                      
%% Make radio buttons for ethogram

outputdata.radio(1) = uicontrol('Style', 'radiobutton', ...
                           'Callback', @myRadio, ...
                           'Units',    'pixels', ...
                           'Position', [980, 500, 80, 22], ...
                           'String',   'Non-specific', ...
                           'Value',    0);
outputdata.radio(2) = uicontrol('Style', 'radiobutton', ...
                           'Callback', @myRadio, ...
                           'Units',    'pixels', ...
                           'Position', [980, 480, 80, 22], ...
                           'String',   'Rearing', ...
                           'Value',    0);

outputdata.radio(3) = uicontrol('Style', 'radiobutton', ...
                           'Callback', @myRadio, ...
                           'Units',    'pixels', ...
                           'Position', [980, 460, 80, 22], ...
                           'String',   'Snif', ...
                           'Value',    0);

outputdata.radio(4) = uicontrol('Style', 'radiobutton', ...
                           'Callback', @myRadio, ...
                           'Units',    'pixels', ...
                           'Position', [980, 440, 80, 22], ...
                           'String',   'Retrieving', ...
                           'Value',    0);                       

outputdata.radio(5) = uicontrol('Style', 'radiobutton', ...
                           'Callback', @myRadio, ...
                           'Units',    'pixels', ...
                           'Position', [1100, 500, 80, 22], ...
                           'String',   'Nesting', ...
                           'Value',    0); 

outputdata.radio(6) = uicontrol('Style', 'radiobutton', ...
                           'Callback', @myRadio, ...
                           'Units',    'pixels', ...
                           'Position', [1100, 480, 80, 22], ...
                           'String',   'Hover-over', ...
                           'Value',    0); 

outputdata.radio(7) = uicontrol('Style', 'radiobutton', ...
                           'Callback', @myRadio, ...
                           'Units',    'pixels', ...
                           'Position', [1100, 460, 80, 22], ...
                           'String',   'Self-Groom', ...
                           'Value',    0);                        
                       
% Maybe here define the behavior list ?
outputdata.Behavior_List = get(outputdata.radio,'String');
                      
%% Plot
% this is weird with the closing fun, it doesn't delete the axis for some
% reason
%   p1 = axes('Units', 'pixels', 'Position',[980 20 200 300]);
                       
%% Activex control for VLC player
                    
    % Create activex control 
    outputdata.vlc = actxcontrol('VideoLAN.VLCPlugin.2', [0 0 960 540], outputdata.hFigure); 
    % Format filepath so that VLC can use it
    

    % Read into vlc
    
    filepath = ['file://localhost/' filepath]; 
   
 
    % Add file to playlist 
    outputdata.vlc.playlist.add(filepath); 
    
    % Play file 
    outputdata.vlc.playlist.play(); 
    % Deinterlace 
    outputdata.vlc.video.deinterlace.enable('x'); 
    % Go back to begining of file 
    outputdata.vlc.input.time = 0; 
    
   
   % Register an event to trigger when video is being played regularly 
   outputdata.vlc.registerevent({'MediaPlayerTimeChanged', @MediaPlayerTimeChanged}); 

   % Position changed
   outputdata.vlc.registerevent({'MediaPlayerPositionChanged', @MediaPlayerPositionChanged});
   
   %% Save output on closing

   outputdata.fields_to_remove = {'vlc', 'radio', 'hFigure', ...
                                  'hNotAnnotateButton', 'hAnnotateButton', ...
                                  'hGoToEndFrameButton', 'hGoToStartFrameButton', ...
                                  'hSeekToZeroButton', 'hTogglePlayButton', ...
                                  'fields_to_remove'};
   
   % Save handles 
   guidata(outputdata.hFigure, outputdata); 
       
   set(outputdata.hFigure, 'CloseRequestFcn', @closing_fun)
   
end