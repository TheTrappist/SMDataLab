function [local_step_data, xfit] = StepProperties(time, unwound, force, start, finish)
% [local_step_data, xfit] = StepProperties(time, unwound, force, start,
% finish) calculates step properties based on the start and finish
% indices included in start and finish.  This function also compiles a
% staircase fit to the data, useful for plotting and accuracy measures.  

% Jeffrey Moffitt
% 02/14/09
% jmoffitt@berkeley.edu
% Version 02-14-09-JM

dt = time(2)-time(1); %define the time interval

xfit = NaN(1, length(unwound));

if length(start) > 1 % If there is more than one transition in the data
    for j=1:length(start) % cycle through all found transitions
        %----------------------------------------------------------------------
        % Calculate properties of the transitions
        % Duration
        local_step_data(j).transDuration = (finish(j) - start(j) + 1)*dt; 
        
        % Slope
        if finish - start > 1 % If larger than 1, can define slope
            tempFit = polyfit(time(start(j):finish(j)), ... 
                unwound(start(j):finish(j)), 1);
            local_step_data(j).transSlope = tempFit(1);
        else % otherwise, we can't--make sure the data knows this.  NaN serves as a flag
            local_step_data(j).transSlope = NaN;
        end

        % Average Force
        local_step_data(j).transAvForce = mean(force(start(j):finish(j)));

        % Average position
        local_step_data(j).transAvPos = mean(unwound(start(j):finish(j)));

        %----------------------------------------------------------------------
        % Calculate properties of the data between the transitions

        % Cases to check:  
        % 1) Is this the first transition?
        %   a) If it is, then is the transition at the start of the
        %   data?
        % 2) Is this the last transition?
        %   a) If it is, then is the transition at the end of the data?

        switch j % switch based on the number of the transition
            %----------------------------------------------------------------------
            % Case 1:  The transition is the first transition in the data
            case 1 % 
                if start(1) == 1 % Is this at the beginning?, Case1-a
                    % In this case, there is not data to define a step
                    % size or dwell time
                    local_step_data(j).stepSize = NaN;
                    local_step_data(j).stepErr = NaN;
                    local_step_data(j).dwell = NaN;
                    local_step_data(j).AvForce = NaN;
                    local_step_data(j).forceErr = NaN;
                    local_step_data(j).flag = -1;  % Raise the error flag
                    local_step_data(j).pre_index = [];
                    local_step_data(j).post_index = (finish(1)+1):(start(2)-1); % just in case
                    local_step_data(j).pre_pos = NaN;
                    local_step_data(j).pre_pos_err = NaN;
                    local_step_data(j).post_pos = NaN;
                    local_step_data(j).post_pos_err = NaN;
                    continue; % Start next for loop skipping all code below
                else %If this is not at the beginning a step can be defined
                    % Determine dwell indices
                    pre_index = 1:(start(1)-1); % The index of the data before the transition
                    post_index = (finish(1)+1):(start(2)-1); % After the transition

                    % Set step flag to indicate the beginning
                    % step--first dwell may not be defined
                    local_step_data(j).flag = 0;

                end 
            %End of case 1
            
            %----------------------------------------------------------------------
            % Case 2:  The transition is the last transition in the data
            case length(start)
                % Check to see if there is a final dwell
                if finish(end) == length(unwound) % Is this at the end?, Case2-a
                    % In this case, there is not data to define a step
                    % size since we don't know when the unwinding stopped
                    local_step_data(j).stepSize = NaN;
                    local_step_data(j).stepErr = NaN;
                    local_step_data(j).dwell = NaN;
                    local_step_data(j).AvForce = NaN;
                    local_step_data(j).forceErr = NaN;
                    local_step_data(j).flag = -1;  % Raise the error flag
                    local_step_data(j).pre_index = (finish(end-1)+1):(start(end)-1);
                    local_step_data(j).post_index = [];
                    local_step_data(j).pre_pos = NaN;
                    local_step_data(j).pre_pos_err = NaN;
                    local_step_data(j).post_pos = NaN;
                    local_step_data(j).post_pos_err = NaN;
                    continue; % Start next for loop skipping all code below
                else % If there is a final dwell the step can be defined
                    % Determine dwell indices
                    pre_index = (finish(j-1)+1):(start(end)-1); % The index of the data before the transition
                    post_index = (finish(end)+1):length(unwound); % After the transition

                    % Set step flag to indicate the last step
                    % i.e. the final dwell is not completely defined--probably not a problem
                    local_step_data(j).flag = 2;
                end 
            % End Case 2
            
            %----------------------------------------------------------------------
            % Case 3:  The transition is in the middle of the data
            otherwise % This is the default case:  a transition that is neither the first or last
                % Determine dwell indices
                pre_index = (finish(j-1)+1):(start(j)-1); % The index of the data before the transition
                post_index = (finish(j)+1):(start(j+1)-1); % After the transition

                % Set step flag to indicate a middle step, with
                % well defined preceding and succeding dwells
                local_step_data(j).flag = 1;    
            % End of otherwise case
            
        end % End the switch statement
        
        %----------------------------------------------------------------------
        % Calculate step properties
        
        % Save pre and post dwell indices for later use if needed
        local_step_data(j).pre_index = pre_index; 
        local_step_data(j).post_index = post_index;

        % Save dwell time
        local_step_data(j).dwell = length(pre_index)*dt;

        % Calculate dwell positions
        pre_pos = mean(unwound(pre_index));
        pre_pos_err = std(unwound(pre_index))/sqrt(length(pre_index));
        post_pos = mean(unwound(post_index));
        post_pos_err = std(unwound(post_index))/sqrt(length(post_index));

        local_step_data(j).pre_pos = pre_pos;
        local_step_data(j).pre_pos_err = pre_pos_err;
        local_step_data(j).post_pos = post_pos;
        local_step_data(j).post_pos_err = post_pos_err;
        % errors are the standard error of the mean

        % Calculate step size
        local_step_data(j).stepSize = post_pos-pre_pos;
        local_step_data(j).stepErr = sqrt(pre_pos_err^2 + post_pos_err^2);

        % Calculate forces during pre dwell
        local_step_data(j).AvForce = mean(force(pre_index));
        local_step_data(j).forceErr = std(force(pre_index))/sqrt(length(pre_index));
        
        %----------------------------------------------------------------------
        % Create staircase fit
        
        % Dwells
        xfit(pre_index) = pre_pos*ones(1, length(pre_index));
        xfit(post_index) = post_pos*ones(1, length(post_index));
        
        % Transition
        slope = (post_pos - pre_pos)/(finish(j)-start(j) + 2);
        xfit(start(j):finish(j)) = pre_pos + slope*(1:(finish(j)-start(j)+1));
    end % End the for loop for the step transition

