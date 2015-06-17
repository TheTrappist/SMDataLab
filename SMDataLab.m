function varargout = SMDataLab(varargin)
% m-file file for SMDataLab.fig
%
%   SMDataLab is a program that displays many types of time-domain data
%   (such as displacement traces recorded in fluorescence tracking or
%   optical tweezers experiments) and allows the user to process the data,
%   fit it to arbitrary functions, and save the processed results.
%
%   Written by Vladislav Belyy, Yildiz Lab, UC Berkeley
%   
%
% See also: GUIDE, GUIDATA, GUIHANDLES


% Last Modified by GUIDE v2.5 21-Oct-2014 16:13:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SMDataLab_OpeningFcn, ...
    'gui_OutputFcn',  @SMDataLab_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SMDataLab is made visible.
function SMDataLab_OpeningFcn(hObject, eventdata, handles, varargin) %#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SMDataLab (see VARARGIN)

setappdata(0,'UseNativeSystemDialogs',false)

handles.figureHandle = hObject;
MainPath=pwd;
SubFunctions=strcat(MainPath,'\SubFns');
SubGUIs = strcat(MainPath,'\SubGUIs');
addpath(SubFunctions)
addpath(SubGUIs)
handles.currentPath='C:\';
handles.display.filtered = 0;

% Structure to hold all traces that can be plotted
handles.allTraces = struct('TraceName', '','DataRaw',[],...
    'Data_nm', [], 'StartTime', 0, 'SamplingRate', 0, 'Visible', 1); 
% Trace names can contain the following reserved suffixes:
% '_filt': filtered trace
% '_force': scaled to piconewtons
% '_extn': extension
% '_step': step fit
% '_lineFit': line fit


handles.recordingType = 'Fixed trap'; % other options: 'Force clamp',
                                    %'Force calibration', 'PSD calibration'
                       
% Calibrations
handles.springConsts = [0.05 0.05 0.05 0.05]; % Trap spring constants
handles.trackAngle = 0; % in radians
handles.samplingRate = 20000; % in Hz
handles.PSDoffsetFit = 'No fit performed yet'; % store fit to offset trace
handles.trapOffsets = [0;0]; % x and y separation between trap centers, nm
handles.trapStiffRotated = [0;0]; % trap stiffness along the 
                % tether coordinate for AOD trap and piezo trap
                

set(handles.FilterData,'string','Filter/Decimate Data?')

%handles.corrFig = 0; % Handle to analysis figure

handles.currLegend = {};

% Initialize primary axes
set(handles.axes1,'Ygrid','on')
axes(handles.axes1); %#ok<MAXES>
plot(0,0)
hold on 
title('No data selected')
hold off


% Choose default command line output for SMDataLab
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(~, eventdata, handles)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed


key = eventdata.Key; % determine which key was pressed

% Determine if the user is trying to add or remove steps manually:
manualStepsButton = get(handles.ManualStepFitting, 'String');
manuallyAdjust = strcmp(manualStepsButton, 'Exit');

if manuallyAdjust
       
    if strcmp(key, 't') % toggle between add/delete
        currentString = get(handles.AddDeleteStep, 'String');

        if strcmp(currentString, 'Add')
            set(handles.AddDeleteStep, 'String', 'Delete');
        else
            set(handles.AddDeleteStep, 'String', 'Add');
        end
    end
end



% --- Executes on button press in NewParameters.
function NewParameters_Callback(hObject, eventdata, handles) %#ok

handles = ResetStepFitter(handles);

% Prompt user for new conversion parameters

handles = GetNewConversionParams(hObject, handles);

if length(handles.rawPSD1Data_X) > 1 % Only plot data if some data file
                                        % is already loaded
    
    % Rotate and convert raw PSD1 signals: creates handles.PSD1Data_Long,
    % PSD1Data_Short, and handles.t
    handles = BuildCurrentPSDData(hObject, handles);
    
    keepLimits = 1; % keep the limits
    handles = PlotData(hObject, handles, keepLimits);
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in LoadFile.
function LoadFile_Callback(hObject, eventdata, handles) %#ok

% Ask user to choose file to display
pathcat = get(handles.FilePath,'string');
[filename, path, filterindex] = uigetfile({'*.ytd;*.bin;*.mat', ...
    'Trap data files (*.bin, *.ytd, or *.mat)'}, ...
    'Select a trap data file', pathcat); %#ok

if filename ~= 0 % user selected a name and didn't hit cancel
    dataFile = [path, filename];
    handles = loadDataFile(handles, dataFile);
    keepLimits = 0; % reset Y-limits
    handles = PlotData(hObject, handles, keepLimits); % Plot the data
end
    
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in RePlot.
function RePlot_Callback(hObject, eventdata, handles) %#ok

keepLimits = 0; % Reset limits
handles = PlotData(hObject, handles, keepLimits); % Re-plot data
% Save the handles structure.
guidata(hObject,handles)

% --- Executes on selection change in LinesOrDots. 
function LinesOrDots_Callback(hObject, eventdata, handles) %#ok

