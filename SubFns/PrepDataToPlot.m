function handles = PrepDataToPlot(handles)
% Polls the front panel controls and determines which channels need to be
% plotted
%
%
% Written by Vladislav Belyy
% Last updated on 11/20/2013

%% Read user parameters from the front panel
% Obtain current plot units

plotUnitStr=get(handles.YScaleMenu,'string'); % Current selection
plotUnitVal=get(handles.YScaleMenu,'value'); % Current selection
% Possible values: 'Tether extension (nm)','nm and rotated',
% 'Force (pN)','Raw data (dimensionless)'
plotUnits = plotUnitStr(plotUnitVal); 


showX = get(handles.ShowX,'value');
showY = get(handles.ShowY,'value');
showTrapX = get(handles.ShowTrapLong,'value');
showTrapY = get(handles.ShowTrapShort, 'value');
fitSteps = get(handles.FitSteps, 'string'); % Values: 'FIT', 'Erase'
fitLine = get(handles.FitLine, 'string'); % Values: 'FIT', 'Erase'

% possible values: 'Choose channels manually'
chooseChannels = get(handles.ChooseChannels, 'string');

PSDselectorString = get(handles.PSD_selector, 'string');
PSDselectorValue = get(handles.PSD_selector, 'value');
% possible values: 'Both PSDs', 'PSD1', 'PSD2'

PSDselector = PSDselectorString(PSDselectorValue);

%possible values: 'Filter/Decimate Data?', 'Raw Data'
filterData = get(handles.FilterData, 'string'); 
if strcmp(filterData,'Filter/Decimate Data?')
    filterData = 0;
else
    filterData = 1;
end

%% If necessary, calculate extension and forces

if strcmp(plotUnits, 'Tether extension (nm)')
    handles = CalcTetherExtension(handles);
elseif strcmp(plotUnits, 'Force (pN)')
    handles = CalcForce(handles);
end


%% Establish visibility of current traces
for i=1:length(handles.allTraces)
    
    visible = 1;
    traceName = handles.allTraces(i).TraceName;
    
    if strcmp(PSDselector, 'PSD1') % do not display PSD2 or piezo trap
        if ~isempty(strfind(traceName, 'PSD2'))
            visible = 0;
        elseif ~isempty(strfind(traceName, 'Piezo'))
            visible = 0;
        end
    elseif strcmp(PSDselector, 'PSD2') % do not display PSD1 or AOD trap
        if ~isempty(strfind(traceName, 'PSD1'))
            visible = 0;
        elseif ~isempty(strfind(traceName, 'AOD'))
            visible = 0;
        end
    end
    
    if ~showX % do not display PSD x-axes
        if ~isempty(strfind(traceName, 'PSD1 X')) || ...
                ~isempty(strfind(traceName, 'PSD2 X'))
            visible = 0;
        end
    end
    if ~showY % do not display PSD y-axes
        if ~isempty(strfind(traceName, 'PSD1 Y')) || ...
                ~isempty(strfind(traceName, 'PSD2 Y'))
            visible = 0;
        end
    end
    
    if ~showTrapX % do not display trap x-axis
        if ~isempty(strfind(traceName, 'Trap X'))
            visible = 0;
        end
    end
    if ~showTrapY % do not display trap y-axis
        if ~isempty(strfind(traceName, 'Trap Y'))
            visible = 0;
        end
    end
    
    if strcmp(plotUnits, 'Tether extension (nm)') % Only display extension
        if isempty(strfind(traceName, '_extn')) && ...
                isempty(strfind(traceName, 'Distance between traps'))
            visible = 0;
        end
    elseif ~isempty(strfind(traceName, '_extn')) % do not display extension
        visible = 0;
    end
    
     if strcmp(plotUnits, 'Force (pN)') % Only display force
        if isempty(strfind(traceName, '_force'))
            visible = 0;
        end
    elseif ~isempty(strfind(traceName, '_force')) % do not display force
        visible = 0;
     end
     
    if strcmp(plotUnits, 'Raw data (dimensionless)') || ...
       strcmp(plotUnits, 'nm and rotated') % Do not display extension
        if ~isempty(strfind(traceName, '_extn')) || ...
                ~isempty(strfind(traceName, '_force')) || ...
                ~isempty(strfind(traceName, 'Distance between traps'))
            visible = 0;
        end
    end
        
    if filterData
        if isempty(strfind(traceName, '_filt'))
            visible = 0;
        end
    else % display unfiltered data
        if ~isempty(strfind(traceName, '_filt'))
            visible = 0;
        end
    end
            
    handles.allTraces(i).Visible = visible;
end


