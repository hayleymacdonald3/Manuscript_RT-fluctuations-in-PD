function [edata, practice_data] = exp_block_start_practice(edata, practice_data)
% If at the beginning of the block, perform specified functions

    if ~is_new_block(), return; end;
    
%% Perform these actions at the beginning of the block    

    current_block = practice_data.block(edata.current_trial);

    enforcedInterBlockBreakTime = 5.0;
    
    for i = enforcedInterBlockBreakTime:-1:1
        exp_display_centered_text(edata, 'Starting block %d in\n\n%d seconds', current_block, i);
        Screen('Flip', edata.display.index);
        pause(1.0);
    end
    
    exp_display_centered_text(edata, '(press space bar to begin)');
    Screen('Flip', edata.display.index);

    % wait for keypress
    get_key_press(edata.inputs.main_keyboard_index, 0, {'space'}, true)
    Screen('Flip', edata.display.index);

%% helper function (PROBABLY DO NOT NEED TO MODIFY THIS CODE)

    function [is_new] = is_new_block()

        % if there isn't a block column in trial_data, return
        if edata.current_trial == 1
            is_new = true;
        elseif ~ismember('block', get(practice_data, 'VarNames'))
            is_new = false;
        elseif practice_data.block(edata.current_trial) ~= practice_data.block(edata.current_trial-1)
            is_new = true;
        else
            is_new = false;
        end
    end
    
end
