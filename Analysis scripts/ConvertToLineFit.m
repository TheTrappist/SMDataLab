function ConvertToLineFit(~)
% Converts step-fitted .mat files to line-fit .mat files


% Read files
filesInFolder = ls;

for i = 1:size(filesInFolder,1)
    
    % get name of current file
    currFileName = strtrim(filesInFolder(i,:));
    
    % only try to open Mat-files
    if ~isempty(strfind(currFileName, '.mat'))
        clear stepResults
        clear lineResults
        load(currFileName);
        
        
        lineResults = struct('timeVector', [], 'dataVector', [], ...
            'lineVector', [], 'fitParams', [],  'filename', '', ...
            'runTime', [], 'runLength', [], 'timeStamp', []);
        
        disp(currFileName);
        for ii = 1:length(stepResults)
            
            % Create new line fit
            % fit to straight line
            t = stepResults(ii).timeVector;
            x = stepResults(ii).dataVector;
            linFit = polyfit(t, x, 1);
            
            
            % Determine if steps were flipped (i.e. "forward" is down)
            stepIndices = logical(real(stepResults(ii).stepVector(2:end) - ...
                stepResults(ii).stepVector(1:end-1)));
            flipSteps = stepResults(ii).stepSizes / ...
                (stepResults(ii).stepVector([false,...
                stepIndices])-stepResults(ii).stepVector(stepIndices));
            flipSteps = round(flipSteps);
            
            
            % Build line vector
            
                        
            lineResults(ii).timeVector = stepResults(ii).timeVector;
            lineResults(ii).dataVector = stepResults(ii).dataVector;
            lineResults(ii).lineVector = t*linFit(1) + linFit(2);
            
            lineResults(ii).fitParams = linFit;
            lineResults(ii).velocity = linFit(1)*flipSteps;
            %disp(flipSteps); % debugging only
            
            lineResults(ii).filename = stepResults(ii).filename;
            
            lineResults(ii).runTime = stepResults(ii).runTime;
            
            lineResults(ii).runLength = abs(linFit(1)*(t(end)-t(1)));
            
            lineResults(ii).timeStamp = stepResults(ii).timeStamp;
        end
        
        currLineFileName = strcat('linFit',currFileName);
        save(currLineFileName, 'lineResults');
        
    end
end

end

