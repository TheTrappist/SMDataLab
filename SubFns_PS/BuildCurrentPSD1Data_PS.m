function handles = BuildCurrentPSD1Data_PS(hObject, handles)
% Rotates PSD1 signal along the axoneme track and converts the signal to
% nanometers. The output, written directly to the handles structure, is
% PSD1Data_Long and PSD1Data_Short, two vectors containing
% the long-axis position in nanometers and short-axis position in
% nanometers, respectively. This function also generates handles.t, a
% vector of the same length as PSD1Data that stores the time
% coordinate of the recording, and handles.trackAngle, which stores the
% track angle of the current recording

% Written by Vladislav Belyy


% Read the polynomial coefficients used to convert raw PSD signals to
% nanometers
handles.ax1=str2double(get(handles.x1,'string')); 
handles.ax3=str2double(get(handles.x3,'string')); 
handles.ax0=str2double(get(handles.x0,'string')); 
handles.ax2=str2double(get(handles.x2,'string')); 
handles.ay1=str2double(get(handles.y1,'string')); 
handles.ay3=str2double(get(handles.y3,'string'));
handles.ay0=str2double(get(handles.y0,'string'));
handles.ay2=str2double(get(handles.y2,'string'));


% I have no clue why Tom passed zero instead of ax2/ay2 here. It may be
% important but I'm changing it for now because I can't think of any good
% reasons to not just pass ax2 and ay2.
%xCoeffs=[handles.ax1 0 handles.ax3]; 
%yCoeffs=[handles.ay1 0 handles.ay3];

% create arrays of polynomial coefficients:
xCoeffs=[handles.ax1 handles.ax2 handles.ax3]; 
yCoeffs=[handles.ay1 handles.ay2 handles.ay3];

% convert psd to position
X=convertPSD2position_PS(handles.rawPSD1Data_X,xCoeffs);
Y=convertPSD2position_PS(handles.rawPSD1Data_Y,yCoeffs);


%get angle of rotation and sampling rate from filename
filename = get(handles.FileName,'string');
[ANG SR ProtNum]=getdetailsfromFilename_PS(filename); %#ok

handles.TrackAngle=ANG;
handles.SamplingRate=SR;

% create time axis:
handles.t=1/SR:1/SR:length(X)/SR;

% generate rotation matrix:
M=[cos(ANG) sin(ANG);-sin(ANG) cos(ANG)]; 

rotatedSignal=M*[X';Y']; % Rotate the signal along the track

% Generate rotated signal and save it to handles
handles.PSD1Data_Long = rotatedSignal(1,:);
handles.PSD1Data_Short = rotatedSignal(2,:);
handles.trackAngle = ANG;
