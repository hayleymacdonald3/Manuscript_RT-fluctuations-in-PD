function [edata, trial_data] = exp_block_feedback(edata, trial_data)
% Display feedback graphs for block
    
%% If there isn't an active screen, create one

    [edata] = exp_display_start(edata);
    
%% annoying PC bug fix

    % I have not been able to resolve a bug on PCs that after the first Screen('Flip')
    % command, the get_key_press function blanks the screen. The cludgey fix is to flip a blank
    % screen, do a meaningless get_key_press, and then all subsequent screens will display ok
    % (mike c. 03-02-09)
    if ispc
        Screen('Flip', edata.display.index);
        get_key_press(edata.inputs.main_keyboard_index, -1, {'space'}, false);
        Screen('Flip', edata.display.index);
    end
    
%% display message while graph is being generated

    exp_display_centered_text(edata, 'Generating feedback graph...');
    Screen('Flip', edata.display.index);

%% open a figure

    if edata.run_mode.debug
        f_handle = figure('Visible','on');
    else
        % it is faster to create figures that are not visible
        f_handle = figure('Visible','off');
    end

%% calculate block stats and plot

    edata = bar1_block_stats(edata, trial_data);
    
    % display calculated stats in the command window
    disp(edata.block_stats);

%% display subject graph on screen for 10 seconds

    exp_display_black_background(edata);
    figure_to_ptb_screen(f_handle, edata.display.index);
    close(f_handle);    
    DrawFormattedText(edata.display.index, 'Graphs will display for 10 seconds', 'center');
    Screen('Flip',edata.display.index);
    pause(10.0);
    

    % wait for keypress
%     pause(1)
%     get_key_press(edata.inputs.main_keyboard_index, 0, {'space'}, true);
%     Screen('Flip', edata.display.index);
%     
end