keepLimits = 2; % keep previous limits strictly
handles = PlotData(hObject, handles, keepLimits); %Plot data
% Save the handles structure.
guidata(hObject,handles)

% --- Executes on selection change in YScaleMenu.
function YScaleMenu_Callback(hObject, eventdata, handles) %#ok


contents = get(hObject,'String');
currSelection = contents{get(hObject,'Value')};

switch currSelection;
    case 'Tether extension (nm)'
        set(handles.GridDiv, 'String', '8 nm');
    case 'nm and rotated'
        set(handles.GridDiv, 'String', '8 nm');
    case 'Force (pN)'
        set(handles.GridDiv, 'String', '0.5 pN');
    otherwise
        set(handles.GridDiv, 'String', '0.01');
end

keepLimits = 0; % do not keep limits
handles = PlotData(hObject, handles, keepLimits); %Plot data
% Save the handles structure.
guidata(hObject,handles)



% --- Executes on button press in newSpringConstButton.
function newSpringConstButton_Callback(hObject, eventdata, handles) %#ok

% Ask the user for new Kx1 and Ky1:
parastr=inputdlg({'Kx' 'Ky'}, ...
    'Obtaining the Trap Stiffness parameters',1,{'0.05' '0.05'});

if length(parastr) == 2 % user successfully provided two parameters
    
    for i=1:2
        
        paras(i)=str2double(parastr(i)); %#ok
        
    end
    
    set(handles.Kx1,'string',num2str(paras(1)));
    set(handles.Ky1,'string',num2str(paras(2)));
    
    handles.KX = paras(1);
    handles.KY = paras(2);
    
    keepLimits = 1; % keep previous limits
    handles = PlotData(hObject, handles, keepLimits); %Plot data
    
end

% Save the handles structure.
guidata(hObject,handles)


% --- Executes on button press in ZoomOut.
function ZoomOut_Callback(hObject, eventdata, handles) %#ok

axes(handles.axes1) %#ok<MAXES>
pan off
zoom(0.5)

zoom on
legend(handles.currLegend{1}, handles.currLegend{2}, ...
    'Interpreter', 'none');

% --- Executes on button press in Pan.
function Pan_Callback(hObject, eventdata, handles) %#ok

axes(handles.axes1) %#ok<MAXES>
panOrZoom=get(handles.Pan,'string');

panOrZoom=panOrZoom(1,:);

if strcmp(panOrZoom, 'Pan')

    zoom off
    pan on

    set(handles.Pan,'string','Zoom');

elseif strcmp(panOrZoom, 'Zoom')

    zoom on

    pan off

    set(handles.Pan,'string','Pan')

end
legend(handles.currLegend{1}, handles.currLegend{2}, ...
    'Interpreter', 'none');


% --- Executes on button press in SaveCurrentView.
function SaveCurrentView_Callback(hObject, eventdata, handles) %#ok
% Creates an export figure containing a copy of the primary axes

