function startSymphony()
    % Add Symphony to path
    appinfo = matlab.apputil.getInstalledAppInfo();
    for i = 1:numel(appinfo)
        if strncmp(appinfo(i).id, 'Symphony', numel('Symphony'))
            symphonyinfo = appinfo(i);
            addpath(genpath(symphonyinfo.location));
            break;
        end
    end
    
    % Update git repos in Symphony search path
    options = symphonyui.app.Options.getDefault();
    searchPath = options.searchPath;
    paths = strsplit(searchPath, ';');
    for i = 1:numel(paths)
        path = paths{i};
        
        % Find out if the path is in a git repo
        [rc, out] = system(['git -C "' path '" rev-parse']);
        if ~isempty(out) && isempty(strfind(out, 'Not a git repository'))
            warning(out);
        end
        
        % If the path is in a git repo
        if ~rc
            % Get the top-level path of the repo
            [rc, out] = system(['git -C "' path '" rev-parse --show-toplevel']);
            if rc
                warning(['Failed to get top-level git directory: ' out]);
            end
            path = strrep(out, sprintf('\n'), '');
            
            % Update the repo
            status = update(path);
            if ~isempty(status)
                [~, repo] = fileparts(path);
                disp([repo ' contains changes not tracked by the server: ' char(10) status]);
                r = input('Are you sure you want to continue? [y/n]: ', 's');
                if ~strcmp(r, 'y')
                    error('Terminated by user');
                end
            end
        end
        
        addpath(genpath(path));
    end
    
    % Setup lab filename convention
    options.fileDefaultName = @()[datestr(now,'yyyy-mm-dd') '_' getenv('RIG_LETTER')];
    options.save();

    % Start Symphony app
    matlab.apputil.run(symphonyinfo.id);
end

function status = update(path)
    [~, repo] = fileparts(path);
    
    disp(['Fetching and integrating changes for ' repo '...']);
    [rc, out] = system(['git -C "' path '" pull']);
    if rc
        warning(['Failed to pull: ' out]);
    end
    disp('Done.');
    
    disp(['Updating submodules in ' repo '...']);
    [rc, out] = system(['git -C "' path '" submodule foreach --recursive "(git checkout master; git pull)";']);
    if rc
        warning(['Failed to pull submodules: ' out]);
    end
    disp('Done.');
    
    [rc, out] = system(['git -C "' path '" status --porcelain']);
    if rc
        warning(['Failed to get status: ' out]);
    end
    status = out;
end