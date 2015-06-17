function [stepSizes, dwellTimesLong, dwellTimesShort] = ...
             StepsDwellsBetweenLarge(sizeCutoff, shortestDwellUsed) 
% Plots separate histograms of small and large steps, with the cutoff 
% determined by sizeCutoff

% ShortestDwellUsed is in seconds

% Read files
filesInFolder = ls;
numBeads = 0;
stepSizes = [];
dwellTimesShort = []; % dwell times of short steps
dwellTimesLong = []; % dwell times of long steps
dwellTimesAll = []; % All dwell times
for i = 1:size(filesInFolder,1)
    
    % get name of current file
    currFileName = strtrim(filesInFolder(i,:));
    
    % only try to open Mat-files
    if ~isempty(strfind(currFileName, '.mat'))
        clear stepResults
        load(currFileName);
        disp(currFileName);
        
        % read velocities from file
        for ii = 1:length(stepResults)
            currStepSizes = stepResults(ii).stepSizes;
            currDwellTimes = stepResults(ii).stepTimes(2:end)-...
                stepResults(ii).stepTimes(1:end-1);
            stepSizes = [stepSizes, currStepSizes];
            indShortSteps = abs(currStepSizes) < sizeCutoff;
            indShortSteps = indShortSteps(2:end);
            
            indLongSteps = ~indShortSteps; % time indices of long steps
            timeLongSteps = stepResults(ii).stepTimes(indLongSteps);
            
            currDwellTimesLong = timeLongSteps(2:end) - ...
                                            timeLongSteps(1:end-1);
            
            currDwellTimesShort = currDwellTimes(indShortSteps);
            dwellTimesShort = [dwellTimesShort, currDwellTimesShort];
            dwellTimesLong = [dwellTimesLong, currDwellTimesLong];
            dwellTimesAll = [dwellTimesAll, currDwellTimes];
        end
        
        % Add one bead to bead count
        numBeads = numBeads + 1;
    end
end

 

% Plot

fig1 = figure;
set(fig1, 'Position', [300, 100, 1000, 750]);  

subplot(2,3,1)
hist(stepSizes, 50);
[AvgNeg, AvgPos] = CalcStepSize(stepSizes);
title(['Average steps: ', num2str(AvgNeg, 3), ' nm and ',...
    num2str(AvgPos, 3), ' nm']); 
xlabel('nm'); ylabel('counts')

subplot(2,3,2)
hist(dwellTimesShort, 50);
title('Short steps histogram'); 
xlabel('sec');
ylabel('counts')


subplot(2,3,3) % Plot and fit normalized dwells
sortShort = sort(dwellTimesShort);
shortY = ((1:length(sortShort))-0.5) ./ length(sortShort);

xOffset = find(sortShort >= shortestDwellUsed, 1);
truncShort = sortShort(xOffset:end)-shortestDwellUsed;

% fit to single exponential:
kShort = expfit(truncShort);

xShort = linspace(0,1.1*max(truncShort)); % grid for plotting
xShortAdj = xShort+shortestDwellUsed;
yOffset = shortY(xOffset);
yScaling = 1 - yOffset;

% Plot
hold on
stairs(sortShort, shortY, 'k-'); % Plot data cdf
plot(xShortAdj,yOffset+yScaling*(expcdf(xShort,kShort)), 'r--'); %plot fit
title(['Short steps k = ', num2str(kShort.^(-1), 3), ' sec^-^1']);
xlabel('sec');
ylabel('Cumulative probability')
hold off


% Plot all steps
subplot(2,3,4)
sortAll = sort(dwellTimesAll);
AllY = ((1:length(sortAll))-0.5) ./ length(sortAll);

xOffset = find(sortAll >= shortestDwellUsed, 1);
truncAll = sortAll(xOffset:end)-shortestDwellUsed;

% fit to single exponential:
kAll = expfit(truncAll);

xAll = linspace(0,1.1*max(truncAll)); % grid for plotting
xAllAdj = xAll+shortestDwellUsed;
yOffset = AllY(xOffset);
yScaling = 1 - yOffset;

% Plot
hold on
stairs(sortAll, AllY, 'k-'); % Plot data cdf
plot(xAllAdj,yOffset+yScaling*(expcdf(xAll,kAll)), 'r--'); %plot fit
title(['All steps k = ', num2str(kAll.^(-1), 3), ' sec^-^1']);
xlabel('sec');
ylabel('Cumulative probability')
hold off





subplot(2,3,5)
hold on
hist(dwellTimesLong, 50)
title('Long steps histogram');
xlabel('sec');
ylabel('counts')
hold off


subplot(2,3,6) % Plot and fit normalized dwells
sortLong = sort(dwellTimesLong);
LongY = ((1:length(sortLong))-0.5) ./ length(sortLong);

xOffset = find(sortLong >= shortestDwellUsed, 1);
truncLong = sortLong(xOffset:end)-shortestDwellUsed;

% fit to single exponential:
kLong = expfit(truncLong);

xLong = linspace(0,1.1*max(truncLong)); % grid for plotting
xLongAdj = xLong+shortestDwellUsed;
yOffset = LongY(xOffset);
yScaling = 1 - yOffset;

% Plot
hold on
stairs(sortLong, LongY, 'k-'); % Plot data cdf
plot(xLongAdj,yOffset+yScaling*(expcdf(xLong,kLong)), 'r--'); %plot fit
title(['Long steps k = ', num2str(kLong.^(-1), 3), ' sec^-^1']);
xlabel('sec');
ylabel('Cumulative probability')
hold off

disp(['Number of beads: ', num2str(numBeads)]);


function [AvgNeg, AvgPos] = CalcStepSize(stepSizes)
%CALCAVGSTEPSIZE Returns average negative and positive step size

stepSizes = sort(stepSizes);

firstPos = find(stepSizes > 0,1, 'first');

AvgNeg = mean(stepSizes(1:firstPos-1));
AvgPos = mean(stepSizes(firstPos:end));




