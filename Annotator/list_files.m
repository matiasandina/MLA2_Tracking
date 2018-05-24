% The idea of this function is to have something that works to list files
% Matlab has too many weird things with dir/patterns/etc...
% It could be slow if calling in a BIG dir and then subsetting
% Otherwise it should work pretty fast

function filenames = list_files(varargin)

% Open input parser
p = inputParser();

% Add possible values
addOptional(p, 'Interactive', true, @islogical)
addOptional(p, 'Dirname', '0', @ischar)
addOptional(p, 'Pattern', {'.'}, @iscell)
addOptional(p, 'FullPath', false, @islogical)


% parse
parse(p, varargin{:});

% retrieve things from parser
Interactive = p.Results.Interactive;
Dirname = p.Results.Dirname;
Pattern = p.Results.Pattern;
FullPath = p.Results.FullPath;


%% Dirname goes first
% If we didn't provide a Dirname, both defaults will hold
% If we provided a Dirname, we will read from there

if (Interactive && string(Dirname) == '0')

    dirname = uigetdir();

else
    
    dirname = Dirname;
    
end


if ~isdir(dirname)
    error('Dirname not valid, check dirname provided is character and exists.')
end

% actually call dir
    d=dir(dirname);
% Remove the dots matlab puts to things
    d=d(~ismember({d.name},{'.','..'}));

    % Get filenames
    % Output as an mx1 cell
    
    filenames = {d.name}';

        
%% Subset by pattern
    
    default_pattern = string(Pattern) == '.';

    if (~default_pattern) % non default case
    
    % join cell patterns separated by the 'or' regular expression
    query_expression = strjoin(Pattern, '|');
    
    %  Subset the patterns
    filenames = filenames(~cellfun(@isempty,regexp(filenames, query_expression)));
    end
    
    % By default we return just the name
    % If you want the full path, call it!
    % it currently works only for 1 folder
    % Recursive = TRUE will be super nice!
    
    if FullPath
    filenames = fullfile(unique({d.folder}), filenames);
    end
end