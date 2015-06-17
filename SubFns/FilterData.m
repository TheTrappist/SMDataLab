function handles = FilterData(hObject, handles)
% Filters all currently visible data filtered in accordance with given m
% method and parameters. The filtered data is saved in handles.allTraces 
% with the suffix '_filt'
%
% Written by Vladislav Belyy
% Last modified on 12/11/2013

tic % start timing

WindowLength=str2double(get(handles.WindowLength,'string'))/1000;
filterTrapPos = get(handles.FilterTrapPosCheckbox, 'Value'); %#ok<NASGU>
filterOnlyCurr = get(handles.FilterOnlyCurrentCheckbox, 'Value');
Decimate=get(handles.Decimate,'Value');
Med=get(handles.MedianFilter,'Value');
Run=get(handles.RunningMean,'Value');
Butt=get(handles.Butterworth,'Value');
L1PWC=get(handles.L1PWC,'Value');

filtTraces = struct('TraceName', '','DataRaw',[], 'Data_nm', [], ...
    'StartTime', 0, 'SamplingRate', 0, 'Visible', 1); 
filtCtr = 1;

tracesToDelete = []; % used to delete previously computed filtered traces

for i = 1:length(handles.allTraces)
    currTrace = handles.allTraces(i);
    traceName = currTrace.TraceName;
    SR = currTrace.SamplingRate;
    startTime = currTrace.StartTime;
    
    if strfind(traceName, '_filt')
        tracesToDelete = [tracesToDelete, i]; %#ok<AGROW>
    elseif currTrace.Visible %only filter currently visible traces
        
        if filterOnlyCurr % Only filter the currently displayed trace segment
            Xlimits = get(handles.axes1, 'XLim'); % in seconds
            startSample = (Xlimits(1)-startTime)*SR;
            endSample = (Xlimits(2)-startTime)*SR;
            startSample = floor(max(1,startSample));
            endSample = floor(min(length(currTrace.DataRaw),endSample));
            startSample = min(startSample, endSample-1);
            
            dataRaw = currTrace.DataRaw(startSample:endSample);
            dataNm = currTrace.Data_nm(startSample:endSample);
            startTimeFilt = startTime + startSample/SR;
        else % filter the entire trace
            dataRaw = currTrace.DataRaw;
            dataNm = currTrace.Data_nm;
            startTimeFilt = startTime;
        end
        
        % Center the data about zero before filtering
        dataRawOffset = mean(dataRaw);
        dataNmOffset = mean(dataNm);
        dataRaw = dataRaw - dataRawOffset;
        dataNm = dataNm - dataNmOffset;
        
        if Decimate
            decimFactor = str2double(...
                get(handles.DecimationFactor, 'String'));

            FilteredRaw = decimate(dataRaw, decimFactor);
            FilteredNm = decimate(dataNm, decimFactor);
            SR_filt = SR/decimFactor; % new sampling rate
            
        elseif Med %Median filtered
            FilteredRaw=medfilt1(dataRaw,WindowLength*SR);
            FilteredNm=medfilt1(dataNm,WindowLength*SR);
            SR_filt = SR;
            
        elseif Run % Running mean filter
            FilteredRaw=filter(ones(1,WindowLength*SR)/...
                (WindowLength*SR),1,dataRaw);
            FilteredNm=filter(ones(1,WindowLength*SR)/...
                (WindowLength*SR),1,dataNm);
            SR_filt = SR;
            
        elseif Butt % Butterworth filter
            CutoffFreq=str2double(get(handles.CutoffFreq,'string'))*2/SR;
            FilterOrder=str2double(get(handles.FilterOrder,'string'));
            [b,a] = butter(FilterOrder,CutoffFreq,'low');
            FilteredRaw=filter(b,a,dataRaw);
            FilteredNm=filter(b,a,dataNm);
            SR_filt = SR;
            
        elseif L1PWC % L1 piecewise-constant filter
            lambda=str2double(get(handles.lambda,'string'));
            FilteredRaw=l1tf_integ(dataRaw',lambda);
            FilteredNm=l1tf_integ(dataNm',lambda);
            SR_filt = SR;
            
        else
            FilteredRaw=dataRaw;
            FilteredNm=dataNm;
            SR_filt = SR;
      
        end
        
        FilteredRaw = FilteredRaw + dataRawOffset;
        FilteredNm = FilteredNm + dataNmOffset;
        
        % Save filtered data 
        filtTraces(filtCtr).TraceName = strcat(traceName, '_filt');
        filtTraces(filtCtr).DataRaw = FilteredRaw;
        filtTraces(filtCtr).Data_nm = FilteredNm;
        filtTraces(filtCtr).StartTime = startTimeFilt;
        filtTraces(filtCtr).SamplingRate = SR_filt;
        filtTraces(filtCtr).Visible = 1;
        filtCtr = filtCtr + 1;
    end
end

% Delete previously filtered traces:
handles.allTraces(tracesToDelete) = []; 

% Append the new data to allTraces
handles.allTraces = [handles.allTraces, filtTraces];

filteringTime = toc; % end timing
disp(['Filtered in ', num2str(filteringTime), ' seconds']);

% Save the handles structure.
guidata(hObject,handles)