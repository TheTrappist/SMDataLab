function handles = PlotData(hObject, handles, keepLimits)
% Plots the data on axis1
%
% If keepLimits = 1, attempts to keep previously selected Y-limits
% If keepLimits = 2, keeps the limits exactly the same
% Otherwise, resets the Y-limits to default values
%
% Written by Vladislav Belyy
% Last updated on 11/19/2013



%% Generate data to be plotted

handles = PrepDataToPlot(handles);

if keepLimits % keep the same limits despite changing units
    
    oldXlim=get(handles.axes1,'Xlim'); % save old X limit
    oldYlim=get(handles.axes1,'Ylim'); % save old Y limit
    %{
    minPos = min(handles.currentPlotPSD_Long);
    maxPos = max(handles.currentPlotPSD_Long);
    
    minT = min(handles.currentPlotT);
    maxT = max(handles.currentPlotT);
    %}
end

%% Actual plotting
% Read plotting parameters
filename = get(handles.FileName,'string'); %#ok<NASGU>

plotType=get(handles.LinesOrDots,'string');
val=get(handles.LinesOrDots,'value');
switch plotType{val};
    case 'Dots' % User selects dots
        markerStyle='.';
        lineStyle = 'none';
    case 'Lines' % User selects lines
        markerStyle = 'none';
        lineStyle = '-';
end
% Obtain current plot units
plotUnitStr=get(handles.YScaleMenu,'string'); % Current selection
plotUnitVal=get(handles.YScaleMenu,'value'); % Current selection
plotUnits = plotUnitStr(plotUnitVal);

% Create RGB plot color palette:
ColorPalette = [51 51 255; 255 102 102; 0 153 0; 204 102 0; 0 153 153; ...
     153 51 255; 198 181 70; 159 70 198];
% Duplicate for really large plot numbers...
ColorPalette = [ColorPalette; ColorPalette];
ColorPalette = ColorPalette / 256;

axes(handles.axes1) %#ok<MAXES>

plot(0,0)

hold on
plotLegends = {};
lineHandles = [];
ctrVis = 1; % Visible trace counter for plot color cycling
for i=1:length(handles.allTraces)
    
    currTrace = handles.allTraces(i);
    samplingRate = currTrace.SamplingRate;
    startTime = currTrace.StartTime;
    endTime = startTime + ((length(currTrace.DataRaw)-1) / samplingRate);
    timeVector = startTime:(1/samplingRate):endTime;
    
    if currTrace.Visible == 1
        
        if strcmp(plotUnits, 'Raw data (dimensionless)')
            data = currTrace.DataRaw;
        else
            data = currTrace.Data_nm;
        end
        
        if ~isempty(strfind(currTrace.TraceName, '_step'))
            lineWidth = 2;
        else
            lineWidth = 1;
        end
        
        h = plot(timeVector, data, 'Color', ColorPalette(ctrVis,:),...
            'Marker', markerStyle, 'LineStyle', lineStyle, ...
            'LineWidth', lineWidth);
        ctrVis = ctrVis + 1;
        lineHandles = [lineHandles; h]; %#ok<AGROW>
        plotLegends = [plotLegends; currTrace.TraceName]; %#ok<AGROW>
        
    end
end

% Populate "Active Trace" drop-down menu
set(handles.ActiveTrace, 'String', plotLegends);
set(handles.ActiveTrace, 'Value', 1);

% Generate legend and labels:
handles.currLegend = {lineHandles, plotLegends};
legend(lineHandles, plotLegends, 'Interpreter', 'none');
xlabel('Time (s)')
if strcmp(plotUnits, 'Raw data (dimensionless)')
    units = 'Dimensionless PSD units';
elseif strcmp(plotUnits, 'Force (pN)')
    units = 'Force (pN)';
else
    units = 'Distance (nm)';
