function handles = PlotData_PS(hObject, handles, keepLimits)
% Plots the trap data with all the current settings.
% Generates the following variables in handles: currentPlotT, 
% currentPlotPSD_Long, currentPlotPSD_Short, currentPlotTrap_Long,
% and currentPlotTrap_Short
% If keepLimits = 1, attempts to keep previously selected Y-limits
% Otherwise, resets the Y-limits to default values
%
% Modified from Tom Builyard's files PlotMainData.m and SaveYScale.m 
% by Vladislav Belyy
% Last updated on 11/18/2011



%method=1 for PS, =0 for Data display

%% Generate data to be plotted

doNotCenter = 0; % used to turn off centering if 'Dimensionless PSD units'
                 % is selected
allowTrapPosDisplay = 0; % only allowed if position signals are in nm and 
 % rotated; otherwise, displaying trap position makes no sense

if keepLimits % keep the same limits despite changing units
  
    oldXlim=get(handles.axes1,'Xlim'); % save old X limit
    oldYlim=get(handles.axes1,'Ylim'); % save old Y limit
    
    minPos = min(handles.currentPlotPSD_Long);
    maxPos = max(handles.currentPlotPSD_Long);
    
    minT = min(handles.currentPlotT);
    maxT = max(handles.currentPlotT);
end


% Obtain current plot type
str=get(handles.YScaleMenu,'string'); % cell array of selection options
val=get(handles.YScaleMenu,'value'); % Current selection

% Generate appropriate data array
switch str{val};
    case 'Dimensionless PSD units'
        handles.currentPlotPSD_Long=handles.rawPSD1Data_X;
        handles.currentPlotPSD_Short=handles.rawPSD1Data_Y;
        handles.currentPlotT=handles.t;
        handles.currentYlabel='PSD signal (dimensionless units)';
        doNotCenter = 1; % Tell program to bypass centering
        
        %{
        if method==0
            set(handles.SaveFile,'Visible','off')
            set(handles.GridDiv,'string','0.02 units')
        end
        CurrentSelection='1: PSD signal'
        PrevSelection=handles.Ytype;
        PrevScale=handles.Yaxis;
        %}
       
    case 'Force (pN)'
        
        % Re-rotate signals
        ANG = handles.trackAngle;
        % generate backwards rotation matrix:
        M = [cos(-ANG) sin(-ANG); -sin(-ANG) cos(-ANG)]; 
        
        if handles.display.filtered % Filtered trace
            X = handles.PSD1Data_Long_Filt;
            Y = handles.PSD1Data_Short_Filt;
        else % not filtered
            X = handles.PSD1Data_Long;
            Y = handles.PSD1Data_Short;
        end
        S=[X;Y];

        D=M*S; % the actual rotation happens here

        x=D(1,:);
        y=D(2,:);
        
        Xforce=x*handles.KX;
        Yforce=y*handles.KY;
        
        % Rotate the final force signals back
        SS=[Xforce;Yforce];
        MM=[cos(ANG) sin(ANG); -sin(ANG) cos(ANG)]; % forwards rot. matrix
        DD=MM*SS;

        ForceXX=DD(1,:);
        ForceYY=DD(2,:);
        
        handles.currentPlotPSD_Long=ForceXX;
        handles.currentPlotPSD_Short=ForceYY;
        handles.currentPlotT=handles.t;
        
        handles.currentYlabel='Force (pN)';
 
        
    case 'nm and rotated' 
        
        if handles.display.filtered % Filtered trace
            handles.currentPlotPSD_Long = handles.PSD1Data_Long_Filt;
            handles.currentPlotPSD_Short = handles.PSD1Data_Short_Filt;
        else % Not filtered
            handles.currentPlotPSD_Long = handles.PSD1Data_Long;
            handles.currentPlotPSD_Short = handles.PSD1Data_Short;
        end
        handles.currentPlotT = handles.t;
        
        handles.currentYlabel='position (nm)';
        
        allowTrapPosDisplay = 1; % Allow trap position to be displayed
        
        % Subtract trap position from signal in force clamp traces:
        if strcmp(handles.recordingType, 'Force clamp')
            handles.currentPlotPSD_Long = handles.currentPlotPSD_Long + ...
                handles.trapPosLong;
            
            handles.currentPlotPSD_Short = handles.currentPlotPSD_Short ...
                + handles.trapPosShort;
        end

        %{
        if method==0
            set(handles.SaveFile,'Visible','on')
            set(handles.SaveFile,'string','Save t,X,Y File')
            set(handles.GridDiv,'string','8 nm')
        end
        CurrentSelection='3: nm and rotated'
        PrevSelection=handles.Ytype;
        PrevScale=handles.Yaxis;
        %}
