function varargout = TrapCalibrationGUI(varargin)
% TRAPCALIBRATIONGUI M-file for TrapCalibrationGUI.fig
%      TRAPCALIBRATIONGUI, by itself, creates a new TRAPCALIBRATIONGUI or raises the existing
%      singleton*.
%
%      H = TRAPCALIBRATIONGUI returns the handle to a new TRAPCALIBRATIONGUI or the handle to
%      the existing singleton*.
%
%      TRAPCALIBRATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRAPCALIBRATIONGUI.M with the given input arguments.
%
%      TRAPCALIBRATIONGUI('Property','Value',...) creates a new TRAPCALIBRATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PowerSpectrumGUI_VladSaveData_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to TrapCalibrationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TrapCalibrationGUI

% Last Modified by GUIDE v2.5 12-Feb-2013 18:11:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TrapCalibrationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @TrapCalibrationGUI_OutputFcn, ...
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


% --- Executes just before TrapCalibrationGUI is made visible.
function TrapCalibrationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TrapCalibrationGUI (see VARARGIN)


setappdata(0,'UseNativeSystemDialogs',false)

MainPath=pwd;
SubFunctions=strcat(MainPath,'\SubFns_PS');
SubFunctions2=strcat(MainPath,'\SubFns_PS\Jeffs Code');
addpath(SubFunctions)
addpath(SubFunctions2)

set(handles.SavePowerSpectrum,'Visible','off')

handles.Sx=[0];
handles.Sy=[0];
handles.x=[0];
handles.y=[0];
handles.t=[0];
handles.PSx=[0];
handles.PSy=[0];
handles.fx=[0];
handles.fy=[0];
handles.SR=10000;
handles.currentXlabel='time (s)';
handles.currentYlabel='position (nm)';
handles.currentstyleX='b.';
handles.currentstyleY='r.';
handles.currentDir='C:\*.txt';
handles.currentPath='*.txt';
handles.Ytype=1;
handles.Yaxis=1;

% vladsData stores the following values:
% Kx and Ky from power spectrum, Kx and Ky from equipartition,
% and filename (string)
handles.vladsData={0,0,0,0,0,0,''};

% Choose default command line output for TrapCalibrationGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TrapCalibrationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TrapCalibrationGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in NewParameters.
function NewParameters_Callback(hObject, eventdata, handles)
% hObject    handle to NewParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% cd SubFns


%{
currDir = get(handles.FilePath, 'String');

[paras dir pathname]=GetNewConversionParams_PS(currDir);

set(handles.FilePath,'string',pathname)
handles.currentDir=dir;

% cd ..

% set(handles.x1,'string',num2str(paras(1),'%0.2e'))
% set(handles.x3,'string',num2str(paras(2),'%0.2e'))
% set(handles.y1,'string',num2str(paras(3),'%0.2e'))
% set(handles.y3,'string',num2str(paras(4),'%0.2e'))
% 
% handles.ax1=str2num(get(handles.x1,'string'));
% handles.ax3=str2num(get(handles.x3,'string'));
% handles.ay1=str2num(get(handles.y1,'string'));
% handles.ay3=str2num(get(handles.y3,'string'));
% 
% ax=[handles.ax1 0 handles.ax3];
% ay=[handles.ay1 0 handles.ay3];
set(handles.x0,'string',num2str(paras(1),'%0.2e'))
set(handles.x1,'string',num2str(paras(2),'%0.2e'))
set(handles.x2,'string',num2str(paras(3),'%0.2e'))
set(handles.x3,'string',num2str(paras(4),'%0.2e'))
set(handles.y0,'string',num2str(paras(5),'%0.2e'))
set(handles.y1,'string',num2str(paras(6),'%0.2e'))
set(handles.y2,'string',num2str(paras(7),'%0.2e'))
set(handles.y3,'string',num2str(paras(8),'%0.2e'))

handles.ax1=str2num(get(handles.x1,'string'));
handles.ax3=str2num(get(handles.x3,'string'));
handles.ax0=str2num(get(handles.x0,'string'));
handles.ax2=str2num(get(handles.x2,'string'));
handles.ay1=str2num(get(handles.y1,'string'));
handles.ay3=str2num(get(handles.y3,'string'));
handles.ay0=str2num(get(handles.y0,'string'));
handles.ay2=str2num(get(handles.y2,'string'));
%}


