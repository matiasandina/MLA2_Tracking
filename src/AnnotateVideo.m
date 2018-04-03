function handles = AnnotateVideo(filepath) 
    
    % Get some initial data from the video
    filepath = fullfile(filepath);
    
    % Get file duration
    
    v = VideoReader(filepath);
    handles.duration = v.Duration;
    handles.frameRate = v.FrameRate;
    delete(v)
    
    total_frames = ceil(handles.duration * handles.frameRate) - 1;
    
    
    %% Make some variables
    
     handles.final_data.frameID = (1:total_frames)';
     handles.final_data.behavior = strings(total_frames, 1);
     
     % change format to table
     handles.final_data = struct2table(handles.final_data);
    
    % Place Holder for behavior
    
    
    %% Build the Figure/GUI

    % Video will be kept on handle
    handles.filepath = filepath; 
    % Create figure to receive activex 
    handles.hFigure = figure('position', [50 50 1300 560], ...
                             'menubar', 'none', 'numbertitle', 'off', ...
                             'name', ['Video: ' filepath],...
                             'tag', 'VideoPlay', 'resize', 'on'); 
                         
    % Create play/pause and seek to 0 button 
    handles.hTogglePlayButton = uicontrol(handles.hFigure, ...
                                          'position', [0 540 80 21], ...
                                          'string', 'play/pause', 'callback',...
                                          @TogglePlayPause); 
    handles.hSeekToZeroButton = uicontrol(handles.hFigure, ...
                                          'position', [81 540 80 21], ...
                                          'string', 'begining', 'callback',...
                                          @SeekToZero); 
    
    handles.hGoToStartFrameButton = uicontrol(handles.hFigure, ...
                                          'position', [161 540 80 21], ...
                                          'string', 'StartFrame', 'callback',...
                                          @SeekToStartFrame);   
    
    handles.hGoToEndFrameButton = uicontrol(handles.hFigure, ...
                                          'position', [241 540 80 21], ...
                                          'string', 'EndFrame', 'callback',...
                                          @SeekToEndFrame);                                        

%% Annotate button

    handles.hAnnotateButton = uicontrol(handles.hFigure, ...
                                          'Style', 'radiobutton', ...
                                          'position', [980 320 100 41], ...
                                          'String', 'Annotate', 'callback',...
                                          @Annotate);
   handles.hNotAnnotateButton = uicontrol(handles.hFigure, ...
                                       'Style', 'radiobutton', ...
                                       'position', [1100 320 100 41], ...
                                       'String', 'Not-Annotate', ...
                                       'Value', 1, ...
                                       'callback', @NotAnnotate);

                                      
                                      
%% Make radio buttons for ethogram
                                      
handles.radio(1) = uicontrol('Style', 'radiobutton', ...
                           'Callback', @myRadio, ...
                           'Units',    'pixels', ...
                           'Position', [980, 500, 80, 22], ...
                           'String',   'Non-specific', ...
                           'Value',    0);
handles.radio(2) = uicontrol('Style', 'radiobutton', ...
                           'Callback', @myRadio, ...
                           'Units',    'pixels', ...
                           'Position', [980, 480, 80, 22], ...
                           'String',   'Rearing', ...
                           'Value',    0);

handles.radio(3) = uicontrol('Style', 'radiobutton', ...
                           'Callback', @myRadio, ...
                           'Units',    'pixels', ...
                           'Position', [980, 460, 80, 22], ...
                           'String',   'Snif', ...
                           'Value',    0);

handles.radio(4) = uicontrol('Style', 'radiobutton', ...
                           'Callback', @myRadio, ...
                           'Units',    'pixels', ...
                           'Position', [980, 440, 80, 22], ...
                           'String',   'Retrieving', ...
                           'Value',    0);                       

handles.radio(5) = uicontrol('Style', 'radiobutton', ...
                           'Callback', @myRadio, ...
                           'Units',    'pixels', ...
                           'Position', [1100, 500, 80, 22], ...
                           'String',   'Self-Groom', ...
                           'Value',    0); 