end


%% Center traces, if necessary
if ~doNotCenter % doNotCenter is true if you plot dimensionless PSD signals
    if (handles.display.center == 1) % median centering
        medianValueX = median(handles.currentPlotPSD_Long);
        medianValueY = median(handles.currentPlotPSD_Short);

        handles.currentPlotPSD_Long = ...
            handles.currentPlotPSD_Long - medianValueX;

        handles.currentPlotPSD_Short = ...
            handles.currentPlotPSD_Short - medianValueY;
    
    elseif (handles.display.center == 2) % user value centeting
        centerValueX = str2double(get(handles.XOffset,'String'));
        centerValueY = str2double(get(handles.YOffset,'String'));

        handles.currentPlotPSD_Long = ...
            handles.currentPlotPSD_Long - centerValueX;

        handles.currentPlotPSD_Short = ...
            handles.currentPlotPSD_Short - centerValueY;
    end
end


%% Adjust display limits

if keepLimits % attempt to keep the same limits despite changing units
    
    minPosNew = min(handles.currentPlotPSD_Long);
    maxPosNew = max(handles.currentPlotPSD_Long);
    
    minTNew = min(handles.currentPlotT);
    maxTNew = max(handles.currentPlotT);
    
    % linear transformation; newLim = m*(oldLim) + b
    % first, find coeffs mx and bx for position and mt and bt for time
    mx =  (minPosNew - maxPosNew) / (minPos - maxPos);
    bx = minPosNew - mx*minPos;
    
    mt =  (minTNew - maxTNew) / (minT - maxT);
    bt = minTNew - mx*minT;
    
    % Transform old limits into new limits:
    newXlim = mt*oldXlim + bt;
    newYlim = mx*oldYlim + bx;
end
    
    




%% Actual plotting

% Read plotting parameters
filename = get(handles.FileName,'string');
dispLong = get(handles.ShowX,'value'); % Plot long axis?
dispShort = get(handles.ShowY,'value'); % plot short axis?

plotType=get(handles.LinesOrDots,'string');
val=get(handles.LinesOrDots,'value');

switch plotType{val};
case 'Dots' % User selects peaks
   handles.currentstyleX='b.';
   handles.currentstyleY='r.';
case 'Lines' % User selects membrane
   handles.currentstyleX = 'b-';
   handles.currentstyleY = 'r-';
end

axes(handles.axes1)

plot(0,0)

hold on

if dispShort == 1 % Display short axis

    plot(handles.currentPlotT,handles.currentPlotPSD_Short, ...
        handles.currentstyleY)

end

if dispLong == 1 % Display long axis

    plot(handles.currentPlotT,handles.currentPlotPSD_Long, ...
        handles.currentstyleX)

end

if handles.display.trapPos && allowTrapPosDisplay % Display trap position
    
    plot(handles.currentPlotT,handles.trapPosLong, ...
        handles.currentstyleTrap)
end

xlabel(handles.currentXlabel);
ylabel(handles.currentYlabel);
title(filename,'Interpreter','none')

% Determine the legend
LogCase = 2*dispLong + dispShort;
if LogCase==1
    
    
    legend('Y')

elseif LogCase==2
    
    if handles.display.trapPos && allowTrapPosDisplay
        legend('X', 'Trap position');
    else
        legend('X');
    end
    
elseif LogCase==3
    
    if handles.display.trapPos && allowTrapPosDisplay
        legend('X','Y', 'Trap position');
    else
        legend('X','Y');
    end
    
end

hold off


if keepLimits == 1 % keep old X and Y limits   
    set(handles.axes1,'Ylim', newYlim);
    set(handles.axes1,'Xlim', newXlim);
end


if handles.display.gridLines % display gridlines
    
    % Determine user-specified gridline spacing
    DivString=get(handles.GridDiv,'string');
    Loc=strfind(DivString,' ');

    if size(Loc,1)==0 % No units specified
        Div = str2double(DivString);
    else
        Div = str2double(DivString(1:strfind(DivString,' ')-1));
    end

    Ylims=get(handles.axes1,'Ylim'); % get Y-limits
    
    
    % Generate ticks
    Ticks=floor(Ylims(1)/Div)*Div:Div:ceil(Ylims(2)/Div)*Div;
    
    set(handles.axes1,'YGrid','on')
    set(handles.axes1,'YTick',Ticks)

else % Do not display gridlines
    set(handles.axes1,'YGrid','off')

end

% Update handles structure
guidata(hObject, handles);