else % If there is only one transition in the data
    %----------------------------------------------------------------------
    % Calculate properties of the transitions

    % Duration
    local_step_data(1).transDuration = (finish - start + 1)*dt; 

    % Slope
    if finish - start > 1 % If larger than 1, can define slope
        tempFit = polyfit(time(start(1):finish(1)), ... 
            unwound(start(1):finish(1)), 1);
        local_step_data(1).transSlope = tempFit(1);
    else % otherwise, we can't--make sure the data knows this.  NaN serves as a flag
        local_step_data(1).transSlope = NaN;
    end

    % Average Force
    local_step_data(1).transAvForce = mean(force(start(1):finish(1)));

    % Average position
    local_step_data(1).transAvPos = mean(unwound(start(1):finish(1)));
    
    if start(1)==1 % If the transition is at the beginning of the data
        local_step_data(1).stepSize = NaN;
        local_step_data(1).stepErr = NaN;
        local_step_data(1).dwell = NaN;
        local_step_data(1).AvForce = NaN;
        local_step_data(1).forceErr = NaN;
        local_step_data(1).flag = -1;  % Raise the error flag
        local_step_data(1).pre_index = [];
        local_step_data(1).post_index = (finish(1)+1):unwound(end); % just in case
        local_step_data(1).pre_pos = NaN;
        local_step_data(1).pre_pos_err = NaN;
        local_step_data(1).post_pos = NaN;
        local_step_data(1).post_pos_err = NaN;
    else
        if finish(end) == length(unwound)
            local_step_data(1).stepSize = NaN;
            local_step_data(1).stepErr = NaN;
            local_step_data(1).dwell = NaN;
            local_step_data(1).AvForce = NaN;
            local_step_data(1).forceErr = NaN;
            local_step_data(1).flag = -1;  % Raise the error flag
            local_step_data(1).pre_index = 1:(start(1)-1);
            local_step_data(1).post_index = [];
            local_step_data(1).pre_pos = NaN;
            local_step_data(1).pre_pos_err = NaN;
            local_step_data(1).post_pos = NaN;
            local_step_data(1).post_pos_err = NaN;
        else
            % Determine dwell indices
            pre_index = 1:(start(1)-1); % The index of the data before the transition
            post_index = (finish(1)+1):length(unwound); % After the transition     

            %----------------------------------------------------------------------
            % Calculate step properties

            % Save pre and post dwell indices for later use if needed
            local_step_data(1).pre_index = pre_index; 
            local_step_data(1).post_index = post_index;

            % Save dwell time
            local_step_data(1).dwell = length(pre_index)*dt;

            % Calculate dwell positions
            pre_pos = mean(unwound(pre_index));
            pre_pos_err = std(unwound(pre_index))/sqrt(length(pre_index));
            post_pos = mean(unwound(post_index));
            post_pos_err = std(unwound(post_index))/sqrt(length(post_index));

            local_step_data(1).pre_pos = pre_pos;
            local_step_data(1).pre_pos_err = pre_pos_err;
            local_step_data(1).post_pos = post_pos;
            local_step_data(1).post_pos_err = post_pos_err;
            % errors are the standard error of the mean

            % Calculate step size
            local_step_data(1).stepSize = post_pos-pre_pos;
            local_step_data(1).stepErr = sqrt(pre_pos_err^2 + post_pos_err^2);

            % Calculate forces during pre dwell
            local_step_data(1).AvForce = mean(force(pre_index));
            local_step_data(1).forceErr = std(force(pre_index))/sqrt(length(pre_index));
            
            %----------------------------------------------------------------------
            % Create staircase fit
        
            % Dwells
            xfit(pre_index) = pre_pos*ones(1, length(pre_index));
            xfit(post_index) = post_pos*ones(1, length(post_index));

            % Transition
            slope = (post_pos - pre_pos)/(finish(1)-start(1) + 2);
            xfit(start(1):finish(1)) = pre_pos + slope*(1:(finish(1)-start(1)+1));
            
            % Set step flag to indicate a step with a ill-defined first
            % dwell
            local_step_data(1).flag = 0;  
        end
    end
end


