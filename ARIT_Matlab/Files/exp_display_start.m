function [edata] = exp_display_start(edata)
% If there isn't currently a valid screen, open a new one    
    
%% if there is a currently valid screen index, return as is    
    try
        if Screen(edata.display.index, 'WindowKind')
            return
        end
    end

%% otherwise, try opening a new screen using the scr() function    
    
    try
        if edata.run_mode.debug
            % if using multiple displays,  open in the last one
            if length(Screen('Screens')) > 1
                [edata.display.index, screen_paramters] = scr();
                
            % if using one display, open a picture-in-picture window
            else
%                [edata.display.index, screen_paramters] = scr(2);
                [edata.display.index, screen_paramters] = scr();
            end
        else
            [edata.display.index, screen_paramters] = scr(); %set to 2 to have windowed for easy debugging, otherwise leave empty
        end
        
%% catch errors are return debugging tips

    catch
        if ~exist('screen_parameters', 'var')
            % The scr command failed completely. Rethrow the error.
            fprintf('Failed to open PsychToolbox screen using scr():\n')
            rethrow(lasterror);
        elseif isfield('initialization_message', screen_parameters)
            disp(screen_parameters.initialization_message)
            fprintf('PsychToolbox failed to open a screen (see details above). Try running again.\n')
        else
            fprintf('PsychToolbox failed to open a screen. Try calling scr() directly to debug.\n')
        end
        return
    end

end