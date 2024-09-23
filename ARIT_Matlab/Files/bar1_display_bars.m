function bar1_display_bars(edata, left_percent_full, right_percent_full, target_color)
   
%% gray background    
    
%    screenNumber = max(Screen('Screens'));
%    [edata.display.index] = Screen('OpenWindow', screenNumber);
   Screen('FillRect', edata.display.index, [edata.display.colors.gray]);
    
%% target

    if ~exist('target_color', 'var') 
       target_color = edata.display.colors.black; 
    end
    Screen('FillRect', edata.display.index, [target_color], [edata.display.elements.target]);
    
%% empty bars

    Screen('FillRect', edata.display.index, [edata.display.colors.white], ...
        [edata.display.elements.left_bar]);
    Screen('FillRect', edata.display.index, [edata.display.colors.white], ...
        [edata.display.elements.right_bar]);
    
%% bar fillings    
    
    if exist('left_percent_full', 'var') && ~isnan(left_percent_full)
        left_bar_rect = edata.display.elements.left_bar;
        left_height = round(left_percent_full * edata.display.elements.bar_height);
        left_bar_rect(2) = left_bar_rect(4) - left_height;        
        Screen('FillRect', edata.display.index, edata.display.colors.black, left_bar_rect);
    end

    if exist('right_percent_full', 'var') && ~isnan(right_percent_full)
        right_bar_rect = edata.display.elements.right_bar;
        right_height = round(right_percent_full * edata.display.elements.bar_height);
        right_bar_rect(2) = right_bar_rect(4) - right_height;
        Screen('FillRect', edata.display.index, edata.display.colors.black, right_bar_rect);
    end
    
end