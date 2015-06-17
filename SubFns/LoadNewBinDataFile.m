function handles = LoadNewBinDataFile(handles, path, filename)
% Reads data from a new file given by filename at the given path and saves 
% all the appropriate new variables to the handles structure
%   All relevant information about the file can be extracted from its name,
%   which follows the following template:
%   
%   (yymmdd)_(hrminsec)_SR(sampling rate in Hz)NP(number of points)ANG
%   (whole_thousadths of radians, representing angle of track)_CH(four t/f 
%   characters for the four channels that can be recorded)_(type of 
%   recording)_(user notes)_(number of recording).bin
%
%   For example, the filename: 
%  110927_174403_SR20000NP100000ANGm1_515_CHtftf_rapidscan_37.bin
%   means that this file:
%   1) was created at 17:44:03 on Sept. 27, 2011  
%   2) is sampled at 20000Hz (i.e. 20kHz)
%   3) contains 100,000 time points (so given the sampling rate, this file
%     contains 5 seconds of data)
%   4) needs to be rotated by the angle of the axoneme track, -1.515 
%     radians. We know that the value is negative because of the lower-case
%     letter 'm' between ANG and the number
%   5) contains two channels, PSD1 and Trap Position
%   6) is a PSD calibration file (keyword 'rapidscan')
%   7) was the 37th file acquired on that day
%
% Written by Vladislav Belyy
% Last updated on 02/12/2013


%% Prepare for data reading

tic % debug purposes only - optimizing load time

% Turn off filtering
set(handles.FilterData,'string','Filter/Decimate Data?')
handles.display.filtered = 0;

handles = ResetStepFitter(handles);

% Reset line fitter
handles.lineVector = 0;
set(handles.FitLine, 'String', 'FIT');
set(handles.SaveLineFit, 'Visible', 'off');

DataFilePath=strcat(path,filename);
handles.currentPath=DataFilePath;


ChannelLogic=WhichChannels(filename);
handles.ChLogic=ChannelLogic;

%determine number of samples in file:
firstNP=strfind(filename,'NP');
lastNP=strfind(filename,'ANG');
numSamp = str2double(filename(firstNP+2:lastNP-1));


%% Read data

% Uncomment the two lines below to read from the text file instead
%DataFilePathOld = strrep(DataFilePath,'.bin','PSDsignals.txt');
%DataOld=ReadDataFile(DataFilePathOld); % fast data read

Data=ReadBinDataFile(DataFilePath,ChannelLogic, numSamp); % binary data read

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
set(handles.AODTrapPos,'Value',(ChannelLogic(3)));
set(handles.PiezoTrapPos,'Value',(ChannelLogic(4)));

%% Convert raw data to positions

% See if user wants data to be centered
handles = DetermineCentering (handles);

% Rotate and convert raw PSD1 signals: creates handles.PSD1Data_Long,
% PSD1Data_Short, and handles.t
handles = BuildCurrentPSD1Data(handles); 

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
     handles.display.trapPosLong = 1;
elseif any(handles.trapPosShort)
    set (handles.Recording_Type, 'Value', 2); % Force feedback
    handles.recordingType = 'Force clamp';
    handles.display.trapPosShort = 1;
else
    set (handles.Recording_Type, 'Value', 1); % Fixed trap
    handles.recordingType = 'Fixed trap';
    handles.display.trapPosLong = 0;
    handles.display.trapPosShort = 0;
end


% debug purposes only:
disp(['Loaded in: ', num2str(tElapsed), ' seconds']);