%% Activex control for VLC player
                    
    % Create activex control 
    handles.vlc = actxcontrol('VideoLAN.VLCPlugin.2', [0 0 960 540], handles.hFigure); 
    % Format filepath so that VLC can use it
    

    % Read into vlc
    
    filepath = ['file://localhost/' filepath]; 
   
 
    % Add file to playlist 
    handles.vlc.playlist.add(filepath); 
    
    % Play file 
    handles.vlc.playlist.play(); 
    % Deinterlace 
    handles.vlc.video.deinterlace.enable('x'); 
    % Go back to begining of file 
    handles.vlc.input.time = 0; 
    
   
   % Register an event to trigger when video is being played regularly 
   handles.vlc.registerevent({'MediaPlayerTimeChanged', @MediaPlayerTimeChanged}); 

   % Position changed
   handles.vlc.registerevent({'MediaPlayerPositionChanged', @MediaPlayerPositionChanged});
    
   % Save handles 
   guidata(handles.hFigure, handles); 

    
%% Helper functions and button callbacks    
    

   function MediaPlayerPositionChanged(varargin)
   hFigure = findobj('tag', 'VideoPlay');
   handles = guidata(hFigure);
   
   % Get position
   handles.mypos = handles.vlc.input.Position;
   
   % Get frame
   handles.myframe = handles.vlc.input.Time;
   
   % If position is changing AND annotate button is 'ON' (value == 1)
   % Annotate
   will_annotate = get(handles.hAnnotateButton, 'Value');
  
   if(will_annotate)
   Annotate
   end
   
   end

%% Display running time in application title 

    function MediaPlayerTimeChanged(varargin) 
   hFigure = findobj('tag', 'VideoPlay'); 
   handles = guidata(hFigure); 
    
   myframe = handles.vlc.input.Time;
   
   set(hFigure, 'name', [handles.filepath ' ; ' num2str(myframe/1000) ' sec.']);

    end
 
%% Annotate: MAIN 'Looping' Function
% called when position is changed and annotate button

        function Annotate(varargin)
            
            hFigure = findobj('tag', 'VideoPlay');
            handles = guidata(hFigure);
            
            % change value of the orther button to 0
            set(handles.hNotAnnotateButton, 'Value', 0);
                    
            mypos = handles.vlc.input.Position;
            behavior = handles.Behavior;
            
            % Calculate frame
            myframe = ceil(handles.vlc.input.Time/1000 * handles.frameRate) - 1;
            
            handles.final_data.behavior(myframe) = behavior;
                        
            display(handles.final_data(myframe, :))

            guidata(handles.hFigure, handles)
        end

 %% Not annotate, basic placeholder to not annotate   
    
    function NotAnnotate(varargin)    
        hFigure = findobj('tag', 'VideoPlay');
        handles = guidata(hFigure);
        % change value of the orther button to 0
        set(handles.hAnnotateButton, 'Value', 0);
    end
            
    
    function TogglePlayPause(varargin) 
        % Toggle Play/Pause 
        hFigure = findobj('tag', 'VideoPlay'); 
        handles = guidata(hFigure); 
        handles.vlc.playlist.togglePause(); 
    end
    
    function SeekToZero(varargin) 
        % Seek to begining of file 
        hFigure = findobj('tag', 'VideoPlay'); 
        handles = guidata(hFigure); 
        handles.vlc.input.Time = 0; 
    end
        
    function SeekToStartFrame(varargin) 
        % Seek StartFrame of file 
        hFigure = findobj('tag', 'VideoPlay'); 
        handles = guidata(hFigure); 
        handles.vlc.input.Time = StartFrame; 
    end
        
    function SeekToEndFrame(varargin) 
        % Seek to EndFrame of file 
        hFigure = findobj('tag', 'VideoPlay'); 
        handles = guidata(hFigure); 
        handles.vlc.input.Time = EndFrame;
     end
    
    function myRadio(RadioH, EventData)
        handles = guidata(RadioH);
        otherRadio = handles.radio(handles.radio ~= RadioH);
        set(otherRadio, 'Value', 0);
        set(handles.hAnnotateButton, 'Value', 0);
        handles.Behavior = RadioH.String;
        sprintf('Switching to...%s', handles.Behavior)
        guidata(handles.hFigure, handles)
    end 
        

% End of global function
 

    end