end
ylabel(units, 'Interpreter', 'none')
[~, fileName, ext] = fileparts(handles.currentPath);
plotTitle = strcat(fileName, ext);
title(plotTitle, 'Interpreter', 'none')

hold off

    
if keepLimits % keep old X and Y limits
    set(handles.axes1,'Ylim', oldYlim);
    set(handles.axes1,'Xlim', oldXlim);
end
    
    
%end
% Obtain current plot units
gridLines=get(handles.GridLines,'string'); % Plot gridlines?

if strcmp(gridLines, 'Remove GridLines') % display gridlines
    
    % Determine user-specified gridline spacing
    DivString=get(handles.GridDiv,'string');
    Loc=strfind(DivString,' ');
    
    if size(Loc,1)== 0 % No units specified
        Div = str2double(DivString);
    else
        Div = str2double(DivString(1:strfind(DivString,' ')-1));
    end
    
    %Ylims=get(handles.axes1,'Ylim'); % get Y-limits

    ylims = get(handles.axes1,'Ylim');
      
    Ticks=floor(ylims(1)/Div)*Div:Div:ceil(ylims(2)/Div)*Div;
    
    set(handles.axes1,'YGrid','on')
    set(handles.axes1,'YTick',Ticks)
    
else % Do not display gridlines
    set(handles.axes1,'YGrid','off')
    
end


%% For debugging only - plot PSD1 and PSD2 channels separately in new figure

% Determine if user wants to plot individual channels in separate figure
plotRawData = get(handles.PlotAllChannels, 'value');

if plotRawData

    hMainFig = gcf; % Handle to main GUI
    
    try % Check if figure already exists
        figure(handles.hRawPSDFig);  
    catch ME%#ok<NASGU> % if not, make it
        handles.hRawPSDFig = figure;
    end
    
    samplingRate = handles.hRawPSD.SR;
    t = 0:(1/samplingRate):(size(handles.hRawPSD.Xdiff1,1)-1)/samplingRate;
    
    % if main data display is downsampled, downsample individual PSD
    % channels accordingly:
    downSamp = 1;
    Decimate=get(handles.Decimate,'Value');
    if Decimate && handles.display.filtered == 1;
            downSamp = str2double(...
                get(handles.DecimationFactor, 'String'));
            t = downsample(t, downSamp);
    end
    
    Xlim = get(handles.axes1,'Xlim'); % Keep the X limits the same
    
    axPSD(1) = subplot(4,2,1);
     plot(t, decimate(handles.hRawPSD.Xdiff1,downSamp))
    title('Xdiff 1');
    axPSD(2) = subplot(4,2,3);
    plot(t, decimate(handles.hRawPSD.Ydiff1, downSamp))
    title('Ydiff 1');
    axPSD(3) = subplot(4,2,5);
    plot(t, decimate(handles.hRawPSD.Xsum1, downSamp))
    title('Xsum 1');
    axPSD(4) = subplot(4,2,7);
    plot(t, decimate(handles.hRawPSD.Ysum1, downSamp))
    title('Ysum 1');
    
    axPSD(5) = subplot(4,2,2);
    plot(t, decimate(handles.hRawPSD.Xdiff2, downSamp))
    title('Xdiff 2');
    axPSD(6) = subplot(4,2,4);
    plot(t, decimate(handles.hRawPSD.Ydiff2, downSamp))
    title('Ydiff 2');
    axPSD(7) = subplot(4,2,6);
    plot(t, decimate(handles.hRawPSD.Xsum2, downSamp))
    title('Xsum 2');
    axPSD(8) = subplot(4,2,8);
    plot(t, decimate(handles.hRawPSD.Ysum2, downSamp))
    title('Ysum 2');
    
    set(axPSD, 'Xlim', Xlim);
    
    pause(0.1);
    
    linkaxes([axPSD,handles.axes1], 'x');
    
    figure(hMainFig) % switch focus back to main GUI
    
end

% Update handles structure
guidata(hObject, handles);