ExportFig = figure('visible','off');
newax = copyobj(handles.axes1, ExportFig);
set(newax, 'units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);
set(ExportFig, 'visible', 'on')



% --- Executes on button press in SaveFile.
function SaveFile_Callback(hObject, eventdata, handles) %#ok
% Saves whatever is currently visible on the main plot as a space-delimited
% file, with the first column storing time in seconds and the remaining
% columns storing whatever else is currently plotted in whatever units it
% is plotted. This info is not saved anywhere in the file, so the user
% should be careful to note the units either in the file name or in their
% lab notebook

currFileName = get(handles.FileName, 'String');
fileMask = [handles.currentPath, '*.txt'];

[~, ~, ext] = fileparts(currFileName);

% Add any additional information to the file name:
addDetails = '_TXYdata.txt';

proposedFileName = strrep(currFileName, ext, addDetails);

% Prompt user for save file name and location
[file,path] = uiputfile(fileMask,'Choose location of new data file', ...
    proposedFileName);

% Create the final file name after the user has had the option to modify it
finalFileName = strcat(path, file);

% Get the data currently plotted on axes1:
children = get(handles.axes1, 'Children');
x = get(children, 'Xdata');
y = get(children, 'Ydata');
dataNames = get(children, 'DisplayName');

% Generate data matrix, with the first column being time and the remaining
% columns being whatever else is currently plotted on the main graph:
M = x{1,1}';
lengthM = length(M);
i = 1;
while length(y{i,1}) == lengthM
    M = [M, y{i,1}']; %#ok<AGROW>
    i = i+1;
end

ncols = length(dataNames)-1; % number of data columns in file
fid = fopen(finalFileName, 'w');
fprintf(fid, '%s', 'Time(sec)');
for col=1:ncols
    fprintf(fid, '\t%s', dataNames{col});
end
fprintf(fid, '\n');
fclose(fid);


% Write the data matrix to file with spaces as delimiters:
dlmwrite(finalFileName, M, '-append', 'delimiter', '\t');

disp('New file created successfully!');

% Save the handles structure.
guidata(hObject,handles)



% --- Executes on button press in GridLines.
function GridLines_Callback(hObject, eventdata, handles)%#ok

Option = get(handles.GridLines,'string');

switch Option

    case 'Add Grid Lines'
        
        handles.display.gridLines = 1;
        set(handles.GridLines,'string','Remove GridLines')

    case 'Remove GridLines'
    
        handles.display.gridLines = 0;
        set(handles.GridLines,'string','Add Grid Lines')

end

keepLimits = 2; % Keep the old limits strictly
handles = PlotData(hObject, handles, keepLimits); % Plot new data

% Save the handles structure.
guidata(hObject,handles)


% --- Executes on button press in DisplayStalls.
function DisplayStalls_Callback(hObject, eventdata, handles) 




% --- Executes on button press in FilterData.
function FilterData_Callback(hObject, eventdata, handles) %#ok

DisplayType=get(handles.FilterData,'string');

if strcmp(DisplayType,'Filter/Decimate Data?') % Filter data

    handles = FilterData(hObject, handles);

    set(handles.FilterData,'string','Raw Data?')
    handles.display.filtered = 1;

else % Display raw data
    
    set(handles.FilterData,'string','Filter/Decimate Data?')
    handles.display.filtered = 0;
end

handles = ResetStepFitter(handles);

keepLimits = 2; % Keep the old limits strictly
handles = PlotData(hObject, handles, keepLimits); % Plot new data

% Save the handles structure.
guidata(hObject,handles)

% --- Executes on selection change in Recording_Type.
function Recording_Type_Callback(hObject, eventdata, handles) %#ok
% Hints: contents = get(hObject,'String') returns Recording_Type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Recording_Type

contents = get(hObject,'String');
currentSel = contents{get(hObject,'Value')};

handles.recordingType = currentSel;

keepLimits = 0; % Reset limits
handles = PlotData(hObject, handles, keepLimits); % Plot new data

% Save the handles structure.
guidata(hObject,handles)



% --- Executes on button press in Load_Previous.
function Load_Previous_Callback(hObject, eventdata, handles) %#ok
% Loads the previous PSDsignals file in the current directory

path = get(handles.FilePath, 'string');
file = get(handles.FileName, 'string');

[~, ~, extension]= fileparts(file); 
if strcmp(extension, '.bin')
        filenameTemplate = [path, '*.bin'];
elseif strcmp(extension, '.ytd')
        filenameTemplate = [path, '*.ytd'];
end

% Obtain a list of all PSDsignals.txt files in the current directory

dataFilesStruct = dir(filenameTemplate);
% Convert the structure to cells 
fileNames = cell(length(dataFilesStruct), 1);
for i = 1:length(fileNames)
    fileNames(i) = cellstr(dataFilesStruct(i).name);
end

% Find index of the current file
currentIndex = find(strcmp(file, fileNames));
newIndex = currentIndex - 1;

% Do not allow the array to exceed bounds
if newIndex > 0
    newFilename = char(fileNames(newIndex));
    % Load the new data file
    dataFile = [path, newFilename];
    handles = loadDataFile(handles, dataFile);
        
    keepLimits = 0; % reset Y-limits
    handles = PlotData(hObject, handles, keepLimits); % Plot the data
else
    disp('You''ve reached the beginning of the directory');
end
       
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in OpenNext.
function OpenNext_Callback(hObject, eventdata, handles) %#ok

path = get(handles.FilePath, 'string');
file = get(handles.FileName, 'string');

[~, ~, extension]= fileparts(file); 
if strcmp(extension, '.bin')
        filenameTemplate = [path, '*.bin'];
elseif strcmp(extension, '.ytd')
        filenameTemplate = [path, '*.ytd'];
end


% Obtain a list of all PSDsignals.txt files in the current directory

dataFilesStruct = dir(filenameTemplate);
% Convert the structure to cells 
fileNames = cell(length(dataFilesStruct), 1);
for i = 1:length(fileNames)
    fileNames(i) = cellstr(dataFilesStruct(i).name);
end

% Find index of the current file
currentIndex = find(strcmp(file, fileNames));
newIndex = currentIndex + 1;

% Do not allow the array to exceed bounds
if newIndex <= length(fileNames)
    newFilename = char(fileNames(newIndex));
    % Load the new data file
    dataFile = [path, newFilename];
    handles = loadDataFile(handles, dataFile);
    
    keepLimits = 0; % reset Y-limits
    handles = PlotData(hObject, handles, keepLimits); % Plot the data
else
    disp('You''ve reached the end of the directory');
end
       
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in ShowX.
function ShowX_Callback(hObject, eventdata, handles) %#ok

keepLimits = 1; % keep Y-limits
handles = PlotData(hObject, handles, keepLimits); % Re-plot data
% Save the handles structure.
guidata(hObject,handles)


% --- Executes on button press in ShowY.
function ShowY_Callback(hObject, ~, handles)

keepLimits = 2; % keep Y-limits strictly
handles = PlotData(hObject, handles, keepLimits); % Re-plot data
% Save the handles structure.
guidata(hObject,handles)

function GridDiv_Callback(hObject, eventdata, handles) %#ok
% Hints: get(hObject,'String') returns contents of GridDiv as text
%        str2double(get(hObject,'String')) returns contents of GridDiv as a double

keepLimits = 2; % keep Y-limits strictly
handles = PlotData(hObject, handles, keepLimits); % Re-plot data
% Save the handles structure.
guidata(hObject,handles)


% --- Executes on button press in ShowTrapLong.
function ShowTrapLong_Callback(hObject, ~, handles)

showLong=get(hObject,'Value');

if showLong
    handles.display.trapPosLong = 1;
else
    handles.display.trapPosLong = 0;
end

keepLimits = 2; % Keep the old limits strictly
handles = PlotData(hObject, handles, keepLimits); % Plot new data

% Save the handles structure.
guidata(hObject,handles)


% --- Executes on button press in ShowTrapShort.
function ShowTrapShort_Callback(hObject, ~, handles)
% Hint: get(hObject,'Value') returns toggle state of ShowTrapShort

showShort=get(hObject,'Value');

if showShort
    handles.display.trapPosShort = 1;
else
    handles.display.trapPosShort = 0;
end

keepLimits = 2; % Keep the old limits strictly
handles = PlotData(hObject, handles, keepLimits); % Plot new data

% Save the handles structure.
guidata(hObject,handles)


% --- Executes on button press in PrintFilenames.
function PrintFilenames_Callback(~, ~, handles)

path = get(handles.FilePath, 'string');
fileNames = ListFileNames(path);
disp(fileNames);



% --- Executes on button press in PlotFExtcurve.
function PlotFExtcurve_Callback(hObject, ~, handles)

% Calculate force if extension if not already calculated
handles = CalcTetherExtension(handles);
handles = CalcForce(handles);

extn = getDataFromTrace(handles, 'Long axis_extn');
force = getDataFromTrace(handles, 'Tether_force');

% Plot force-extension
figure
hold on
[~, fileName, ext] = fileparts(handles.currentPath);
plotTitle = strcat(fileName, ext);
title(plotTitle, 'Interpreter', 'none')
xlabel('Tether extension (nm)')
ylabel('Force (pN)')
plot(extn, force)
hold off

% Save the handles structure.
guidata(hObject, handles)

% --- Executes on button press in ChooseChannels.
function ChooseChannels_Callback(hObject, ~, handles)

keepLimits = 2; % Keep the old limits strictly
handles = PlotData(hObject, handles, keepLimits); % Plot new data
% Save the handles structure.
guidata(hObject,handles)

% --- Executes on selection change in PSD_selector.
function PSD_selector_Callback(hObject, ~, handles)

keepLimits = 0; % get new limits
handles = PlotData(hObject, handles, keepLimits); % Re-plot data
% Save the handles structure.
guidata(hObject,handles)



%%%%%% Centering-related callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ReCenterTraces_SelectionChangeFcn(hObject, eventdata, handles) %#ok

% determine new centering parameters
handles = DetermineCentering (hObject, handles);

keepLimits = 0; % reset Y-limits
handles = PlotData(hObject, handles, keepLimits); % Re-plot data

% Save the handles structure.
guidata(hObject,handles)

function XOffset_Callback(hObject, eventdata, handles) %#ok

% determine new centering parameters
handles = DetermineCentering (hObject, handles);

keepLimits = 0; % reset Y-limits
handles = PlotData(hObject, handles, keepLimits); % Re-plot data

% Save the handles structure.
guidata(hObject,handles)

function YOffset_Callback(hObject, eventdata, handles) %#ok

% determine new centering parameters
handles = DetermineCentering (hObject, handles);

keepLimits = 0; % reset Y-limits
handles = PlotData(hObject, handles, keepLimits); % Re-plot data

% Save the handles structure.
guidata(hObject,handles)


%%% Offset callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in CorrectPSDforAODtrap.
function CorrectPSDforAODtrap_Callback(hObject, ~, handles)
% just re-load the file using new correction setting
filename = get(handles.FileName,'string');
path = get(handles.FilePath,'string');

[~, ~, extension]= fileparts(filename);
if strcmp(extension, '.bin')
    handles = LoadNewBinDataFile(hObject, handles, path, filename);
elseif strcmp(extension, '.ytd')
    handles = LoadNewYTDdataFile(hObject, handles, path, filename);
elseif strcmp(extension, '.mat') % Mat-file from Bustamante trap
    handles = LoadBustamanteMatFile(hObject, handles, path, filename);
end

keepLimits = 0; % reset Y-limits
handles = PlotData(hObject, handles, keepLimits); % Plot the data
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in ApplyPSDOffset.
function ApplyPSDOffset_Callback(hObject, eventdata, handles)



% --- Executes on button press in DefineOffset.
function DefineOffset_Callback(hObject, ~, handles)

% Calculate force if extension if not already calculated
handles = CalcTetherExtension(handles);

extn = getDataFromTrace(handles, 'Long axis_extn');
dist = getDataFromTrace(handles, 'Distance between traps');

offset = extn - dist;

data = [dist, offset];

% Load correction GUI
result = OffsetCorrection(data);

disp(result);

handles.PSDoffsetFit = result;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in LoadOffset.
function LoadOffset_Callback(hObject, eventdata, handles)



%%% Step-fitter callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in FitSteps.
function handles = FitSteps_Callback(hObject, eventdata, handles) %#ok<INUSL>

currSelection = get(hObject, 'String');

if strcmp(currSelection, 'FIT')
    
    set(hObject, 'String', 'Erase');
    set(handles.ManualStepFitting, 'Visible', 'on');
    set(handles.SaveSteps, 'Visible', 'on');
    set(handles.text72, 'Visible', 'on');
    set(handles.AddDeleteStep, 'Visible', 'on');
    
    % Obtain all the parameters:
    %{
    MaxNumSteps = str2double(get(handles.MaxNumSteps, 'String'));
    ExpSqNoise = str2double(get(handles.ExpSqNoise, 'String'));
    MinDeltaQ = str2double(get(handles.MinDeltaQ, 'String'));
    MinPtsInStep = str2double(get(handles.MinPtsInStep, 'String'));
    %}
    Xlimits = get(handles.axes1, 'XLim');
    
    
    
    % Determine which trace to fit steps to:
    plotLegends = get(handles.ActiveTrace, 'String');
    activeTraceIndex = get(handles.ActiveTrace, 'Value');
    activeTrace = plotLegends{activeTraceIndex};
    
    
    for i=1:length(handles.allTraces)
        currTrace = handles.allTraces(i);
        currInd = i;
        if strcmp(currTrace.TraceName, activeTrace)
            break;
        end
    end
    
    % The rest executes only on the active trace:
    samplingRate = currTrace.SamplingRate;
    startTime = currTrace.StartTime;
    

    
    startIndex = floor((Xlimits(1) - startTime) * samplingRate);
    startIndex = max(startIndex, 1);
    startTimeNew = max(startTime, Xlimits(1));
    
    endIndex = ceil((Xlimits(2) - startTime) * samplingRate);
    endIndex = min(endIndex, length(currTrace.DataRaw));
    
    % Obtain current plot units
    plotUnitStr=get(handles.YScaleMenu,'string'); % Current selection
    plotUnitVal=get(handles.YScaleMenu,'value'); % Current selection
    plotUnits = plotUnitStr(plotUnitVal);
    if strcmp(plotUnits, 'Raw data (dimensionless)')
        data = currTrace.DataRaw(startIndex:endIndex)';
    else
        data = currTrace.Data_nm(startIndex:endIndex)';
    end
    
    noiseParam = get(handles.NoiseParam, 'Value');
    minStepSize = 0;
    
    % fit the steps
    %tic % uncomment tic/toc pair to benchmark stepfinder performance
    StepStatistics = SICstepFinder(data, minStepSize, noiseParam);
    %toc
    
    traceName = [activeTrace, '_step'];
    
    % Construct new allTraces structure:
    allTracesNew = handles.allTraces(1:currInd);
    nextTraceInd = currInd + 1;
      
    allTracesNew(nextTraceInd).TraceName = traceName;
    allTracesNew(nextTraceInd).Data_nm = StepStatistics.StepFit;
    allTracesNew(nextTraceInd).DataRaw = StepStatistics.StepFit;
    allTracesNew(nextTraceInd).SamplingRate = samplingRate;
    allTracesNew(nextTraceInd).StartTime = startTimeNew;
    allTracesNew(nextTraceInd).Visible = 1;
    
    allTracesNew = [allTracesNew, handles.allTraces(currInd+1:end)];
    handles.allTraces = allTracesNew;
    
    % Build step vector
    handles.stepVector = StepStatistics.StepFit;
    handles.stepVectorData = data; % Data (filtered/decimated) used for fit
    endTime = startTimeNew + (length(data)-1)/samplingRate;
    handles.stepVectorT = startTimeNew:(1/samplingRate):endTime;
    
    
    % Prepare and display power spectrum of corrected trace
    %{
    effectiveSR = handles.SamplingRate;
    if strcmp(get(handles.FilterData, 'String'), 'Raw Data?')
        effectiveSR = effectiveSR / ...
            str2double(get(handles.DecimationFactor, 'String'));
    end
        stepCorrectedX = x - StepStatistics.StepFit;
    [F, PSx, PSy]=GetWindowedPowerSpectrum(stepCorrectedX,...
        x,effectiveSR,1); %#ok<NASGU,ASGLU>
    %}
    if get(handles.PlotAutocorr, 'Value')
        figure;
        autocorr(stepCorrectedX,[],2);
    end
    
    %{
    figure;
    loglog(F, PSx, F,PSy);
    %}
        
else
   handles = ResetStepFitter(handles);
end


keepLimits = 2; % keep Y-limits strictly the same
handles = PlotData(hObject, handles, keepLimits); % Re-plot data

% Save the handles structure.
guidata(hObject,handles)



% This callback gets triggered if user clicks somewhere on the figure and
% is used to add or remove steps manually
function figure1_WindowButtonDownFcn(hObject, ~, handles)

% Determine if the user is trying to add or remove steps manually:
manualStepsButton = get(handles.ManualStepFitting, 'String');
manuallyAdjust = strcmp(manualStepsButton, 'Exit'); 

if manuallyAdjust
    
    % First, determine if the user clicked inside the axes:
    clickCoords = get(handles.axes1, 'CurrentPoint'); % in axes units
    clickX = clickCoords(1,1);
    clickY = clickCoords(1,2);
    
    Xlims = get(handles.axes1, 'XLim');
    Ylims = get(handles.axes1, 'YLim');
    inBounds = clickX>Xlims(1) && clickX<Xlims(2) && clickY>Ylims(1) && ...
        clickY<Ylims(2);
    
    if inBounds
        % Add or remove step:        
        handles = AddRmvStepManually(hObject, handles, clickX);
    end
end
% Save the handles structure.
guidata(hObject,handles)


% --- Executes on button press in AddDeleteStep.
function AddDeleteStep_Callback(hObject, ~, handles)

currentString = get(hObject, 'String');

if strcmp(currentString, 'Add')
    set(hObject, 'String', 'Delete');
else
    set(hObject, 'String', 'Add');
end
% Save the handles structure.
guidata(hObject,handles)

% --- Executes on button press in ManualStepFitting.
function ManualStepFitting_Callback(hObject, ~, handles)

currentString = get(hObject, 'String');

if strcmp(currentString, 'Adjust')
    set(hObject, 'String', 'Exit');
    
    zoom off
    pan off
    
else
    set(hObject, 'String', 'Adjust');
    set(handles.Pan,'string','Pan');
    zoom on
end
% Save the handles structure.
guidata(hObject,handles)



% --- Executes on button press in ChangeStepFilename.
function ChangeStepFilename_Callback(~, ~, handles)

% extract the current directory from filename:
currFullFileName = get(handles.StepsFilename, 'String');
slashPositions = strfind(currFullFileName, '\');
lastSlashPosition = slashPositions(end);
currDir = currFullFileName(1:lastSlashPosition);

filterSpec = [currDir, '*.mat'];
DialogTitle = 'Please select a file to save step-fitting results';


[fileName,pathName,filterIndex] = uiputfile(filterSpec,DialogTitle);  %#ok<NASGU>


if ~isequal(fileName, 0) && ~isequal(pathName, 0)
    set(handles.StepsFilename, 'String', [pathName, fileName]);
end


% --- Executes on button press in SaveSteps.
function SaveSteps_Callback(~, ~, handles)

fileName = get(handles.StepsFilename, 'String');
WriteStepsToFile(handles, fileName);


%%% Line-fitter callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in FitLine.
function FitLine_Callback(hObject, ~, handles)

currSelection = get(hObject, 'String');
if strcmp(currSelection, 'FIT')
    
    set(hObject, 'String', 'Erase');
    set(handles.SaveLineFit, 'Visible', 'on');
       
    Xlimits = get(handles.axes1, 'XLim');
    
    %determine start and end points
    startTime =  find(handles.currentPlotT > Xlimits(1), 1);
    endTime = find(handles.currentPlotT >= (Xlimits(2)), 1)-1;
    
    % select to fit line to:
    x = real(handles.currentPlotPSD_Long(startTime:endTime));
    t = handles.currentPlotT(startTime:endTime);
    
    % fit to straight line
    linFit = polyfit(t, x, 1);
    handles.lineFitCoeffs = linFit;
    
    % Build line vector
    handles.lineVector = NaN(1,length(handles.currentPlotPSD_Long));
    handles.lineVector(startTime:endTime) = t*linFit(1) + linFit(2);

else % Erase previously fitted line
    handles.lineVector = 0;
    set(handles.FitLine, 'String', 'FIT');
    set(handles.SaveLineFit, 'Visible', 'off');
end

keepLimits = 2; % keep Y-limits strictly the same
handles = PlotData(hObject, handles, keepLimits); % Re-plot data

% Save the handles structure.
guidata(hObject,handles)

function lineFitFilename_Callback(~, ~, handles)

% extract the current directory from filename:
currFullFileName = get(handles.lineFitFilenameEdit, 'String');
slashPositions = strfind(currFullFileName, '\');
lastSlashPosition = slashPositions(end);
currDir = currFullFileName(1:lastSlashPosition);

filterSpec = [currDir, '*.mat'];
DialogTitle = 'Please select a file to save line-fitting results';

[fileName,pathName,filterIndex] = uiputfile(filterSpec,DialogTitle);  %#ok<NASGU>

if ~isequal(fileName, 0) && ~isequal(pathName, 0) % check validity
    set(handles.lineFitFilenameEdit, 'String', [pathName, fileName]);
end


% --- Executes on button press in SaveLineFit.
function SaveLineFit_Callback(~, ~, handles)

fileName = get(handles.lineFitFilenameEdit, 'String');
WriteLineFitToFile(handles, fileName);


% --- Executes on slider movement.
function NoiseParam_Callback(hObject, eventdata, handles)
currSelection = get(handles.FitSteps, 'String');
if strcmp(currSelection, 'Erase')
    set(handles.FitSteps, 'String', 'FIT');
    newNoiseParam = num2str(get(hObject, 'Value'),2);
    set(handles.NoiseParam_edit, 'String', newNoiseParam);
    handles = FitSteps_Callback(handles.FitSteps, eventdata, handles);
    set(handles.FitSteps, 'String', 'Erase');
end
% Save the handles structure.
guidata(hObject,handles)


function NoiseParam_edit_Callback(hObject, eventdata, handles)
currSelection = get(handles.FitSteps, 'String');
if strcmp(currSelection, 'Erase')
    set(handles.FitSteps, 'String', 'FIT');
    newNoiseParam = str2double(get(hObject, 'String'));
    set(handles.NoiseParam, 'Value', newNoiseParam);
    handles = FitSteps_Callback(handles.FitSteps, eventdata, handles);
    set(handles.FitSteps, 'String', 'Erase');
end
% Save the handles structure.
guidata(hObject,handles)


%%% Small useful functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles = loadDataFile(handles, dataFile)
% Loads data file, adjusting for file type

[path, filename, extension]= fileparts(dataFile);
path = [path, filesep];
filename = [filename, extension];
if strcmp(extension, '.bin')
    handles = LoadNewBinDataFile(handles, path, filename);
elseif strcmp(extension, '.ytd')
    handles = LoadNewYTDdataFile(handles, path, filename);
elseif strcmp(extension, '.mat') % Mat-file from Bustamante trap
    handles = LoadBustamanteMatFile(handles, path, filename);
end

function trace = getDataFromTrace(handles, traceName)
% Returns the data stored in the trace definted by traceName, in the
% x-region defined by current axes1 window bounds.

% Get limits of current axis
Xlimits = get(handles.axes1, 'XLim');

% Build array of trace names:
traceNames = cell(length(handles.allTraces),1);
for i = 1:length(handles.allTraces)
    traceNames{i} = handles.allTraces(i).TraceName;
end

% Find index of requested trace
iTrace = find(strcmp(traceName, traceNames),1);

trace = handles.allTraces(iTrace).Data_nm;

samplingRate = handles.allTraces(iTrace).SamplingRate;
startTime = handles.allTraces(iTrace).StartTime;
XlimSamp = (Xlimits - startTime) * samplingRate ; % window limits

traceStart = max(ceil(XlimSamp(1)), 1);
traceEnd = min(floor(XlimSamp(2)), length(trace));

trace = trace(traceStart:traceEnd);



%%% Unused calbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% In all of the below callbacks:
% hObject    handle to the object (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function NoiseParam_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function NoiseParam_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function lambda_Callback(hObject, eventdata, handles) 

% --- Executes during object creation, after setting all properties.
function lambda_CreateFcn(hObject, eventdata, handles) 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles) 

% --- Executes during object creation, after setting all properties.
function Recording_Type_CreateFcn(hObject, eventdata, handles) 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CutoffFreq_Callback(hObject, eventdata, handles) 

% --- Executes during object creation, after setting all properties.
function CutoffFreq_CreateFcn(hObject, eventdata, handles) 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in CentreSignal.
function CentreSignal_Callback(hObject, eventdata, handles) 
% Hint: get(hObject,'Value') returns toggle state of CentreSignal

% --- Executes during object creation, after setting all properties.
function XOffset_CreateFcn(hObject, eventdata, handles) 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function YOffset_CreateFcn(hObject, eventdata, handles) 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles) 
% Hint: get(hObject,'Value') returns toggle state of checkbox7

function AODnmMHz_Callback(hObject, eventdata, handles) 

% --- Executes during object creation, after setting all properties.
function AODnmMHz_CreateFcn(hObject, eventdata, handles) 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ExpStepSize_Callback(hObject, eventdata, handles) 
% --- Executes during object creation, after setting all properties.
function ExpStepSize_CreateFcn(hObject, eventdata, handles) 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function upper_Callback(hObject, eventdata, handles) 

% --- Executes during object creation, after setting all properties.
function upper_CreateFcn(hObject, eventdata, handles) 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit9_Callback(hObject, eventdata, handles)  

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles) 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in PSD1.
function PSD1_Callback(hObject, eventdata, handles) 
% Hint: get(hObject,'Value') returns toggle state of PSD1

% --- Executes on button press in PSD2.
function PSD2_Callback(hObject, eventdata, handles) 
% Hint: get(hObject,'Value') returns toggle state of PSD2

% --- Executes on button press in AODTrapPos.
function AODTrapPos_Callback(hObject, eventdata, handles) 
% Hint: get(hObject,'Value') returns toggle state of AODTrapPos

% --- Executes on button press in PiezoTrapPos.
function PiezoTrapPos_Callback(hObject, eventdata, handles) 
% Hint: get(hObject,'Value') returns toggle state of PiezoTrapPos

function WindowLength_Callback(hObject, eventdata, handles) 
% Hints: get(hObject,'String') returns contents of WindowLength as text
%        str2double(get(hObject,'String')) returns contents of WindowLength as a double

% --- Executes during object creation, after setting all properties.
function WindowLength_CreateFcn(hObject, eventdata, handles) 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit11_Callback(hObject, eventdata, handles) 
% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double

% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles) 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FilterOrder_Callback(hObject, eventdata, handles) 
% Hints: get(hObject,'String') returns contents of FilterOrder as text
%        str2double(get(hObject,'String')) returns contents of FilterOrder as a double

% --- Executes during object creation, after setting all properties.
function FilterOrder_CreateFcn(hObject, eventdata, handles) 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function GridDiv_CreateFcn(hObject, eventdata, handles) 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on mouse press over stallsaxes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles) 
get(hObject,'xlim')

