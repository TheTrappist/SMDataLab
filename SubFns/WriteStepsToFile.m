function WriteStepsToFile(handles, fileName)
% Creates a new file or appends data to an already open file. Step data is
% stored in the structure stepResults, which contains the following fields:
%
% timeVector: contains the time axis, in seconds
% dataVector: contains the data that the steps are being fit to
% stepVector: contains the fitted steps. Has the same number of points as
%               dataVector and timeVector.
% rss: residual sum of squares; used to determine goodness of fit.
%       Calculated by taking sum over i for i=1:n of (yi-f(xi))^2, where
%       yi = actual data point and f(xi) = value of fitted step at that
%       time point
% rssNorm: same as above, but normalized by number of samples; in other
%       words, rss per data point. rssNorm = rss/n 
% filename: name of the original data file
% runTime: [tBegin, tEnd] - in seconds, the start and end points of the
%       step-fitter's run. Can be used to screen for overlapping regions
% stepTimes: vector containing the start times for each fitted step, in 
%       seconds
% stepSizes: vector containing the sizes, in nanometers, of all steps.
%       Contains th same number of elements as stepTimes, and stepSizes(i)
%       corresponds to stepTimes(i)
% timeStamp: time of fit as a date vector ([year month day hour minute
%       seconds]. Can be used to determine which fits are newer and which
%       are older.

% Created by Vladislav Belyy
% Last updated on 01/03/2011


% Determine if the file already exists:
loadFail = 0;

try
    load(fileName);    
catch %#ok<CTCH>
    loadFail = 1;
    disp('This file does not exist; creating a new one');
end

if loadFail % generate new stepResults structure
    stepResults = struct('timeVector', [], 'dataVector', [], ... 
        'stepVector', [], 'rss', [], 'rssNorm', [], 'filename', '', ...
        'runTime', [], 'stepTimes', [], 'stepSizes', [], 'timeStamp', []);
    
    ind = 1; % start writing to the first field of the srtucture

else
    ind = length(stepResults)+1; %#ok<NODEF> % add data to stepResults
end

% Determine which way is up and which way is down
button = questdlg( ...
    'In this trace, which direction is "forwards" for the motor?', ...
    'Select directionality','Up','Down','Up');
if strcmp(button, 'Up')
    flipSteps = 1; % do not flip steps
else
    flipSteps = -1; % flip steps
end


% Write data:

stepResults(ind).timeVector = handles.stepVectorT;
stepResults(ind).dataVector = handles.stepVectorData;
stepResults(ind).stepVector = handles.stepVector;

stepResults(ind).rss = sum((stepResults(ind).dataVector - ...
    stepResults(ind).stepVector).^2);
stepResults(ind).rssNorm = stepResults(ind).rss / ...
                                length(stepResults(ind).timeVector);

stepResults(ind).filename =  get(handles.FileName, 'String');

stepResults(ind).runTime = [stepResults(ind).timeVector(1), ...
    stepResults(ind).timeVector(end)];

% Calculate stepTimes and stepSizes:

stepIndices = logical(real(stepResults(ind).stepVector(2:end) - ...
    stepResults(ind).stepVector(1:end-1)));

stepResults(ind).stepTimes = stepResults(ind).timeVector(stepIndices);
stepResults(ind).stepSizes = (stepResults(ind).stepVector([false,...
    stepIndices])-stepResults(ind).stepVector(stepIndices))*flipSteps;

stepResults(ind).timeStamp = clock; %#ok<NASGU>

% save data
save(fileName, 'stepResults');






