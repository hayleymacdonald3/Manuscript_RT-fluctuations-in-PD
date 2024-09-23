function [edata] = exp_initialize_inputs(edata)
% Finds input devices and confirms keys being used
        
    if IsOSX
        edata.inputs.main_keyboard_index = input_device_keyboard;
        edata.inputs.quit_key = 'escape';
    else
        % PC's don't need a keyboard index
        edata.inputs.main_keyboard_index = [];
        edata.inputs.quit_key = 'esc';
    end
    
%% determine which keys to use for responses

    edata.inputs.response_key_names = {'z' '/?'};
    edata.inputs.left_key_num = KbName(edata.inputs.response_key_names{1});
    edata.inputs.right_key_num = KbName(edata.inputs.response_key_names{2});

    fprintf('Default keys on the left are %s and %s, on the right are %s and %s.\n', edata.inputs.response_key_names{:});
%     default_question = 'Use default keys? (ENTER to use defaults above, type c to customize): ';
%     if ~isempty(input(default_question, 's'))
%         fprintf('Press key for left hand, left key:... ');
%         [was_pressed, press_time, pressed_key] = get_key_press(edata.inputs.left_keypad_index, [], {}, true);
%         edata.inputs.reponse_keys_nums(1) = pressed_key(1);
%         edata.inputs.reponse_keys_names{1} = KbName(pressed_key(1));
%         fprintf('key = ''%s''\n', KbName(pressed_key(1)));
% 
%         fprintf('Press key for left hand, right key:... ');
%         [was_pressed, press_time, pressed_key] = get_key_press(edata.inputs.left_keypad_index, [], {}, true);
%         edata.inputs.reponse_keys_nums(2) = pressed_key(1);
%         edata.inputs.reponse_keys_names{2} = KbName(pressed_key(1));
%         fprintf('key = ''%s''\n', KbName(pressed_key(1)));
% 
%     end
end
