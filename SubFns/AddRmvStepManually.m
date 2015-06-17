function handles = AddRmvStepManually(hObject, handles, clickX)
% Adds or removes a step where the user clicked on the axes

% Find step trace:
for i = 1:length(handles.allTraces) 
    traceName = handles.allTraces(i).TraceName;
    
    if ~isempty(strfind(traceName, '_step'))
        stepTraceInd = i;
        break;
    end
end


%hSteps = handles.stepLineHandle; % handle to the plotted step line

scaledStepsT = handles.stepVectorT; % in seconds
%scaledStepsX = get(hSteps, 'YData'); % in nanometers

% find the index of the time point closest to the point the user clicked on
[~, indexT] = min(abs(scaledStepsT - clickX));

%find x-value at current time:
currX = handles.stepVector(indexT);

% find index of previous step:
diffPrev = handles.stepVector(1:indexT) - currX;
prevStepIndex = find(diffPrev, 1, 'last');
if isempty(prevStepIndex)
    prevStepIndex = 1;
end

% find index of next step:
diffNext = handles.stepVector(indexT:end) - currX;
nextStepIndex = find(diffNext, 1, 'first') + indexT;
if isempty(nextStepIndex)
    nextStepIndex = length(handles.stepVector);
end

% determine if a step is being added or deleted:
addStep = strcmp(get(handles.AddDeleteStep, 'String'), 'Add');
if addStep
    %disp('Adding')
    
    prevStepLevel = ...
        mean(handles.stepVectorData(prevStepIndex:indexT));
    nextStepLevel = ...
        mean(handles.stepVectorData(indexT:nextStepIndex));
    
    % adjust the step array
    handles.stepVector(prevStepIndex:indexT) = ...
        ones(1,indexT - prevStepIndex + 1) * prevStepLevel;
    handles.stepVector(indexT:nextStepIndex) = ...
        ones(1,nextStepIndex - indexT + 1) * nextStepLevel;
    
    
else % remove a step
    %disp('Removing')
    
    if (nextStepIndex-indexT) > (indexT-prevStepIndex)
    % remove previous step
        
        % find index of step before the step being deleted:
        prevStepX = handles.stepVector(prevStepIndex);
        diffPrev = handles.stepVector(1:prevStepIndex) - prevStepX;
        prePrevStepIndex = find(diffPrev, 1, 'last');
        
        % Case where user selects very first step:
        if isempty(prePrevStepIndex)
            prePrevStepIndex = 1;
        end
    
        newStepLevel = ...
        mean(handles.stepVectorData(prePrevStepIndex:nextStepIndex));
        
        % adjust the step array
        handles.stepVector(prePrevStepIndex:nextStepIndex) = ...
            ones(1,nextStepIndex - prePrevStepIndex + 1) * newStepLevel;
    
    else
    % remove next step
         % find index of step after the step being deleted:
        nextStepX = handles.stepVector(nextStepIndex);
        diffNext = handles.stepVector(nextStepIndex:end) - nextStepX;
        nextNextStepIndex = find(diffNext, 1, 'first') + nextStepIndex;
        
        % Case where user selects very last step:
        if isempty(nextNextStepIndex)
            nextNextStepIndex = length(handles.stepVector);
        end
        
        newStepLevel = ...
        mean(handles.stepVectorData(prevStepIndex:nextNextStepIndex));
        
        % adjust the step array
        handles.stepVector(prevStepIndex:nextNextStepIndex) = ...
            ones(1,nextNextStepIndex - prevStepIndex + 1) * newStepLevel;
    
    end
end

handles.allTraces(stepTraceInd).Data_nm = handles.stepVector;
handles.allTraces(stepTraceInd).DataRaw = handles.stepVector;

keepLimits = 2; % keep Y-limits strictly the same
handles = PlotData(hObject, handles, keepLimits); % Re-plot data