disp('You clicked on axis');

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over newSpringConstButton.
function newSpringConstButton_ButtonDownFcn(hObject, eventdata, handles) 

% --- Executes on key press over newSpringConstButton with no controls selected.
function newSpringConstButton_KeyPressFcn(hObject, eventdata, handles) 

% --- Executes during object creation, after setting all properties.
function LinesOrDots_CreateFcn(hObject, eventdata, handles) 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Outputs from this function are returned to the command line.
function varargout = SMDataLab_OutputFcn(hObject, eventdata, handles)   %#ok<STOUT>
% varargout  cell array for returning output args (see VARARGOUT);

% --- Executes during object creation, after setting all properties.
function YScaleMenu_CreateFcn(hObject, eventdata, handles) 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LowF_Callback(hObject, eventdata, handles) 
% Hints: get(hObject,'String') returns contents of LowF as text
%        str2double(get(hObject,'String')) returns contents of LowF as a double

% --- Executes during object creation, after setting all properties.
function LowF_CreateFcn(hObject, eventdata, handles) %#ok
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Get default command line output from handles structure
varargout{1} = handles.output; %#ok

function edit17_Callback(hObject, eventdata, handles) 
% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in MedianFilter.
function MedianFilter_Callback(hObject, eventdata, handles) 
% Hint: get(hObject,'Value') returns toggle state of MedianFilter

