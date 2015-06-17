function handles = CalcForce(handles)
% Calculates tether force from PSD1 and PSD2 signals
%
% Written by Vladislav Belyy
% Last updated on 3/28/2014
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

%% Calculate tether force
kRot = handles.trapStiffRotated; % rotated spring constants of both traps

ind = strcmp('Tether_force', traceNames);
if isempty(find(ind, 1)) % extension hasn't been calculated yet
    ind = strcmp('PSD1 X', traceNames);
    PSD1_longAxis = handles.allTraces(ind).Data_nm; % rotated on-axis PSD1
    
    % Calculate on-axis force from AOD trap:
    f_PSD1_longAxis = PSD1_longAxis * kRot(1,1); 
    
    ind = strcmp('PSD2 X', traceNames);
    PSD2_longAxis = handles.allTraces(ind).Data_nm;
    
    % Calculate on-axis force from piezo trap:
    f_PSD2_longAxis = (-1) * PSD2_longAxis * kRot(2,1); 
    
    samplingRate = handles.allTraces(ind).SamplingRate;
    startTime = handles.allTraces(ind).StartTime;

    % tether force is the mean of the forces measured by the two traps
    % (ideally, the two forces should be very close)
    f_tether_longAxis = (f_PSD1_longAxis + f_PSD2_longAxis) / 2;
    
    % Generate tether force trace:
    handles.allTraces(nextTraceInd).TraceName = 'Tether_force';
    handles.allTraces(nextTraceInd).Data_nm = f_tether_longAxis;
    handles.allTraces(nextTraceInd).DataRaw = f_tether_longAxis;
    handles.allTraces(nextTraceInd).SamplingRate = samplingRate;
    handles.allTraces(nextTraceInd).StartTime = startTime;
    handles.allTraces(nextTraceInd).Visible = 1;
        
    % Generate AOD trap force trace:
    nextTraceInd = nextTraceInd + 1;
    handles.allTraces(nextTraceInd).TraceName = 'AOD_force';
    handles.allTraces(nextTraceInd).Data_nm = f_PSD1_longAxis;
    handles.allTraces(nextTraceInd).DataRaw = f_PSD1_longAxis;
    handles.allTraces(nextTraceInd).SamplingRate = samplingRate;
    handles.allTraces(nextTraceInd).StartTime = startTime;
    handles.allTraces(nextTraceInd).Visible = 1;
    
   % Generate piezo trap force trace:
    nextTraceInd = nextTraceInd + 1;
    handles.allTraces(nextTraceInd).TraceName = 'Piezo_force';
    handles.allTraces(nextTraceInd).Data_nm = f_PSD2_longAxis;
    handles.allTraces(nextTraceInd).DataRaw = f_PSD2_longAxis;
    handles.allTraces(nextTraceInd).SamplingRate = samplingRate;
    handles.allTraces(nextTraceInd).StartTime = startTime;
    handles.allTraces(nextTraceInd).Visible = 1;
    
end

