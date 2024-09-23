function [edata, td] = exp_trial_feedback(edata, td)
% Display feedback in command window or screen after each trial

%% draw the bars

    if td.outcome == 'stop - successful stop' || td.outcome == 'go - correct' || td.outcome == 'stop - arduino miss' || td.outcome == 'go - arduino miss'
        target_color = edata.display.colors.green;
    else
        target_color = edata.display.colors.red;
    end
%     if td.trial_type == 'go' %#ok<STCMP>
%         left_percent = nz(td.left_rt / edata.parameters.time_fill, 1);
%         right_percent = nz(td.right_rt / edata.parameters.time_fill, 1);        
%     else
%         if td.stop_side == 'left' %#ok<STCMP>
%             left_percent = min(td.ssd, td.left_rt) / edata.parameters.time_fill;
%             right_percent = nz(td.right_rt / edata.parameters.time_fill, 1);        
%         elseif td.stop_side == 'right'  %#ok<STCMP>
%             left_percent = nz(td.left_rt / edata.parameters.time_fill, 1);
%             right_percent = min(td.ssd, td.right_rt) / edata.parameters.time_fill;
%         elseif td.stop_side == 'both'  %#ok<STCMP>
%             left_percent = min(td.ssd, td.left_rt) / edata.parameters.time_fill;
%             right_percent = min(td.ssd, td.right_rt) / edata.parameters.time_fill;            
%         end
%     end

    bar1_display_bars(edata, edata.left_bar_stop_percent, edata.right_bar_stop_percent, target_color);
    
%% text feedback

    if td.outcome == 'stop - successful stop' || td.outcome == 'go - correct' || td.outcome == 'stop - arduino miss' || td.outcome == 'go - arduino miss'
        screen_text = 'Success'
    else
        screen_text = 'Miss'
    end
    
    % screen_text = char(td.outcome);
    if td.outcome == 'stop - successful stop' || td.outcome == 'go - correct' || td.outcome == 'stop - arduino miss' || td.outcome == 'go - arduino miss'
        feedback_color = edata.display.colors.black;
    else
        feedback_color = edata.display.colors.red;
    end
    DrawFormattedText(edata.display.index, screen_text, 'center', 50, edata.display.colors.black); % chainging the number changes vertical position of feedback text - is counted from top of screen
    Screen('Flip', edata.display.index);

%% pause

    pause(1.0);
    
end