handles=GetNewConversionParams_PS(hObject, handles);

ax=[handles.ax1 handles.ax2 handles.ax3];
ay=[handles.ay1 handles.ay2 handles.ay3];
% 
% cd SubFns

X=convertPSD2position_PS(handles.Sx,ax);
Y=convertPSD2position_PS(handles.Sy,ay);


handles.X=X;
handles.Y=Y;

% cd ..

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in LoadFile.
function LoadFile_Callback(hObject, eventdata, handles)
% hObject    handle to LoadFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


currDir = get(handles.FilePath, 'String');

[filename, pathname, filterindex] = uigetfile({'*.ytd;*.bin', ...
    'Trap data files (*.bin or *.ytd)'}, ...
    'Select a trap data file', currDir); %#ok

handles.currentDir=pathname;

DataFilePath=strcat(pathname,filename)

handles.currentPath=DataFilePath;

[~, ~, extension]= fileparts(filename); 

if strcmp(extension, '.bin') % binary file
    %Data=textread(DataFilePath);
    ChannelLogic=WhichChannels_PS(filename);
    handles.ChLogic=ChannelLogic;
    
    %determine number of samples in file:
    firstNP=strfind(filename,'NP');
    lastNP=strfind(filename,'ANG');
    numSamp = str2double(filename(firstNP+2:lastNP-1));
    
    Data = ReadBinDataFile_PS(DataFilePath,ChannelLogic, numSamp); % read binary
    
elseif strcmp(extension, '.ytd') % ytd file
    
    [hdr, rawData] = ReadYTDdataFile_PS(DataFilePath);
            
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
    ChannelLogic = zeros(1,4);
    
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
    
    choice = 'default';
    if (~isempty(PSD1) && ~isempty(PSD2))
        choice = questdlg('Which trap to calibrate?', ...
            'Trap selection', ...
               'AOD trap (PSD1)','Piezo trap (PSD2)','AOD trap (PSD1)');
    end
    
    if isempty(PSD2) || strcmp(choice, 'AOD trap (PSD1)')
        % Use PSD1 and AOD trap data
        Data = [PSD1, AODTrap];
    else
        % Use PSD2 and Piezo trap data
        Data = [PSD2, PiezoTrap];
    end

        
    
end

set(handles.FileName,'string',filename)
set(handles.FilePath,'string',pathname)

Sy=Data(:,1);
Sx=Data(:,2);
Fx=Data(:,3);
Fy=Data(:,4);

handles.Sx=Sx;
handles.Sy=Sy;
handles.Fx=Fx;
handles.Fy=Fy;


handles.ax1=str2num(get(handles.x1,'string'));
handles.ax3=str2num(get(handles.x3,'string'));
handles.ay1=str2num(get(handles.y1,'string'));
handles.ay3=str2num(get(handles.y3,'string'));

ax=[handles.ax1 0 handles.ax3]
ay=[handles.ay1 0 handles.ay3]
% 
% cd SubFns

X=convertPSD2position_PS(Sx,ax);
Y=convertPSD2position_PS(Sy,ay);


handles.X=X;
handles.Y=Y;

if strcmp(extension, '.bin') % binary file
    [ANG SR ProtNum]=getdetailsfromFilename_PS(filename);
elseif strcmp(extension, '.ytd') % ytd file
    ANG = hdr(1).trackAngle;
    SR = hdr(1).nSamplesSec;
end

% 
% cd ..

handles.TrackAngle=ANG;

handles.SR=SR;

handles.t=1/SR:1/SR:length(handles.X)/SR;

str=get(handles.YScaleMenu,'string');
val=get(handles.YScaleMenu,'value');
[Xlim, Ylim, handles]=SaveYScale_PS(handles, str, val,1);
str=get(handles.popupmenu1,'string');
val=get(handles.popupmenu1,'value');
[Xlim Ylim handles]=SavePlotStyle_PS(handles,val,str);

PlotMainData_PS(handles);

% axes(handles.axes1)
% zoom on
% plot(handles.t,handles.currentdataY,handles.currentstyleY,handles.t,handles.currentdataX,handles.currentstyleX)
% xlabel(handles.currentXlabel);
% ylabel(handles.currentYlabel);
% legend('Y','X')
%title(handles.currentttitle);