% --- Executes during object creation, after setting all properties.
function Decimate_Factor_CreateFcn(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MaxNumSteps_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of MaxNumSteps as text
%        str2double(get(hObject,'String')) returns contents of MaxNumSteps as a double


% --- Executes during object creation, after setting all properties.
function MaxNumSteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxNumSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ExpSqNoise_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of ExpSqNoise as text
%        str2double(get(hObject,'String')) returns contents of ExpSqNoise as a double

% --- Executes during object creation, after setting all properties.
function ExpSqNoise_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MinDeltaQ_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of MinDeltaQ as text
%        str2double(get(hObject,'String')) returns contents of MinDeltaQ as a double

% --- Executes during object creation, after setting all properties.
function MinDeltaQ_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MinPtsInStep_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of MinPtsInStep as text
%        str2double(get(hObject,'String')) returns contents of MinPtsInStep as a double


% --- Executes during object creation, after setting all properties.
function MinPtsInStep_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function StepsFilename_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of StepsFilename as text
%        str2double(get(hObject,'String')) returns contents of StepsFilename as a double

% --- Executes during object creation, after setting all properties.
function StepsFilename_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function DecimationFactor_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of DecimationFactor as text
%        str2double(get(hObject,'String')) returns contents of DecimationFactor as a double


% --- Executes during object creation, after setting all properties.
function DecimationFactor_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PrintFilenames.
function PrintFilenames_ButtonDownFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function NewParameters_CreateFcn(hObject, eventdata, handles)

% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% disp('You clicked on figure')

% --- Executes during object creation, after setting all properties.
function lineFitFilenameEdit_CreateFcn(hObject, eventdata, handles)

function lineFitFilenameEdit_Callback(hObject, eventdata, handles)


% --- Executes on button press in PlotAutocorr.
function PlotAutocorr_Callback(hObject, eventdata, handles)

% --- Executes on button press in FilterTrapPosCheckbox.
function FilterTrapPosCheckbox_Callback(hObject, eventdata, handles)


% --- Executes on button press in FilterOnlyCurrentCheckbox.
function FilterOnlyCurrentCheckbox_Callback(hObject, eventdata, handles)


function PiezoNmVolts_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function PiezoNmVolts_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ActiveTrace.
function ActiveTrace_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ActiveTrace_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function PSD_selector_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in PlotAllChannels.
function PlotAllChannels_Callback(hObject, eventdata, handles)



