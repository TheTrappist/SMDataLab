function handles = LoadNewYTDdataFile(handles, path, filename)
% Reads data from a new file given by filename at the given path and saves 
% all the appropriate new variables to the handles structure. This file
% specifically loads files of the .ytd format
%
% Written by Vladislav Belyy
% Created on 07/16/2013
% Last modified on 03/31/2014

% Determine if user wants to plot individual channels in separate figure
plotRawData = get(handles.PlotAllChannels, 'value');


%% Prepare for data reading

tic % debug purposes only - optimizing load time

% Turn off filtering
set(handles.FilterData,'string','Filter/Decimate Data?')

handles = ResetStepFitter(handles);

% Reset line fitter
set(handles.FitLine, 'String', 'FIT');
set(handles.SaveLineFit, 'Visible', 'off');

DataFilePath=strcat(path,filename);
handles.currentPath=DataFilePath;

% Clear the allTraces structure
handles.allTraces = struct('TraceName', '','DataRaw',[],...
    'Data_nm', [], 'StartTime', 0, 'SamplingRate', 0, 'Visible', 1); 



%% Read data

[hdr, rawData] = ReadYTDdataFile(DataFilePath); % binary data read

rawData = rawData / 131072; % convert back from int32 to double

%% Pull out useful parameters from file header

handles.trackAngle = hdr(1).trackAngle;
samplingRate = hdr(1).nSamplesSec;

% Calculate trap stiffness along the tether coordinate by assuming that the
% trap is elliptical with the axes aligned along the x and y axes

k_AOD = abs(hdr(1).springConstAOD);
k_Piezo = abs(hdr(1).springConstPiezo);
theta = [handles.trackAngle, (handles.trackAngle + pi/2)];


a = k_AOD(1);
b = k_AOD(2);
k_AOD_rot = a*b ./ sqrt((b*cos(theta)).^2+(a*sin(theta)).^2);

a = k_Piezo(1);
b = k_Piezo(2);
k_Piezo_rot = a*b ./ sqrt((b*cos(theta)).^2+(a*sin(theta)).^2);

if any(isnan(k_AOD_rot)) || any(isnan(k_Piezo_rot))
    disp(...
        'WARNING: trap stiffness not saved in file. Using default values');
    k_AOD_rot = [1,1];
    k_Piezo_rot = k_AOD_rot;
end

handles.trapStiffRotated = [k_AOD_rot; k_Piezo_rot];
    
try
    handles.trapOffsets = hdr(1).trapOffsets;
catch exception
    handles.trapOffsets = [0, 0];
    disp(exception.message);
end

% Correct PSD 1 signal for AOD trap position, if required and able:
correctPSDforAOD = get(handles.CorrectPSDforAODtrap, 'value');
if correctPSDforAOD && (abs(hdr.PSDvsAODcorr(1)) < 1000)
    correctPSDforAOD = 1;
else
    correctPSDforAOD = 0;
end

hdr(1).coeffsPSD1;
hdr(1).coeffsPSD2;
% Load PSD coefficients:
frmt = '%1.3e'; % format string
set(handles.x_Trap1_0, 'string', num2str(hdr(1).coeffsPSD1(1),frmt));
set(handles.x_Trap1_1, 'string', num2str(hdr(1).coeffsPSD1(2),frmt));
set(handles.x_Trap1_2, 'string', num2str(hdr(1).coeffsPSD1(3),frmt));
set(handles.x_Trap1_3, 'string', num2str(hdr(1).coeffsPSD1(4),frmt));
set(handles.y_Trap1_0, 'string', num2str(hdr(1).coeffsPSD1(5),frmt));
set(handles.y_Trap1_1, 'string', num2str(hdr(1).coeffsPSD1(6),frmt));
set(handles.y_Trap1_2, 'string', num2str(hdr(1).coeffsPSD1(7),frmt));
set(handles.y_Trap1_3, 'string', num2str(hdr(1).coeffsPSD1(8),frmt));
set(handles.x_Trap2_0, 'string', num2str(hdr(1).coeffsPSD2(1),frmt));
set(handles.x_Trap2_1, 'string', num2str(hdr(1).coeffsPSD2(2),frmt));
set(handles.x_Trap2_2, 'string', num2str(hdr(1).coeffsPSD2(3),frmt));
set(handles.x_Trap2_3, 'string', num2str(hdr(1).coeffsPSD2(4),frmt));
set(handles.y_Trap2_0, 'string', num2str(hdr(1).coeffsPSD2(5),frmt));
set(handles.y_Trap2_1, 'string', num2str(hdr(1).coeffsPSD2(6),frmt));
set(handles.y_Trap2_2, 'string', num2str(hdr(1).coeffsPSD2(7),frmt));
set(handles.y_Trap2_3, 'string', num2str(hdr(1).coeffsPSD2(8),frmt));