set(handles.SavePowerSpectrum,'Visible','off')

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in RePlot.
function RePlot_Callback(hObject, eventdata, handles)
% hObject    handle to RePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% axes(handles.axes1)
% plot(handles.t,handles.currentdataY,handles.currentstyleY,handles.t,handles.currentdataX,handles.currentstyleX)
% xlabel(handles.currentXlabel);
% ylabel(handles.currentYlabel);
% legend('Y','X')
PlotMainData_PS(handles);

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

% Determine the selected data set.
str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
% switch str{val};
% case 'Dots' % User selects peaks
%    handles.currentstyleX='b.';
%    handles.currentstyleY='r.';
% case 'Lines' % User selects membrane
%    handles.currentstyleX = 'b-';
%    handles.currentstyleY = 'r-';
% end
[Xlim Ylim handles]=SavePlotStyle_PS(handles,val,str);

% axes(handles.axes1)
% plot(handles.t,handles.currentdataY,handles.currentstyleY,handles.t,handles.currentdataX,handles.currentstyleX)
% xlabel(handles.currentXlabel);
% ylabel(handles.currentYlabel);
% legend('Y','X')
PlotMainData_PS(handles);

% Save the handles structure.
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in YScaleMenu.
function YScaleMenu_Callback(hObject, eventdata, handles)
% hObject    handle to YScaleMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Determine the selected data set.
str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
% switch str{val};
% case 'Dimensionless PSD units' % User selects peaks
%    handles.currentdataX=handles.Sx;
%    handles.currentdataY=handles.Sy;
%    handles.currentYlabel='PSD signal (dimensionless units)';
% case 'nm and rotated' % User selects membrane
%    handles.currentdataX = handles.X;
%    handles.currentdataY = handles.Y;
%    handles.currentYlabel='position (nm)';
% end

handles=SaveYScale_PS(handles, str, val,1);

% axes(handles.axes1)
% plot(handles.t,handles.currentdataX,handles.currentstyleX,handles.t,handles.currentdataY,handles.currentstyleY)
% xlabel(handles.currentXlabel);
% ylabel(handles.currentYlabel);
% legend('X','Y')

PlotMainData_PS(handles);


% Save the handles structure.
guidata(hObject,handles)

% Hints: contents = get(hObject,'String') returns YScaleMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from YScaleMenu


% --- Executes during object creation, after setting all properties.
function YScaleMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YScaleMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in DisplayPS.
function DisplayPS_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.SavePowerSpectrum,'Visible','on')

X=handles.X;
Y=handles.Y;
t=handles.t;
SR=handles.SR;

WindowLength=str2num(get(handles.WindowLength,'string'))
% 
% cd SubFns

Wind=get(handles.Windowed,'Value');
FreqAv=get(handles.FrequencyAveraged,'Value');

lowF=str2num(get(handles.LowF,'string'));
highF=str2num(get(handles.HighF,'string'));

X=X-median(X);

Y=Y-median(Y);

[NX XX]=hist(X,25);
STDevX=std(X)

lnNX=log(NX);

% figure;

% plot(XX,lnNX,'b*')
% 
% lnp=fminsearch(@(lnp) FitLogGaussian(XX,lnNX,lnp),[STDevX max(lnNX)])
% 
% XXX=min(XX):.01:max(XX);
% 
% XFIT=lnp(2)-XXX.*XXX/2/lnp(1)^2;
% 
% hold on
% 
% plot(XXX,XFIT,'r-')




set(handles.XStDev,'string',strcat('X StDev = ',num2str(STDevX),' nm^2'))

KX=4.11/STDevX^2
set(handles.KxEE,'string',strcat('Kx = ',num2str(KX),' pN/nm'))

axes(handles.XHist)

plot(XX,lnNX,'b*')

lnp=fminsearch(@(lnp) FitLogGaussian(XX,lnNX,lnp),[STDevX max(lnNX)])

XXX=min(XX):.01:max(XX);

XFIT=lnp(2)-XXX.*XXX/2/lnp(1)^2;

hold on

plot(XXX,XFIT,'r-')
% bar(XX,NX,'b')
xlabel('x (nm)')
ylabel('ln(N)')

hold off

[NY YY]=hist(Y,25);

STDevY=std(Y)

