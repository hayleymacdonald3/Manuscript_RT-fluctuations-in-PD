function [edata, trial_data] = exp_block_end(edata, trial_data)
    
    if ~is_block_end(), return; end;
    
   
%% Perform these actions at the end of the block    
    
    current_block = trial_data.block(edata.current_trial);
    [edata, trial_data] = exp_block_feedback(edata, trial_data);
    
    exp_display_centered_text(edata, 'press SPACE BAR to continue, ESCAPE to exit');
    Screen('Flip', edata.display.index);

    %% Write block to csv file

    td2csv(trial_data, edata)
    
    % wait for keypress
    [was_pressed, press_time, pressed_keys] = get_key_press(edata.inputs.main_keyboard_index, 0, {'space', edata.inputs.quit_key}, true);
    Screen('Flip', edata.display.index);
    if pressed_keys == KbName(edata.inputs.quit_key) % check for escape (mac) and esc (pc)
        fprintf('Experiment stopped at end of block %d\n', current_block);
        edata.run_mode.stop_asap = true;
    end;

%% helper function (PROBABLY DO NOT NEED TO MODIFY THIS CODE)

    function [is_end] = is_block_end()

        if edata.current_trial == size(trial_data, 1)
            is_end = true;
        elseif ~ismember('block', get(trial_data, 'VarNames'))
            is_end = false;
        elseif trial_data.block(edata.current_trial) ~= trial_data.block(edata.current_trial+1)
            is_end = true;
        else
            is_end = false;
        end
        
        
    end
    
    
end
