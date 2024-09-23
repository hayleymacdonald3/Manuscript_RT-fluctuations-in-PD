function [edata, td] = bar1_get_response(edata, td)

% if in debug mode, don't suppress keyboard output because it makes it difficult to recover from errors
%     if ~edata.run_mode.debug
%         ListenChar(2);
%     end

%% Initialize LPT1 port and add lines for left and right mouse buttons
% DIO1 = digitalio('parallel','LPT1');
% get(DIO1,'PortAddress');
% signal_out = addline(DIO1, 2, 'out');
% tms_out = addline(DIO1, 4, 'out');
% in = addline(DIO1, 0:4, 1, 'in');

% leftLiftTime = -2;
% rightLiftTime = -2;

% Initialize communication with Arduino
%Check for 'Q' from Arduino
serialObject = serial('COM4');    % define serial port
serialObject.BaudRate=9600;               % define baud rate
set(serialObject, 'terminator', 'CR/LF');    % define the terminator for println
fopen(serialObject);

rec = fgetl(serialObject);
if (rec ~= 'Q')
    disp(rec);
    error('Arduino / Matlab out of sync'); 
end

% Initialize National Instruments device
nidaq = daqhwinfo('nidaq');
usb6009_device_id = nidaq.InstalledBoardIds{strcmpi(nidaq.BoardNames, 'USB-6009')};
DIO1 = digitalio('nidaq',usb6009_device_id);
% get(DIO1,'PortAddress');
% in = addline(DIO1, 0:1, 1, 'in');
% signal_out = addline(DIO1, 2, 0, 'out');
% tms_out_tscs = addline(DIO1, 3:4, 0, 'out');

% Determine TMS signal info
% Get TMS delay time from td
if ~isNaN(td.stimulation_time_ts)       % if there is a ts, then stimulation trial is required
   tmsDelay = (td.stimulation_time_ts);
else
    tmsDelay = NaN;
end
   
% Send delay for TMS to Arduino
fprintf(serialObject,'%d',tmsDelay);

% Get type of trial from td info (i.e. non-stim, single or double stim)
if ~isNaN(td.stimulation_time_ts) && ~isNaN(td.stimulation_time_cs)
    tmsType = 2;
elseif ~isNaN(td.stimulation_time_ts)
    tmsType = 1;
else
    tmsType = 0;
end

% Send type of trial info to Arduino
fprintf(serialObject,'%d',tmsType);

%% display the bar

bar1_display_bars(edata);
Screen('Flip', edata.display.index);

% SET PRIORITY FOR SCRIPT EXECUTION TO REALTIME PRIORITY:
%     PRIORITYLEVEL=MAXPRIORITY(edata.display.index);
%     PRIORITY(PRIORITYLEVEL);
%
%% wait until the participant is holding down left and right mouse buttons

% max = 0.9;
% min = 0.4;
% LPTRaw = getvalue(in);       % returns array about voltage state of pins
% 
% % while ~all(LPTRaw == [1 0 0 1 0])  % array returned if left and right mouse buttons down
% while ~all(LPTRaw == [0 0])
%     LPTRaw = getvalue(in);
% end

% Setup non timing crucial variables
keep_going = true;
% left_button_down = true;
% right_button_down = true;
left_rt = NaN;
right_rt = NaN;
left_bar_rect = edata.display.elements.left_bar;
right_bar_rect = edata.display.elements.right_bar;
left_bar_stop_percent = NaN;
right_bar_stop_percent = NaN;
% stimulation_ts_shouldfire = false;
% stimulation_cs_shouldfire = false;
currentTime = 0;
lastDrawnTime = 0;

% putvalue(signal_out,0); % Init putvalue
% putvalue(tms_out_tscs, [0 0]); % Init tscs
 

% WaitSecs((max-min)*rand+min);
% putvalue(signal_out,1); % here you trigger by sending '1' to Signal
% start_time = GetSecs; % Starting timing here so signal timing is accurate
% WaitSecs(0.001);
% putvalue(signal_out,0); % put value '0' to end trigger
%% setup variables