set(handles.YStDev,'string',strcat('Y StDev = ',num2str(STDevY),' nm^2'))

KY=4.11/STDevY^2
set(handles.KyEE,'string',strcat('Ky = ',num2str(KY),' pN/nm'))

axes(handles.YHist)

lnNY=log(NY);

plot(YY,lnNY,'b*')

lnp=fminsearch(@(lnp) FitLogGaussian(YY,lnNY,lnp),[STDevY max(lnNY)])

YYY=min(YY):.01:max(YY);

YFIT=lnp(2)-YYY.*YYY/2/lnp(1)^2;

hold on

plot(YYY,YFIT,'r-')
% bar(YY,NY,'r')
xlabel('y (nm)')
ylabel('ln(N)')
hold off

TT=handles.t;

NumberWindows=floor(TT(end)/WindowLength);

SignalSelect=(get(handles.PositionSignal,'value'))

if SignalSelect==1
    
    DataX=X;
    DataY=Y;
    ystring='power (nm^2/Hz)';
    
else
    
    DataX=handles.Sx;
    DataY=handles.Sy;
    ystring='power (PSDsignal^2/Hz)';
    
end

if FreqAv==1

% [Fx PSx DFx]=createPS2(DataX,SR);
% [Fy PSy DFy]=createPS2(DataY,SR);
[PSx, Fx] = OneSidedSpectrum(DataX, SR, @nowindow);
DFx=Fx(2)-Fx(1);
[PSy, Fy] = OneSidedSpectrum(DataY, SR, @nowindow);
DFy=Fy(2)-Fy(1);


deci_factor=round(str2num(get(handles.DeciFactor,'string'))/DFx);

[centFx centPSx]=centralFregion(lowF,highF,Fx,PSx,DFx);
[centFy centPSy]=centralFregion(lowF,highF,Fy,PSy,DFy);

[FX PSX]=decimate_sig(centFx,centPSx,deci_factor,'average');
[FY PSY]=decimate_sig(centFy,centPSy,deci_factor,'average');

end

if Wind==1
    
%     [FXall, PSXall,
%     PSYall]=GetWindowedPowerSpectrum(X,Y,SR,WindowLength);    %Tom's code

    [PSXall, FXall] = AverageSpectrum(DataX, SR, NumberWindows, '@nowindow');  %Jeff's Code
    [PSYall, FYall] = AverageSpectrum(DataY, SR, NumberWindows, '@nowindow');   % Gaussian window

    
    df = FXall(2)-FXall(1)
    FXall(1)
    FXall(2)
    
    if lowF<FXall(2)
        
        lowF=FXall(2)
        set(handles.LowF,'string',num2str(lowF))
        
    end
    
    if highF>FXall(end)
        
        highF=FXall(end)
        
    end
    
    [FX PSX]=centralFregion(lowF,highF,FXall,PSXall,df);
    [FY PSY]=centralFregion(lowF,highF,FXall,PSYall,df);
    
end

% 
% cd ..

axes(handles.axes2)
loglog(FY ,PSY,handles.currentstyleY,FX, PSX,handles.currentstyleX)
xlabel('freq (Hz)')
ylabel(ystring)
legend('Y','X')
title('Power Spectrum of PSD signals')

handles.fx=FX;
handles.PSx=PSX;
handles.fy=FY;
handles.PSy=PSY;

% 
% cd SubFns

R=.5*str2num(get(handles.BeadDiameter,'string'));

% Determine dynamic drag coefficient:
percentGlycerol = str2double(get(handles.PercentGlycerol, 'String'));

tempCelsius = 20; % Room temperature
CF = GlycerolWaterViscosity(tempCelsius, ...
    percentGlycerol);

% CF=1.0; % old code

beta=CF*6*pi*1e-9*R;

Px=fminsearch(@(Px) fit_Lorentzian(FX,PSX,Px),[2000 1500]);

pi2_kt=pi^2/4.11;

a1x=sqrt(pi2_kt*beta*Px(1)); %Calculate linear response
ksx=2*pi*beta*Px(2);         % Calculate trap stiffness

Py=fminsearch(@(Py) fit_Lorentzian(FY,PSY,Py),[2000 1500]);

a1y=sqrt(pi2_kt*beta*Py(1));
ksy=2*pi*beta*Py(2);



hold on
axes(handles.axes2)

