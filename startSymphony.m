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
    
    % Setup lab file convention
    options.fileDefaultName = @()[datestr(now,'yyyy-mm-dd') '_' getenv('RIG_LETTER')];
    options.fileCleanupFunction = @(ds)addConversionFactors(ds);
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

function addConversionFactors(documentationService)
    % Do not bother if all devices are not calibrated
    experiment = documentationService.getExperiment();
    devices = experiment.getDevices();
    for i = 1:numel(devices)
        device = devices{i};
        
        if isempty(regexpi(device.name, 'LED', 'once')) && isempty(regexpi(device.name, 'Stage', 'once'))
            continue;
        end
        
        resourceNames = device.getResourceNames();
        if ~any(strcmp('spectrum', resourceNames)) ...
                || ~any(strcmp('ndfAttenuations', resourceNames)) ...
                || ~any(strcmp('fluxFactors', device.getResourceNames()))
            return;
        end
    end
    
    busy = appbox.BusyPresenter('Cleaning Up...', 'Adding isomerization conversion factors.', ...
        'width', appbox.hpix(290/11));
    busy.go();
    deleteBusy = onCleanup(@()delete(busy));
    try
        edu.washington.riekelab.util.addConversionFactors(documentationService.getExperiment());
    catch x
        appbox.MessagePresenter(['Failed to add one or more isomerization conversion factors. See the command ' ...
            'window for more details. You can re-open the file and correct these issues to try again.'], ...
            'Warning').goWaitStop();
        warning(x.getReport());
    end
end