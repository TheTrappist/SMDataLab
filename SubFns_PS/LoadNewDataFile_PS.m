function handles = LoadNewDataFile_PS(hObject, handles, path, filename)
% Reads data from a new file given by filename at the given path and saves 
% all the appropriate new variables to the handles structure
%
% Written by Vladislav Belyy
% Last updated on 11/18/2011


%% Prepare for data reading

tic % debug purposes only - optimizing load time

% Turn off filtering
set(handles.FilterData,'string','Filter Data?')
handles.display.filtered = 0;

DataFilePath=strcat(path,filename);
handles.currentPath=DataFilePath;


ChannelLogic=WhichChannels(filename);
handles.ChLogic=ChannelLogic;

%determine number of samples in file:
firstNP=strfind(filename,'NP');
lastNP=strfind(filename,'ANG');
numSamp = str2double(filename(firstNP+2:lastNP-1));



%% Read data

Data=ReadBinDataFile_PS(DataFilePath,ChannelLogic, numSamp); % read binary

%Data=ReadDataFile(DataFilePath); % fast data read
%Data=textread(DataFilePath); % Old implementation; much slower

tElapsed = toc; % debug purposes only - optimizing time


set(handles.FileName,'string',filename)
set(handles.FilePath,'string',path)


% Find out which columns of Data store trap position:
trapPosColumn=2*ChannelLogic(1)+2*ChannelLogic(2)+1; 

% Find out which columns of Data store bright-field logic
BFChannelColumn=2*ChannelLogic(1)+2*ChannelLogic(2)+2*ChannelLogic(3)+1;


if ChannelLogic(1)==1 % if PSD1 is recorded
    handles.rawPSD1Data_Y=Data(:,1); % read the PSD1 data
    handles.rawPSD1Data_X=Data(:,2);
end


if ChannelLogic(3)==1 %if trap position is recorded
    handles.trapPositionRaw_X=Data(:,trapPosColumn); 
    handles.trapPositionRaw_Y=Data(:,trapPosColumn+1);
    
else % generate empty vectors for trap position
    handles.trapPositionRaw_X = zeros(size(Data,1),1);
    handles.trapPositionRaw_Y = zeros(size(Data,1),1);
end

if ChannelLogic(4)==1 %if bright-field logic is recorded
    handles.BFLog=Data(:,BFChannelColumn); % read the bright-field logic data
end

% Set the channel indicators:
set(handles.PSD1,'Value',(ChannelLogic(1)));
set(handles.PSD2,'Value',(ChannelLogic(2)));
set(handles.TrapPos,'Value',(ChannelLogic(3)));
set(handles.BFLogic,'Value',(ChannelLogic(4)));

%% Convert raw data to positions

% See if user wants data to be centered
handles = DetermineCentering_PS(hObject, handles);

% Rotate and convert raw PSD1 signals: creates handles.PSD1Data_Long,
% PSD1Data_Short, and handles.t
handles = BuildCurrentPSD1Data_PS(hObject, handles); 

%%% Process trap position data %%%

if ChannelLogic(3)==1 %if trap position is recorded 
    
    % Obtain nm/MHz conversion parameter for trap position display
    ConvertPara = ...
        str2double(get(handles.FeedbackConversionPara,'string'));
    handles.FeedbackConvPara=ConvertPara;

    trapPosArray = ...
        [handles.trapPositionRaw_X'; handles.trapPositionRaw_Y'];
    
    % generate rotation matrix:
    ANG = handles.trackAngle;
    M=[cos(ANG) sin(ANG);-sin(ANG) cos(ANG)]; 
    % rotate trap position signal
    trapPosRotated=M*trapPosArray;
    
    % Save converted and rotated trap position:
    handles.trapPosLong = -trapPosRotated(1,:)*ConvertPara;
    handles.trapPosShort = -trapPosRotated(2,:)*ConvertPara;
    % Formerly handles.Flong and handles.Fshort

else % if trap position is not recorded, create array of zeros
    handles.trapPosLong = zeros(1, length(handles.t)); 
    handles.trapPosShort = zeros(1, length(handles.t));
 
end

% Determine if the trace is force feedback or fixed trap
if any(handles.trapPosLong) || any(handles.trapPosShort)
    set (handles.Recording_Type, 'Value', 2); % Force feedback
    handles.recordingType = 'Force clamp';
    set(handles.TrapPositionToggle,'string','Remove Trap Position');
    handles.display.trapPosLong = 1;
else
    set (handles.Recording_Type, 'Value', 1); % Fixed trap
    handles.recordingType = 'Fixed trap';
    set(handles.TrapPositionToggle,'string','Display Trap Position')
    handles.display.trapPosLong = 0;
    handles.display.trapPosShort = 0;
end


% debug purposes only:
disp(['Loaded in: ', num2str(tElapsed), ' seconds']);

% Update handles structure
guidata(hObject, handles);