Xfit=create_Lorentzian(FX,Px);
Yfit=create_Lorentzian(FY,Py);

loglog(FX,Xfit,'b-',FX,Yfit,'r-')

hold off

% cd ..

handles.FitPSx=Xfit;
handles.FitPSy=Yfit;

set(handles.Kx,'string',strcat('Kx = ',num2str(ksx),' pN/nm'))
set(handles.Ky,'string',strcat('Ky = ',num2str(ksy),' pN/nm'))
set(handles.Cx,'string',strcat('Cx = ',num2str(a1x)))
set(handles.Cy,'string',strcat('Cy = ',num2str(a1y)))
set(handles.CornerFreqX,'string',strcat('Corner frequency, x =', ...
    num2str(Px(2)),' Hz'))
set(handles.CornerFreqY,'string',strcat('Corner frequency, y =', ...
    num2str(Py(2)),' Hz'))



%Update Vlad's files
handles.vladsData{1} = ksx;
handles.vladsData{2} = ksy;

handles.vladsData{3} = KX;
handles.vladsData{4} = KY;

handles.vladsData{5} = a1x;
handles.vladsData{6} = a1y;

handles.vladsData{7} = get(handles.FileName,'string');

% Save the handles structure.
guidata(hObject,handles)


% --- Executes on button press in FitLorentzian.
function FitLorentzian_Callback(hObject, eventdata, handles)
% hObject    handle to FitLorentzian (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% cd SubFns
% 
% R=.5*str2num(get(handles.BeadDiameter,'string'));
% 
% CF=1.0;
% 
% beta=CF*6*pi*1e-9*R;
% 
% Px=fminsearch(@(Px) fit_Lorentzian(handles.fx,handles.PSx,Px),[100000 50]);
% 
% pi2_kt=pi^2/4.11;
% 
% a1x=sqrt(pi2_kt*beta*Px(1)) %Calculate linear response
% ksx=2*pi*beta*Px(2)         % Calculate trap stiffness
% 
% Py=fminsearch(@(Py) fit_Lorentzian(handles.fy,handles.PSy,Py),[100000 50]) ;
% 
% a1y=sqrt(pi2_kt*beta*Py(1))
% ksy=2*pi*beta*Py(2)
% 
% 
% hold on
% axes(handles.axes2)
% loglog(handles.fx,create_Lorentzian(handles.fx,Px),'b-',handles.fx,create_Lorentzian(handles.fx,Py),'r-')
% 
% hold off
% 
% cd ..
% 
% 
% set(handles.Kx,'string',strcat('Kx = ',num2str(ksx),' pN/nm'))
% set(handles.Ky,'string',strcat('Ky = ',num2str(ksy),' pN/nm'))
% set(handles.Cx,'string',strcat('Cx = ',num2str(a1x)))
% set(handles.Cy,'string',strcat('Cy = ',num2str(a1y)))


function LowF_Callback(hObject, eventdata, handles)
% hObject    handle to LowF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LowF as text
%        str2double(get(hObject,'String')) returns contents of LowF as a double


% --- Executes during object creation, after setting all properties.
function LowF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LowF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HighF_Callback(hObject, eventdata, handles)
% hObject    handle to HighF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HighF as text
%        str2double(get(hObject,'String')) returns contents of HighF as a double


% --- Executes during object creation, after setting all properties.
function HighF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HighF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function DeciFactor_Callback(hObject, eventdata, handles)
% hObject    handle to DeciFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DeciFactor as text
%        str2double(get(hObject,'String')) returns contents of DeciFactor as a double


% --- Executes during object creation, after setting all properties.
function DeciFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DeciFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function BeadDiameter_Callback(hObject, eventdata, handles)
% hObject    handle to BeadDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BeadDiameter as text
%        str2double(get(hObject,'String')) returns contents of BeadDiameter as a double


% --- Executes during object creation, after setting all properties.
function BeadDiameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BeadDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in SavePowerSpectrum.
function SavePowerSpectrum_Callback(hObject, eventdata, handles)
% hObject    handle to SavePowerSpectrum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%{
FilePath=handles.currentPath;

% cd SubFns

NewFilePath=nameXYfilefromPSDsignals(FilePath,'Power Spectrum')
% 
% cd ..
%}

col1=handles.fx;
col2=handles.PSx;
col3=handles.PSy;
%col4=handles.FitPSx;
%col5=handles.FitPSy;
%DATA=[col1' col2' col3' col4' col5'];

PwrSpec=[col1' col2' col3'];
uisave('PwrSpec', 'Power_Spectrum');

%save(NewFilePath,'DATA', '-ascii', '-tabs');


%%% Added by Vlad Belyy on 7/10/2011
%{
try load vlads_data1.mat
    disp('File loaded successfully')
catch
    fitData = {};
end

fitData = [fitData; handles.vladsData];

save vlads_data1.mat fitData;
%}

function WindowLength_Callback(hObject, eventdata, handles)
% hObject    handle to WindowLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WindowLength as text
%        str2double(get(hObject,'String')) returns contents of WindowLength as a double


% --- Executes during object creation, after setting all properties.
function WindowLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WindowLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in ShowX.
function ShowX_Callback(hObject, eventdata, handles)
% hObject    handle to ShowX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowX


% --- Executes on button press in ShowY.
function ShowY_Callback(hObject, eventdata, handles)
% hObject    handle to ShowY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowY




% --- Executes on button press in PowerSpectrum_noFit.
function PowerSpectrum_noFit_Callback(hObject, eventdata, handles)
% hObject    handle to PowerSpectrum_noFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.SavePowerSpectrum,'Visible','on')

X=handles.X;
Y=handles.Y;
t=handles.t;
SR=handles.SR;

WindowLength=str2num(get(handles.WindowLength,'string'))
% 
% cd SubFns

Wind=get(handles.Windowed,'Value');
FreqAv=get(handles.FrequencyAveraged,'Value');

lowF=str2num(get(handles.LowF,'string'));
highF=str2num(get(handles.HighF,'string'));

X=X-median(X);

Y=Y-median(Y);

[NX XX]=hist(X,25);
STDevX=std(X)

lnNX=log(NX);




set(handles.XStDev,'string',strcat('X StDev = ',num2str(STDevX),' nm^2'))

KX=4.11/STDevX^2
set(handles.KxEE,'string',strcat('Kx = ',num2str(KX),' pN/nm'))

axes(handles.XHist)

plot(XX,lnNX,'b*')

lnp=fminsearch(@(lnp) FitLogGaussian(XX,lnNX,lnp),[STDevX max(lnNX)])

XXX=min(XX):.01:max(XX);

XFIT=lnp(2)-XXX.*XXX/2/lnp(1)^2;

hold on

plot(XXX,XFIT,'r-')
% bar(XX,NX,'b')
xlabel('x (nm)')
ylabel('ln(N)')

hold off

[NY YY]=hist(Y,25);

STDevY=std(Y)

set(handles.YStDev,'string',strcat('Y StDev = ',num2str(STDevY),' nm^2'))

KY=4.11/STDevY^2
set(handles.KyEE,'string',strcat('Ky = ',num2str(KY),' pN/nm'))

axes(handles.YHist)

lnNY=log(NY);

plot(YY,lnNY,'b*')

lnp=fminsearch(@(lnp) FitLogGaussian(YY,lnNY,lnp),[STDevY max(lnNY)])

YYY=min(YY):.01:max(YY);

YFIT=lnp(2)-YYY.*YYY/2/lnp(1)^2;

hold on

plot(YYY,YFIT,'r-')
% bar(YY,NY,'r')
xlabel('y (nm)')
ylabel('ln(N)')
hold off

TT=handles.t;

NumberWindows=floor(TT(end)/WindowLength);

SignalSelect=(get(handles.PositionSignal,'value'))

if SignalSelect==1
    
    DataX=X;
    DataY=Y;
    ystring='power (nm^2/Hz)';
    
else
    
    DataX=handles.Sx;
    DataY=handles.Sy;
    ystring='power (PSDsignal^2/Hz)';
    
end

if FreqAv==1

% [Fx PSx DFx]=createPS2(DataX,SR);
% [Fy PSy DFy]=createPS2(DataY,SR);
[PSx, Fx] = OneSidedSpectrum(DataX, SR, @nowindow);
DFx=Fx(2)-Fx(1);
[PSy, Fy] = OneSidedSpectrum(DataY, SR, @nowindow);
DFy=Fy(2)-Fy(1);


deci_factor=round(str2num(get(handles.DeciFactor,'string'))/DFx);

[centFx centPSx]=centralFregion(lowF,highF,Fx,PSx,DFx);
[centFy centPSy]=centralFregion(lowF,highF,Fy,PSy,DFy);

[FX PSX]=decimate_sig(centFx,centPSx,deci_factor,'average');
[FY PSY]=decimate_sig(centFy,centPSy,deci_factor,'average');

end

if Wind==1
    
%     [FXall, PSXall,
%     PSYall]=GetWindowedPowerSpectrum(X,Y,SR,WindowLength);    %Tom's code

    [PSXall, FXall] = AverageSpectrum(DataX, SR, NumberWindows, '@nowindow');  %Jeff's Code
    [PSYall, FYall] = AverageSpectrum(DataY, SR, NumberWindows, '@nowindow');   % Gaussian window

    
    df = FXall(2)-FXall(1)
    FXall(1)
    FXall(2)
    
    if lowF<FXall(2)
        
        lowF=FXall(2)
        set(handles.LowF,'string',num2str(lowF))
        
    end
    
    if highF>FXall(end)
        
        highF=FXall(end)
        
    end
    
    [FX PSX]=centralFregion(lowF,highF,FXall,PSXall,df);
    [FY PSY]=centralFregion(lowF,highF,FXall,PSYall,df);
    
end

% 
% cd ..

axes(handles.axes2)
loglog(FY ,PSY,handles.currentstyleY,FX, PSX,handles.currentstyleX)
xlabel('freq (Hz)')
ylabel(ystring)
legend('Y','X')
title('Power Spectrum of PSD signals')

handles.fx=FX;
handles.PSx=PSX;
handles.fy=FY;
handles.PSy=PSY;

% 
% cd SubFns

R=.5*str2num(get(handles.BeadDiameter,'string'));

CF=1.0;

beta=CF*6*pi*1e-9*R

Px=fminsearch(@(Px) fit_Lorentzian(FX,PSX,Px),[2000 1500])

pi2_kt=pi^2/4.11;

a1x=sqrt(pi2_kt*beta*Px(1)) %Calculate linear response
ksx=2*pi*beta*Px(2)         % Calculate trap stiffness

Py=fminsearch(@(Py) fit_Lorentzian(FY,PSY,Py),[2000 1500]) 

a1y=sqrt(pi2_kt*beta*Py(1))
ksy=2*pi*beta*Py(2)

%{
hold on
axes(handles.axes2)

Xfit=create_Lorentzian(FX,Px);
Yfit=create_Lorentzian(FY,Py);

loglog(FX,Xfit,'b-',FX,Yfit,'r-')

hold off
%}

% cd ..

set(handles.Kx,'string',strcat('Kx = ',num2str(ksx),' pN/nm'))
set(handles.Ky,'string',strcat('Ky = ',num2str(ksy),' pN/nm'))
set(handles.Cx,'string',strcat('Cx = ',num2str(a1x)))
set(handles.Cy,'string',strcat('Cy = ',num2str(a1y)))


%Update Vlad's files
handles.vladsData{1} = ksx;
handles.vladsData{2} = ksy;

handles.vladsData{3} = KX;
handles.vladsData{4} = KY;

handles.vladsData{5} = a1x;
handles.vladsData{6} = a1y;

handles.vladsData{7} = get(handles.FileName,'string');

% Save the handles structure.
guidata(hObject,handles)



% --- Executes on button press in PrintSummary.
function PrintSummary_Callback(hObject, eventdata, handles)
% hObject    handle to PrintSummary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

beadSize = get(handles.BeadDiameter, 'String');

kx = num2str(handles.vladsData{1},3);
ky = num2str(handles.vladsData{2},3);

cx = num2str(handles.vladsData{5},3);
cy = num2str(handles.vladsData{6},3);

disp(['Assuming ', beadSize, 'nm bead size: Kx = ', kx, ...
    '; Ky = ', ky, '; Cx = ', cx, '; Cy =  ', cy]);




function PercentGlycerol_Callback(hObject, eventdata, handles)
% hObject    handle to PercentGlycerol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PercentGlycerol as text
%        str2double(get(hObject,'String')) returns contents of PercentGlycerol as a double


% --- Executes during object creation, after setting all properties.
function PercentGlycerol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PercentGlycerol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



