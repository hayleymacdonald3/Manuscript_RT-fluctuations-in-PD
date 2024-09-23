function [edata, td] = bar1_get_response(edata, td)    
    
    % if in debug mode, don't suppress keyboard output because it makes it difficult to recover from errors
    if ~edata.run_mode.debug
        ListenChar(2);
    end

%% display the bar

    bar1_display_bars(edata);
    Screen('Flip', edata.display.index);
    
%% wait until the participant is holding down both keys

    both_keys_down = false;
    while ~both_keys_down
        if IsOSX
            [key_was_pressed, press_time, key_list] = PsychHID('KbCheck', edata.inputs.main_keyboard_index);
        else
            [key_was_pressed, press_time, key_list] = KbCheck;
        end
        both_keys_down = key_list(edata.inputs.left_key_num) && key_list(edata.inputs.right_key_num);
        pause(0.01);
    end

%% setup variables

    keep_going = true;
    start_time = GetSecs;
    fill_end_time = start_time + edata.parameters.time_fill;
    left_key_down = true;
    right_key_down = true;
    left_rt = NaN;
    right_rt = NaN;
    left_bar_rect = edata.display.elements.left_bar;
    right_bar_rect = edata.display.elements.right_bar;
    left_bar_stop_percent = NaN;
    right_bar_stop_percent = NaN;
    if td.trial_type == 'stop' %#ok<STCMP>
        stop_signal_pending = true;
        td.ssd = edata.parameters.ssd.staircase_values(td.staircase);
        stop_bars_time = start_time + td.ssd;
    else
        stop_signal_pending = false;
    end

%% fill bars and continuously query for participant response

    %try
        while keep_going

            % check key status
            if IsOSX
                [key_was_pressed, press_time, key_list] = PsychHID('KbCheck', edata.inputs.main_keyboard_index);
            else
                [key_was_pressed, press_time, key_list] = KbCheck;
            end
            if left_key_down && ~key_list(edata.inputs.left_key_num)
                left_key_down = false;
                left_rt = GetSecs - start_time;
                if isnan(left_bar_stop_percent)
                    left_bar_stop_percent = left_rt / edata.parameters.time_fill;
                end
            end
            if right_key_down && ~key_list(edata.inputs.right_key_num)
                right_key_down = false;
                right_rt = GetSecs - start_time;
                if isnan(right_bar_stop_percent)
                    right_bar_stop_percent = right_rt / edata.parameters.time_fill;
                end
            end

            % for stop trials, check if the bars need to stop
            if stop_signal_pending && GetSecs > stop_bars_time
                if td.stop_side == 'left' || td.stop_side == 'both' %#ok<STCMP>
                    if isnan(left_bar_stop_percent)
                        left_bar_stop_percent = td.ssd / edata.parameters.time_fill;
                    end
                end
                if td.stop_side == 'right'  || td.stop_side == 'both' %#ok<STCMP>
                    if isnan(right_bar_stop_percent)
                        right_bar_stop_percent = td.ssd / edata.parameters.time_fill;
                    end
                end
            end

            % update the bars
            percent_full = (GetSecs - start_time) / edata.parameters.time_fill;
            bar1_display_bars(edata, ...
                nz(left_bar_stop_percent, percent_full), ...
                nz(right_bar_stop_percent, percent_full));
            Screen('Flip', edata.display.index);

            % determine when to stop checking
            if GetSecs > fill_end_time || ...               % the time has run out
               (~left_key_down && ~right_key_down)          % neither key is down
                    keep_going = false;
            end

        end
        
%% error catching and finish keyboard querying

%     catch
%         ListenChar(0);
%         cls
%         rethrow(lasterror);
%     end
        
    % start listening to the inputs again
    ListenChar(0);

%% adjust reaction times relative to go signal
    
    td.left_rt = left_rt;
    td.right_rt = right_rt;
    td.start_time = start_time;
    
end

    

