function varargout = OffsetCorrection(varargin)
% OFFSETCORRECTION MATLAB code for OffsetCorrection.fig
%      
%      This function accepts the following parameters, in this order:
%      data: n-by-2 matrix with the first column containing trap-trap
%           separation and the second column containing PSD offset signal
%
%
%      OFFSETCORRECTION, by itself, creates a new OFFSETCORRECTION or raises the existing
%      singleton*.
%
%      H = OFFSETCORRECTION returns the handle to a new OFFSETCORRECTION or the handle to
%      the existing singleton*.
%
%      OFFSETCORRECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OFFSETCORRECTION.M with the given input arguments.
%
%      OFFSETCORRECTION('Property','Value',...) creates a new OFFSETCORRECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OffsetCorrection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OffsetCorrection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OffsetCorrection

% Last Modified by GUIDE v2.5 07-Nov-2014 17:01:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OffsetCorrection_OpeningFcn, ...
                   'gui_OutputFcn',  @OffsetCorrection_OutputFcn, ...
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


%%% Main figure callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before OffsetCorrection is made visible.
function OffsetCorrection_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OffsetCorrection (see VARARGIN)

% Process varargin

if length(varargin) >= 1
    handles.data = varargin{1};
end


% Choose default command line output for OffsetCorrection
handles.output = {'No data returned'};

handles = fitOffset(handles);
handles = plotData(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OffsetCorrection wait for user response (see UIRESUME)
uiwait(handles.OffsetCorrectionFig);

% --- Outputs from this function are returned to the command line.
function varargout = OffsetCorrection_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

delete(handles.OffsetCorrectionFig);


% --- Executes when user attempts to close OffsetCorrectionFig.
function OffsetCorrectionFig_CloseRequestFcn(~, ~, handles)
% hObject    handle to OffsetCorrectionFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.OffsetCorrectionFig, 'waitstatus'), 'waiting')
    uiresume(handles.OffsetCorrectionFig);
else
    % Hint: delete(hObject) closes the figure
    delete(handles.OffsetCorrectionFig);
end



%%% UI element Callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in SaveOffset.
function SaveOffset_Callback(~, ~, handles) %#ok<*DEFNU>

saveOffsetFit(handles);




% --- Executes on button press in RejectQuit.
function RejectQuit_Callback(hObject, ~, handles)

guidata(hObject, handles);

closeOffsetGUI(handles);


% --- Executes on button press in SaveQuit.
function SaveQuit_Callback(hObject, ~, handles)

saveOffsetFit(handles);

handles.output = handles.fitResult;

% Update handles structure
guidata(hObject, handles);

closeOffsetGUI(handles);



% --- Executes on button press in ApplyNotSave.
function ApplyNotSave_Callback(hObject, ~, handles)

handles.output = handles.fitResult;

% Update handles structure
guidata(hObject, handles);

closeOffsetGUI(handles);

% --- Executes on button press in Refit.
function Refit_Callback(hObject, ~, handles)

handles = fitOffset(handles);
handles = plotData(handles);

% Update handles structure
guidata(hObject, handles);


%%% Unused callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in WhichModel.
function WhichModel_Callback(~, ~, ~)

% --- Executes during object creation, after setting all properties.
function WhichModel_CreateFcn(~, ~, ~)


%%% Sub-functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles = fitOffset(handles)
% fits data to the current offset model

x = handles.data(:,1);
y = handles.data(:,2);

fitModels = get(handles.WhichModel, 'string');
selection = get(handles.WhichModel, 'value');

model = fitModels{selection};

handles.fitResult = fit(x, y, model);


function handles = plotData(handles)
% fits data to the current offset model

x = handles.data(:,1);
y = handles.data(:,2);

axes(handles.axesOffCorr)
cla reset;
hold on
plot(x,y)
plot(handles.fitResult);

xlabel('Distance between traps (nm)')
ylabel('Offset (nm)')
hold off

function closeOffsetGUI(handles)
% Closes the offset GUI

if isequal(get(handles.OffsetCorrectionFig, 'waitstatus'), 'waiting')
    uiresume(handles.OffsetCorrectionFig);
else
    % Hint: delete(hObject) closes the figure
    delete(handles.OffsetCorrectionFig);
end

function saveOffsetFit(handles)
% Saves the fit in a mat-file

fitResult = handles.fitResult; %#ok<NASGU>
uisave('fitResult','_fitResult');
