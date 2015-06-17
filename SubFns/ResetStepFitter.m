function handles = ResetStepFitter(handles)
% RESETSTEPFITTER resets the parameters of the step-fitter, deletes the 
% current steps, and makes the Manual button invisible

% Written by Vladislav Belyy
% Last modified on 7/14/2014


set(handles.FitSteps, 'String', 'FIT');

set(handles.ManualStepFitting, 'Visible', 'off');
set(handles.ManualStepFitting, 'String', 'Adjust');

set(handles.SaveSteps, 'Visible', 'off');
set(handles.text72, 'Visible', 'off');
set(handles.AddDeleteStep, 'Visible', 'off');

iptPointerManager(handles.figureHandle, 'disable')


%% Delete all step traces
i = 1;
while i <= length(handles.allTraces)
    
    traceName = handles.allTraces(i).TraceName;
    
    if ~isempty(strfind(traceName, '_step'))
        allTracesNew = ...
            [handles.allTraces(1:i-1), handles.allTraces(i+1:end)];
        handles.allTraces = allTracesNew;
        i = i-1;
    end
    i = i+1;
end