fill_end_time = start_time + edata.parameters.time_fill;
% if GetSecs time reaches time for stimulation, send stimulus to TMS machine
if ~isnan(td.stimulation_time_ts)
    stimulation_ts = start_time + td.stimulation_time_ts/1000 - .005;
    stimulation_ts_shouldfire = true;
    if ~isnan(td.stimulation_time_cs)
        stimulation_cs_shouldfire = true;
    end
end

if td.trial_type == 'stop' %#ok<STCMP>
    stop_signal_pending = true;
    td.ssd = edata.parameters.ssd.staircase_values(td.bar_stop_time);
    stop_bars_time = start_time + td.ssd;
else
    stop_signal_pending = false;
end
%% fill bars and continuously query for participant response
%try
while keep_going
    % check button status
    currentTime = GetSecs;   
    if stimulation_ts_shouldfire
        if  currentTime >= stimulation_ts
            if stimulation_cs_shouldfire
                putvalue(tms_out_tscs,[1 1]); % here you trigger by sending '1' to TMS machines
                WaitSecs(0.001);
                putvalue(tms_out_tscs,[0 0]); % put value '0' to end trigger
                stimulation_ts_shouldfire = false;
                stimulation_cs_shouldfire = false;
            else
                putvalue(tms_out_tscs,[1 0]); % here you trigger by sending '1' to Signal
                WaitSecs(0.001);
                putvalue(tms_out_tscs,[0 0]); % put value '0' to end trigger
                stimulation_ts_shouldfire = false;
            end
        end
    end
    
    if (currentTime - lastDrawnTime) >  (1 / 100) % Draw only a certain number of times a second 
        LPTRaw = getvalue(in);
        %LPTRaw = getvalue(parentuddobj,lineIndices);
    end
    if left_button_down && all(LPTRaw == [1 0]) %[1 1 0 1 0]) % if left button was down and then only right button down
        left_button_down = false;
        left_rt = GetSecs - start_time;
        if isnan(left_bar_stop_percent)
            left_bar_stop_percent = left_rt / edata.parameters.time_fill;
        end
    end
    if right_button_down && all(LPTRaw == [0 1]) %[1 0 1 1 0]) % if right button was down and then only left button down
        right_button_down = false;
        right_rt = GetSecs - start_time;
        if isnan(right_bar_stop_percent)
            right_bar_stop_percent = right_rt / edata.parameters.time_fill;
        end
    end
    if left_button_down && all(LPTRaw == [1 1]) %[1 1 1 1 0]) % if left button was down and then neither button down
        left_button_down = false;
        left_rt = GetSecs - start_time;
        if isnan(left_bar_stop_percent)
            left_bar_stop_percent = left_rt / edata.parameters.time_fill;
        end
    end
    if right_button_down && all(LPTRaw == [1 1]) %[1 1 1 1 0]) % if right button was down and then neither button down
        right_button_down = false;
        right_rt = GetSecs - start_time;
        if isnan(right_bar_stop_percent)
            right_bar_stop_percent = right_rt / edata.parameters.time_fill;
        end
    end
    
    % for stop trials, check if the bars need to stop
    if stop_signal_pending && currentTime > stop_bars_time
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
    
    if (currentTime - lastDrawnTime) >  (1 / 60) % Draw only a certain number of times a second 
        % update the bars
        percent_full = (currentTime - start_time) / edata.parameters.time_fill;
        bar1_display_bars(edata, nz(left_bar_stop_percent, percent_full), nz(right_bar_stop_percent, percent_full));
        Screen('Flip', edata.display.index);
        lastDrawnTime = currentTime;
        
        % determine when to stop checking
        if currentTime > fill_end_time || ...               % the time has run out
                (~left_button_down && ~right_button_down)          % neither button is down
            keep_going = false;
        end 
    end
end

%% error catching and finish keyboard querying

%     catch
%         ListenChar(0);
%         cls
%         rethrow(lasterror);
%     end

% start listening to the inputs again
%ListenChar(0);

%% adjust reaction times relative to go signal

td.left_rt = left_rt;
td.right_rt = right_rt;
td.start_time = start_time;

end



