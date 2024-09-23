function [edata, practice_data] = exp_trial_practice(edata, practice_data)
% Runs all necessary actions for a single trial (also used for practice trials)

%% if escape key is down, stop experiment

    if get_key_press(edata.inputs.main_keyboard_index, -1, edata.inputs.quit_key, false)
        edata.run_mode.stop_asap = true;
        return
    end
        
%% create a variable containing only the current trial, for easy referencing in code

    td = practice_data(edata.current_trial, :);
    % useful for debugging, but not necessary for functioning
    assignin('base', 'td', td)


%% determine timing

    % GetSecs returns a number representing computer time. The unit of computer time is one second,
    % so for example, GetSecs + 3 is three seconds from now. The actual value of GetSecs is
    % meaningless (it may be something like 1.079e+05), but we can use the difference between
    % times to reflect specific intervals of time.
    
    % bar1 doesn't use this form of timing

%% the three horsemen of the trial

    [edata, td] = exp_trial_get_response(edata, td);
    [edata, td] = exp_trial_check_response(edata, td);
    [edata, td] = exp_trial_feedback(edata, td);

%% end trial

    %td.start_time = edata.timing.start; - in bars, this is set in get_response
    td.duration = nz(GetSecs - td.duration, 0);
    td.complete = true;

%% save the td variable back into practice data

    old_warnings = warning('off', 'stats:categorical:subsasgn:NewLevelsAdded');
    try
        practice_data(edata.current_trial, :) = td;
    catch
        compare_results = dataset_compare(td, practice_data);
        if ~isempty(compare_results.class_differences)
            command_window_line
            fprintf('Columns in td (a) variable have difference classes than practice_data (b):\n')
            disp(compare_results.class_differences);
            command_window_line
        end
        rethrow(lasterror);        
    end
    warning(old_warnings);

    % useful for debugging, but not necessary for functioning
    assignin('base', 'td', td)

%% display last 10 trials in command line for checking status

    command_window_line
    feedback_data = practice_data(:, {'block', 'trial_num', 'trial_type', 'stop_side', 'bar_stop_time', 'ssd', 'left_rt', 'right_rt', 'outcome', 'correct'});
    disp(feedback_data(max(1, edata.current_trial-9):edata.current_trial, :));    
    
end
