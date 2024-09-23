function [edata] = exp_initialize_display(edata)
% Test the screen and save the basic parameters returned by scr()    
    
    % use the scr() command to open screen and gather screen parameters (sp)
    [display_index, edata.display] = scr(); % saves the screen ID as display_index when opens full screen
    edata.display.index = display_index;
        
    % draw background
    exp_display_black_background(edata);
    
    % confirm the screen works
    DrawFormattedText(edata.display.index, ...
        'Screen works...', 'center', 'center', edata.display.colors.white);
    Screen('Flip', edata.display.index);
    pause(.5);
    cls

%% calculate stimuli coordinates

    % this is a good place to calculate the coordinates of all stimuli to be displayed on the screen
    % throughout the experiment. This eliminates repitious calculations that would be performed
    % during each trial and can also identify potential display errors (e.g. the screen is not big
    % enough for the stimuli as programmed) before the experiment starts.
    
    edata.display.colors.gray = [128 128 128];
    
    
    bar_width = 60;
    bar_height = 600;
    edata.display.elements.bar_width = bar_width;
    edata.display.elements.bar_height = bar_height;
    
    edata.display.elements.target = [ ...
        edata.display.x_center - bar_width * 2.5 ...
        edata.display.y_center - bar_height * 0.3 - 3 ...
        edata.display.x_center + bar_width * 2.5 ...
        edata.display.y_center - bar_height * 0.3 + 3 ...
        ];        
    
    edata.display.elements.left_bar = [...
        edata.display.x_center - bar_width * 1.5 ...
        edata.display.y_center - bar_height * 0.5 ...
        edata.display.x_center - bar_width * 0.5 ...
        edata.display.y_center + bar_height * 0.5 ...
        ];
    
    edata.display.elements.right_bar = [...
        edata.display.x_center + bar_width * 0.5 ...
        edata.display.y_center - bar_height * 0.5 ...
        edata.display.x_center + bar_width * 1.5 ...
        edata.display.y_center + bar_height * 0.5 ...
        ];
    
end
