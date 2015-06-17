function [step_data, helicase_data] = HelicaseStepFinder(helicases, helicase_data, param)
% [step_data, helicase_data] = HelicaseStepFinder(helicases, helicase_data, [filtWin, tWin, threshold, display])
% uses the Student's t-test to identify step transitions in helicase
% unwinding data.  Raw data are filtered and decimated by filtWin points,
% and the t-test is performed using a window of tWin number of points.
% Stepping transitions are determined as the set of contiguous points that
% have a t-probability less than or equal to threshold.

% Jeffrey Moffitt
% 2/14/09: Revised 2/15/09
% jmoffitt@berkeley.edu
% Version: 2-15-09-JM

%--------------------------------------------------------------------------
% Default parameters
if nargin < 3
    prompts = {'Filter Window', 'T Window', 'Threshold', 'Display (Yes=1, No=0)'};
    defaults = {'25','10','1e-4','0'};
    param = getnumbers('Enter parameters:',prompts,defaults);
end
filtWin = param(1);
tWin = param(2);
threshold = param(3);
display_choice = param(4); % This parameter is not used in this version

%--------------------------------------------------------------------------
% Main loop

helID_display = [];
step_data = [];

for i = 1:length(helicase_data)
    %----------------------------------------------------------------------
    %Initial display
    
    % Get helicase ID and step ID for the ith element of helicase_data
    hID = helicase_data(i).hID;
    stID = helicase_data(i).stID; 
    
    % Display the current helicase
    if ~ismember(hID, helID_display)
        display(['Calculating T Test for helicase # ' num2str(hID) ': ' helicases(hID).file]);
        helID_display = [helID_display hID]; % Add the displayed helicase to the list
    end
    
    %----------------------------------------------------------------------
    % Filtering data
    % Define useful temporary variables
    unwound = helicases(hID).unwound{stID};
    time = helicases(hID).time{stID};
    force = helicases(hID).force{stID};
    
    % Check length
    if length(unwound) < 3*filtWin*tWin
        display(['Unwinding trace ' num2str(stID) ' of ' helicase_data(i).file ' is too short']);
        helicase_data(i).t = [];
        helicase_data(i).sgn = [];
        helicase_data(i).filtWin = filtWin;
        helicase_data(i).tWin = tWin;
        break;
    end
    
    % Filter and decimate data
    unwoundFilt = FilterAndDecimate(unwound, filtWin);
    timeFilt = FilterAndDecimate(time, filtWin);
    forceFilt = FilterAndDecimate(force, filtWin);
    
    dt = timeFilt(2) - timeFilt(1);  % Time interval per point
   
    %----------------------------------------------------------------------
    % Calculate the t-test
    [t, sgn] = TTestWindow(unwoundFilt, tWin, 'CalSign');
    % Save values
    helicase_data(i).t = t'; % Change vertical into horizontal array
    helicase_data(i).sgn = sgn';
    helicase_data(i).filtWin = filtWin;
    helicase_data(i).tWin = tWin;

    %----------------------------------------------------------------------
    % Find steps
    
    % Find the points less than or equal to the probability threshold
    trans = sgn' <= threshold; 
    % create arrays for edge finding (0 to 1 transitions)
    left = [0 trans(1:(end-1))];  
    right = [trans(2:end) 0]; 
    %The zeros pad the data so that transitions that start or end at the
    %beginning or end of the data are recorded as starting or ending there
    
    % The start of the transitions are data where the current point trips
    % the threshold but points to the left do not
    transStart = find(left == 0 & trans == 1); 
    % The end of the transitions are data where the current point trips the
    % threshold but points to the right do not
    transFinish = find(trans == 1 & right == 0);
    
    %----------------------------------------------------------------------
    % Calculate properties of the steps
    
    if isempty(transStart) %Where there any transitions found?
        local_step_data = [];
        xfit = NaN(1, length(unwound));
    else % If there are transitions found, calculate their properties       
        [local_step_data, xfit] = StepProperties(timeFilt, unwoundFilt, forceFilt, transStart, transFinish);
    end
    
    % Save the step data structure locally with each unwinding trace
    helicase_data(i).step_data = local_step_data; 
    helicase_data(i).stepFit = xfit;
    
    % Compute the sum of squares for the fit as an estimator of the
    % goodness of fit
    if ~isempty(local_step_data)
        ValidIndex = find(~isnan(xfit));
        helicase_data(i).gof = sum((unwoundFilt(ValidIndex) - xfit(ValidIndex)).^2);
    end
    
    % Compile the step data into an aggregate data structure
    step_data = [step_data local_step_data];
           
    end
end
