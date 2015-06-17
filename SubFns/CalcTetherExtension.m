function handles = CalcTetherExtension(handles)
% Calculates tether extension from PSD1,PSD2, and trap position signals
%
% Written by Vladislav Belyy
% Last updated on 11/20/2013
%
% This function assumes that the PSD signals and trap positions have 
% already been rotated along the angle between the two beads (this is done
% in the file loading routine)

%% Get all the necessary data

% Build array of trace names:
traceNames = cell(length(handles.allTraces),1);
for i = 1:length(handles.allTraces)
    traceNames{i} = handles.allTraces(i).TraceName;
end

nextTraceInd = i+1; %index to insert new traces

%% Calculate long axis extension
ind = strcmp('Long axis_extn', traceNames);
if isempty(find(ind, 1)) % extension hasn't been calculated yet
    ind = strcmp('PSD1 X', traceNames);
    PSD1_longAxis = handles.allTraces(ind).Data_nm;
    
    ind = strcmp('PSD2 X', traceNames);
    PSD2_longAxis = handles.allTraces(ind).Data_nm;
    
    ind = strcmp('AOD Trap X', traceNames);
    AODTrap_longAxis = handles.allTraces(ind).Data_nm;
    
    ind = strcmp('Piezo Trap X', traceNames);
    PiezoTrap_longAxis = handles.allTraces(ind).Data_nm;
    samplingRate = handles.allTraces(ind).SamplingRate;
    startTime = handles.allTraces(ind).StartTime;
    
    xOffset = handles.trapOffsets(1);
    yOffset = handles.trapOffsets(2);
    ANG = handles.trackAngle;
    
    offsetLength = xOffset*cos(ANG) + yOffset*sin(ANG);
    
    distBetweenTraps = PiezoTrap_longAxis - AODTrap_longAxis + offsetLength;
    
    extension = PSD2_longAxis - PSD1_longAxis + distBetweenTraps;
    
    handles.allTraces(nextTraceInd).TraceName = 'Long axis_extn';
    handles.allTraces(nextTraceInd).Data_nm = extension;
    handles.allTraces(nextTraceInd).DataRaw = extension;
    handles.allTraces(nextTraceInd).SamplingRate = samplingRate;
    handles.allTraces(nextTraceInd).StartTime = startTime;
    handles.allTraces(nextTraceInd).Visible = 1;
    
    % Save distance between trap centers
    nextTraceInd = nextTraceInd + 1;
    handles.allTraces(nextTraceInd).TraceName = 'Distance between traps';
    handles.allTraces(nextTraceInd).Data_nm = distBetweenTraps;
    handles.allTraces(nextTraceInd).DataRaw = distBetweenTraps;
    handles.allTraces(nextTraceInd).SamplingRate = samplingRate;
    handles.allTraces(nextTraceInd).StartTime = startTime;
    handles.allTraces(nextTraceInd).Visible = 1;
    
end



