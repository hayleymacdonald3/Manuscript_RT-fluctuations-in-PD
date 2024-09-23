 


%% wait until the participant is holding down left and right mouse buttons

    max = 0.7;
    min = 0.2;
    
    DIO1 = digitalio('parallel','LPT1');
    in = addline(DIO1, 0:4, 1, 'in');

%% setup variables

    keep_going = true;
    start_time = GetSecs;
    fill_end_time = start_time + edata.parameters.time_fill;
    left_button_down = true;
    right_button_down = true;
    left_rt = NaN;
    right_rt = NaN;
    left_bar_rect = edata.display.elements.left_bar;
    right_bar_rect = edata.display.elements.right_bar;
    left_bar_stop_percent = NaN;
    right_bar_stop_percent = NaN;
        stop_signal_pending = false;

%% fill bars and continuously query for participant response

    %try
    LPTRaw = [0 0 0 0 0];
        while keep_going
            % check button status
            LPTRaw = getvalue(in);
                                   
            if left_button_down && all(LPTRaw == [1 1 0 1 0]) % if left button was down and then only right button down
                left_button_down = false;
                left_rt = GetSecs - start_time;
                if isnan(left_bar_stop_percent)
                    left_bar_stop_percent = left_rt / edata.parameters.time_fill;
                end
            end
            if right_button_down && all(LPTRaw == [1 0 1 1 0]) % if right button was down and then only left button down
                right_button_down = false;
                right_rt = GetSecs - start_time;
                if isnan(right_bar_stop_percent)
                    right_bar_stop_percent = right_rt / edata.parameters.time_fill;
                end
            end
            if left_button_down && all(LPTRaw == [1 1 1 1 0]) % if left button was down and then neither button down
                left_button_down = false;
                left_rt = GetSecs - start_time;
                if isnan(left_bar_stop_percent)
                    left_bar_stop_percent = left_rt / edata.parameters.time_fill;
                end
            end
            if right_button_down && all(LPTRaw == [1 1 1 1 0]) % if right button was down and then neither button down
                right_button_down = false;
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

            % determine when to stop checking
            if GetSecs > fill_end_time || ...               % the time has run out
               (~left_button_down && ~right_button_down)          % neither button is down
                    keep_going = false;
            end
        end
    