%{
ChannelLogic=WhichChannels(filename);
handles.ChLogic=ChannelLogic;

%determine number of samples in file:
firstNP=strfind(filename,'NP');
lastNP=strfind(filename,'ANG');
numSamp = str2double(filename(firstNP+2:lastNP-1));
%}



%% Convert raw data into PSD and trap signals

% Find column indices of PSD and trap signals
Xdiff1 = (strfind(hdr(1).chanIDs,'PSD1XDIF')+7)/8;
Ydiff1 = (strfind(hdr(1).chanIDs,'PSD1YDIF')+7)/8;
Xsum1 = (strfind(hdr(1).chanIDs,'PSD1XSUM')+7)/8;
Ysum1 = (strfind(hdr(1).chanIDs,'PSD1YSUM')+7)/8;
Xdiff2 = (strfind(hdr(1).chanIDs,'PSD2XDIF')+7)/8;
Ydiff2 = (strfind(hdr(1).chanIDs,'PSD2YDIF')+7)/8;
Xsum2 = (strfind(hdr(1).chanIDs,'PSD2XSUM')+7)/8;
Ysum2 = (strfind(hdr(1).chanIDs,'PSD2YSUM')+7)/8;
XTrapAOD = (strfind(hdr(1).chanIDs,'AODTRAPX')+7)/8;
YTrapAOD = (strfind(hdr(1).chanIDs,'AODTRAPY')+7)/8;
XTrapPiezo = (strfind(hdr(1).chanIDs,'PZMTRAPX')+7)/8;
YTrapPiezo= (strfind(hdr(1).chanIDs,'PZMTRAPY')+7)/8;





%Initialize variables
PSD1 = [];
PSD2 = [];
AODTrap = [];
PiezoTrap = [];

% Convert PSD1 data into X/Y pairs
if ~isempty(Xdiff1) && ~isempty(Ydiff1)...
        && ~isempty(Xsum1) && ~isempty(Ysum1) % PSD1 channel exists
    PSD1 = [rawData(:,Xdiff1)./rawData(:,Xsum1), ...
        rawData(:,Ydiff1)./rawData(:,Ysum1)];
end

% Convert PSD2 data into X/Y pairs
if ~isempty(Xdiff2) && ~isempty(Ydiff2)...
        && ~isempty(Xsum2) && ~isempty(Ysum2) % PSD2 channel exists
    PSD2 = [rawData(:,Xdiff2)./rawData(:,Xsum2), ...
        rawData(:,Ydiff2)./rawData(:,Ysum2)];
end

% Append trap position if it exists
if ~isempty(XTrapAOD) && ~isempty(YTrapAOD) % AOD trap channel exists
    AODTrap = [rawData(:,XTrapAOD), rawData(:,YTrapAOD)];
end

if ~isempty(XTrapPiezo) && ~isempty(YTrapPiezo) % Piezo trap channel exists
    PiezoTrap = [rawData(:,XTrapPiezo), rawData(:,YTrapPiezo)];
