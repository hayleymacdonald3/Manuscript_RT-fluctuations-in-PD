function [edata, td] = exp_trial_check_response(edata, td)
% Check outcome of subject response

    left_responded = ~isnan(td.left_rt);
    right_responded = ~isnan(td.right_rt);
    left_rt_deviation = abs(td.left_rt - edata.parameters.time_target);
    left_miss = left_rt_deviation > edata.parameters.time_tolerance;
    
    % So the user doesnt get confused if the arduino thinks they missed but
    % the display says that they didnt 
    % td.outcome == 'stop - arduino miss' || td.outcome == 'go - arduino miss'
    left_display_deviation = abs(edata.left_bar_stop_percent - edata.parameters.time_target);
    left_display_miss = left_display_deviation > edata.parameters.time_tolerance;
    
    right_rt_deviation = abs(td.right_rt - edata.parameters.time_target);
    right_miss = right_rt_deviation > edata.parameters.time_tolerance;
    
    right_display_deviation = abs(edata.right_bar_stop_percent - edata.parameters.time_target);
    right_display_miss = right_display_deviation > edata.parameters.time_tolerance;

    %% go trials
    if td.trial_type == 'go' %#ok<STCMP>
        
        % failed to respond with one or two hands
        if ~left_responded || ~right_responded
            td.outcome = 'go - missing response';
            td.correct = 0;
        
        % response was too far from target
        elseif left_miss || right_miss
            if  ~(left_display_miss || right_display_miss)
                td.outcome = 'go - arduino miss';
                td.correct = 0;
            else
                td.outcome = 'go - missed target';
                td.correct = 0;
            end
        else
            if (left_display_miss || right_display_miss)
                td.outcome = 'go - display missed target';
                td.correct = 1;
            else
                td.outcome = 'go - correct';
                td.correct = 1;
            end
        end

%% stop trials

    else
        
        switch char(td.stop_side)
            case 'left'
                if left_responded && right_responded
                    td.outcome = 'stop - failed stop';
                    td.correct = 0;
                elseif ~left_responded && ~right_miss && right_responded
                    td.outcome = 'stop - successful stop';
                    td.correct = 1;
                elseif ~left_responded && right_miss && right_responded
                    if ~right_display_miss
                        td.outcome = 'stop - arduino miss';
                        td.correct = 1;
                    else
                        td.outcome = 'stop - stop but missed target';
                        td.correct = 1;
                    end
                else
                    td.outcome = 'stop - misc error';
                    td.correct = 0;
                end
            case 'right'
                if left_responded && right_responded
                    td.outcome = 'stop - failed stop';
                    td.correct = 0;
                elseif ~left_miss && ~right_responded && left_responded
                    td.outcome = 'stop - successful stop';
                    td.correct = 1;
                elseif left_miss && ~right_responded && left_responded
                    if ~left_display_miss
                        td.outcome = 'stop - arduino miss';
                        td.correct = 1;
                    else
                        td.outcome = 'stop - stop but missed target';
                        td.correct = 1;
                    end
                else
                    td.outcome = 'stop - misc error';
                    td.correct = 0;
                end
            case 'both'
                if ~left_responded && ~right_responded
                    td.outcome = 'stop - successful stop';
                    td.correct = 1;
                else
                    td.outcome = 'stop - failed stop';
                    td.correct = 0;
                end
        end
    end
    
    td.outcome = nominal(td.outcome);
    
%% adjust SSD

    if td.trial_type == 'stop' && ~edata.run_mode.practice %#ok<STCMP>
        if td.outcome == 'stop - successful stop' || td.outcome == 'stop - stop but missed target' %#ok<STCMP>
            % increase the SSD, making it harder
            edata.parameters.ssd.staircase_values(td.bar_stop_time) = ...
                edata.parameters.ssd.staircase_values(td.bar_stop_time) + edata.parameters.ssd.increment;
        else
            % decrease the SSD, making it easier (but less than 50 ms)
            edata.parameters.ssd.staircase_values(td.bar_stop_time) = ...
                edata.parameters.ssd.staircase_values(td.bar_stop_time) - edata.parameters.ssd.increment;
            
            % make sure the ssd is not less than the minimum
            edata.parameters.ssd.staircase_values(td.bar_stop_time) = ...
            	max(edata.parameters.ssd.minimum, edata.parameters.ssd.staircase_values(td.bar_stop_time));
        end
    end
    
    
end