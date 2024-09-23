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
serialObject = serial('COM3');    % define serial port
serialObject.BaudRate=9600;               % define baud rate
set(serialObject, 'terminator', 'CR/LF');    % define the terminator for println
fopen(serialObject);

display('Connection Established');
fprintf(serialObject,'%s','A'); %Sends byte to Arduino, which is waiting for MatLab
%Print message from Arduino (temporary)
rec = fgetl(serialObject);
disp(rec);

% Initialize National Instruments device
WaitSecs(0.1);
niDevice = daq.createSession('ni');
% niDevice = daq.getDevices;
niDevice.addDigitalChannel('Dev2','Port0/Line1:2','InputOnly'); % changed from Dev1 to Dev2?????????????????????????????????????????????????????

% nidaq = daqhwinfo('nidaq');
% usb6009_device_id = nidaq.InstalledBoardIds{strcmpi(nidaq.BoardNames, 'USB-6009')};
% DIO1 = digitalio('nidaq',usb6009_device_id);
% % get(DIO1,'PortAddress');
% leftRightSwitchInput = addline(DIO1, 1:2, 0, 'in');
% signal_out = addline(DIO1, 2, 0, 'out');
% tms_out_tscs = addline(DIO1, 3:4, 0, 'out');

% Determine TMS signal info
% Get TMS delay time from td
if ~isnan(td.stimulation_time_ts)       % if there is a ts, then stimulation trial is required
    tmsDelay = td.stimulation_time_ts;
else
    tmsDelay = -1;
end

% Send delay for TMS to Arduino
fprintf(serialObject,'%d',tmsDelay);
%Print message from Arduino (temporary)
rec = fgetl(serialObject);
disp(rec);

% Get type of trial from td info (i.e. non-stim, single or double stim)
if ~isnan(td.stimulation_time_ts)  && ~isnan(td.stimulation_time_cs)
    tmsType = 2;
elseif ~isnan(td.stimulation_time_ts)
    tmsType = 1;
else
    tmsType = 0;
end

% Send type of trial info to Arduino
fprintf(serialObject,'%d',tmsType);
%Print message from Arduino (temporary)
rec = fgetl(serialObject);
disp(rec);

%% display the bar

bar1_display_bars(edata);
Screen('Flip', edata.display.index);


% Setup non timing crucial variables
keep_going = true;
% left_button_down = true;
% right_button_down = true;
leftLiftTime = NaN;
rightLiftTime = NaN;
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


%% setup variables

%%%%%%%%%%%%% WAIT FOR TRIGGER FROM ARDUINO TO START BARS RISING %%%%%%%%%%%%%%%%%%%%
%Beeper()
leftRightSwitchState = [0 0];
while ~leftRightSwitchState
    leftRightSwitchState = niDevice.inputSingleScan();
    %display(a)
end
%Beeper()
start_time = GetSecs;
fill_end_time = start_time + edata.parameters.time_fill;
% if GetSecs time reaches time for stimulation, send stimulus to TMS machine
% if ~isnan(td.stimulation_time_ts)
%     stimulation_ts = start_time + td.stimulation_time_ts/1000 - .005;
%     stimulation_ts_shouldfire = true;
%     if ~isnan(td.stimulation_time_cs)
%         stimulation_cs_shouldfire = true;
%     end
% end

if td.trial_type == 'stop' %#ok<STCMP>
    stop_signal_pending = true;
    td.ssd = edata.parameters.ssd.staircase_values(td.bar_stop_time);
    stop_bars_time = start_time + td.ssd;
else
    stop_signal_pending = false;
end

while keep_going
    currentTime = GetSecs;
    if (currentTime - lastDrawnTime) >  (1 / 60) % Draw only a certain number of times a second
        % update the bars  
        percent_full = (currentTime - start_time) / edata.parameters.time_fill;
        bar1_display_bars(edata, nz(left_bar_stop_percent, percent_full), nz(right_bar_stop_percent, percent_full));
        Screen('Flip', edata.display.index,[],2,2); %dont clear screen, dont wait for sync
        lastDrawnTime = currentTime;
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
    
    %%%%%%%%%%%%%%% LOOK FOR TRIGGER FROM ARDUINO TO SAY BOTH FINGERS HAVE
    %%%%%%%%%%%%%%% LIFTED - ports are other way from usual, is referenced [right_switch_status left_switch_status%%%%%%%%%
    %%%%%%%%%%%%%%% ??????????????????????????????????????????????????????????can't lift right side by itself - when lift only right switch, both bars follow what left switch does - doesn't happen when lift only left???????????????????????????????????????????????????????????????????????
    leftRightSwitchState = niDevice.inputSingleScan();
    if leftRightSwitchState == [0 0] % both switches up or time up ....................................zero = finger lifted?!?!?!
        
        %t = GetSecs - start_time;
        if isnan(left_bar_stop_percent)
            %left_bar_stop_percent =  t / edata.parameters.time_fill;
            left_bar_stop_percent = percent_full;
        end
        if isnan(right_bar_stop_percent)
            right_bar_stop_percent = percent_full;
            %right_bar_stop_percent = t / edata.parameters.time_fill;
        end
        keep_going = false;
    elseif leftRightSwitchState == [1 0] % left switch up
        if isnan(left_bar_stop_percent)
            left_bar_stop_percent = percent_full;
            %left_bar_stop_percent = GetSecs - start_time / edata.parameters.time_fill;
        end
%         keep_going = false;
    elseif leftRightSwitchState == [0 1] %right switch up
        if isnan(right_bar_stop_percent)
            right_bar_stop_percent = percent_full;
            %right_bar_stop_percent = GetSecs - start_time / edata.parameters.time_fill;
        end
%         keep_going = false;
    else
        continue %both switches down - continue 
    end
   %sca;
end

%Recieve and print leftLiftTime
rec = fgetl(serialObject);
leftLiftTime = str2num(rec);
disp(['Left Lift Time: ' num2str(leftLiftTime)])
%Recieve and print rightLiftTime
rec = fgetl(serialObject);
rightLiftTime = str2num(rec);
disp(['Right Lift Time: ' num2str(rightLiftTime)])
disp('All Done!!');
fclose(serialObject);

% Display full black bar if lift time NaN (unless successfully inhibited)

if (leftLiftTime <= 0)
    leftLiftTime = NaN;
    if td.stop_side == 'left' || td.stop_side == 'both'
        left_bar_stop_percent = td.ssd / edata.parameters.time_fill;
    else
        left_bar_stop_percent = edata.parameters.time_fill / edata.parameters.time_fill;
    end
end
if (rightLiftTime <= 0)
    rightLiftTime = NaN;
    if td.stop_side == 'right' || td.stop_side == 'both'
        right_bar_stop_percent = td.ssd / edata.parameters.time_fill;
    else
        right_bar_stop_percent = edata.parameters.time_fill / edata.parameters.time_fill;
    end
end



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

edata.left_bar_stop_percent = left_bar_stop_percent
edata.right_bar_stop_percent = right_bar_stop_percent

% error('go away');

%% error catching and finish keyboard querying

%     catch
%         ListenChar(0);
%         cls
%         rethrow(lasterror);
%     end

% start listening to the inputs again
%ListenChar(0);

%% adjust reaction times relative to go signal

td.left_rt = leftLiftTime / 1000;
td.right_rt = rightLiftTime / 1000;
td.start_time = start_time;

end