end

if plotRawData % Store individual PSD channels for debugging
    
    handles.hRawPSD.Xdiff1 = rawData(:,Xdiff1);
    handles.hRawPSD.Ydiff1 = rawData(:,Ydiff1);
    handles.hRawPSD.Xsum1 = rawData(:,Xsum1);
    handles.hRawPSD.Ysum1 = rawData(:,Ysum1);
    
    handles.hRawPSD.Xdiff2 = rawData(:,Xdiff2);
    handles.hRawPSD.Ydiff2 = rawData(:,Ydiff2);
    handles.hRawPSD.Xsum2 = rawData(:,Xsum2);
    handles.hRawPSD.Ysum2 = rawData(:,Ysum2);
    
    handles.hRawPSD.SR = samplingRate;
    
end
   
    


tElapsed = toc; % debug purposes only - optimizing time

% Apply PSD vs trap position correction
if correctPSDforAOD
    PSD1(:,1) = PSD1(:,1) - AODTrap(:,1)*hdr(1).PSDvsAODcorr(1);
    PSD1(:,2) = PSD1(:,2) - AODTrap(:,2)*hdr(1).PSDvsAODcorr(2);
end

set(handles.FileName,'string',filename)
set(handles.FilePath,'string',path)


%% Load data into allTraces
handles.allTraces = struct('TraceName', '','DataRaw',[], 'Data_nm', [], ...
    'StartTime', 0, 'SamplingRate', 0, 'Visible', 1); 

i = 1; %Counter for filling handles.allTraces

if ~isempty(PSD1) % if PSD1 is recorded
    handles.allTraces(i).DataRaw=PSD1(:,1);
    handles.allTraces(i).TraceName = 'PSD1 X';
    handles.allTraces(i+1).DataRaw=PSD1(:,2);
    handles.allTraces(i+1).TraceName = 'PSD1 Y';
    i = i+2;
end

if ~isempty(PSD2) % if PSD2 is recorded
    handles.allTraces(i).DataRaw=PSD2(:,1);
    handles.allTraces(i).TraceName = 'PSD2 X';
    handles.allTraces(i+1).DataRaw=PSD2(:,2);
    handles.allTraces(i+1).TraceName = 'PSD2 Y';
    i = i+2;
end

if ~isempty(AODTrap) %if trap position is recorded
    handles.allTraces(i).DataRaw=AODTrap(:,1);
    handles.allTraces(i).TraceName = 'AOD Trap X';
    handles.allTraces(i+1).DataRaw=AODTrap(:,2);
    handles.allTraces(i+1).TraceName = 'AOD Trap Y';
    i = i+2;
end


if ~isempty(PiezoTrap) %if trap position is recorded
    handles.allTraces(i).DataRaw=PiezoTrap(:,1);
    handles.allTraces(i).TraceName = 'Piezo Trap X';
    handles.allTraces(i+1).DataRaw=PiezoTrap(:,2);
    handles.allTraces(i+1).TraceName = 'Piezo Trap Y';
    i = i+2; %#ok<NASGU>
end



%% Wrap up

set(handles.AODnmMHz,'string', num2str(hdr(1).nmPerMHz));
set(handles.PiezoNmVolts,'string', num2str(hdr(1).nmPerVolt));

% Convert raw PSD data and rotate along tether coordinate
handles = BuildCurrentPSDData(handles); 

%{
endTime = (length(handles.allTraces(1).DataRaw)-1) / samplingRate;
timeVector = 0:(1/samplingRate):endTime;
%}

% Add time and sampling rate data to all data in allTraces
for i=1:length(handles.allTraces)
    handles.allTraces(i).StartTime = 0;
    handles.allTraces(i).SamplingRate = samplingRate;
    handles.allTraces(i).Visible = 1;

end

% debug purposes only:
disp(['Loaded in: ', num2str(tElapsed), ' seconds']);
