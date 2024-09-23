function exp_display_centered_text(edata, varargin)

    assert(ischar(varargin{1}), 'Second argument must be a string');
    screen_text = sprintf(varargin{:});
    
    exp_display_black_background(edata);
    DrawFormattedText(edata.display.index, screen_text, 'center', 'center', edata.display.colors.white);

end