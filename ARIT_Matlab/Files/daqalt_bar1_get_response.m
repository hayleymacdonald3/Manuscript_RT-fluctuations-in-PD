function [edata, td] = bar1_get_response(edata, td)

% if in debug mode, don't suppress keyboard output because it makes it difficult to recover from errors
%     if ~edata.run_mode.debug
%         ListenChar(2);
%     end

%% Initialize LPT1 port and add lines for left and right mouse buttons
lib = 'myni';	% library alias
if ~libisloaded(lib)
    disp('Matlab: Load nicaiu.dll')
    funclist = loadlibrary('nicaiu.dll','nidaqmx.h','alias',lib);
    %if you do NOT have nicaiu.dll and nidaqmx.h
    %in your Matlab path,add full pathnames or copy the files.
    %libfunctions(lib,'-full') % use this to show the... 
    %libfunctionsview(lib)     % included function
end
disp('Matlab: dll loaded')
disp('')
% %% load all DAQmx constants
NIconstants;

%%%%%% Init read lines
DIlines = {'Dev1/port1/line0','Dev1/port1/line1'};
lineGrouping = DAQmx_Val_ChanPerLine; % One Channel For Each Line
% lineGrouping = DAQmx_Val_ChanForAllLines; % One Channel For All Lines
taskh.DIs = DAQmxCreateDIChan(lib,DIlines,lineGrouping);

% read DI channels together
numSampsPerChan = 1;
timeout = 1;
fillMode =  DAQmx_Val_GroupByChannel; % Group by Channel
% fillMode = DAQmx_Val_GroupByScanNumber; % Group by Scan Number
numchanDI = numel(DIlines); % DI lines
numsample = 1;

%%%% Init write lines
taskh.trigger = DAQmxCreateDOChan(lib,'Dev1/port0/line2',lineGrouping);

tmsLines = {'Dev1/port0/line3','Dev1/port0/line4'};
taskh.tms = DAQmxCreateDOChan(lib,tmsLines,lineGrouping);

% write values to DO lines
dataLayout =  DAQmx_Val_GroupByChannel; % Group by Channel
% dataLayout = DAQmx_Val_GroupByScanNumber; % Group by Scan Number
DAQmxWriteDigitalLines(lib,taskh.trigger,numSampsPerChan,timeout,dataLayout,0);
DAQmxWriteDigitalLines(lib,taskh.tms,numSampsPerChan,timeout,dataLayout,[0,0]);


%% display the bar

bar1_display_bars(edata);
Screen('Flip', edata.display.index);

% SET PRIORITY FOR SCRIPT EXECUTION TO REALTIME PRIORITY:
%     PRIORITYLEVEL=MAXPRIORITY(edata.display.index);
%     PRIORITY(PRIORITYLEVEL);
%
%% wait until the participant is holding down left and right mouse buttons

max = 0.9;
min = 0.4;
LPTRaw = DAQmxReadDigitalLines(lib,taskh.DIs,numSampsPerChan,timeout,fillMode,numchanDI,numsample)       % returns array about voltage state of pins

% while ~all(LPTRaw == [1 0 0 1 0])  % array returned if left and right mouse buttons down
while ~all(LPTRaw == [0; 0])
    LPTRaw = DAQmxReadDigitalLines(lib,taskh.DIs,numSampsPerChan,timeout,fillMode,numchanDI,numsample);
end

% Setup non timing crucial variables
keep_going = true;
left_button_down = true;
right_button_down = true;
left_rt = NaN;
right_rt = NaN;
left_bar_rect = edata.display.elements.left_bar;
right_bar_rect = edata.display.elements.right_bar;
left_bar_stop_percent = NaN;
right_bar_stop_percent = NaN;
stimulation_ts_shouldfire = false;
stimulation_cs_shouldfire = false;
currentTime = 0;
lastDrawnTime = 0;
 

WaitSecs((max-min)*rand+min);
DAQmxWriteDigitalLines(lib,taskh.trigger,numSampsPerChan,timeout,dataLayout,1); % here you trigger by sending '1' to Signal
start_time = GetSecs; % Starting timing here so signal timing is accurate
WaitSecs(0.001);
DAQmxWriteDigitalLines(lib,taskh.trigger,numSampsPerChan,timeout,dataLayout,0); % put value '0' to end trigger
%% setup variables

fill_end_time = start_time + edata.parameters.time_fill;
% if GetSecs time reaches time for stimulation, send stimulus to TMS machine
if ~isnan(td.stimulation_time_ts)
    stimulation_ts = start_time + td.stimulation_time_ts/1000;
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
                DAQmxWriteDigitalLines(lib,taskh.tms,numSampsPerChan,timeout,dataLayout,[1 1]); % here you trigger by sending '1' to Signal
                WaitSecs(0.001);
                DAQmxWriteDigitalLines(lib,taskh.tms,numSampsPerChan,timeout,dataLayout,[0 0]); % put value '0' to end trigger
                stimulation_ts_shouldfire = false;
                stimulation_cs_shouldfire = false;
            else
                DAQmxWriteDigitalLines(lib,taskh.tms,numSampsPerChan,timeout,dataLayout,[1 0]); % here you trigger by sending '1' to Signal
                WaitSecs(0.001);
                DAQmxWriteDigitalLines(lib,taskh.tms,numSampsPerChan,timeout,dataLayout,[0 0]); % put value '0' to end trigger
                stimulation_ts_shouldfire = false;
            end
        end
    end
    
    if (currentTime - lastDrawnTime) >  (1 / 100) % Draw only a certain number of times a second 
        LPTRaw = DAQmxReadDigitalLines(lib,taskh.DIs,numSampsPerChan,timeout,fillMode,numchanDI,numsample);
        %LPTRaw = getvalue(parentuddobj,lineIndices);
    end
    if left_button_down && all(LPTRaw == [1; 0]) %[1 1 0 1 0]) % if left button was down and then only right button down
        left_button_down = false;
        left_rt = GetSecs - start_time;
        if isnan(left_bar_stop_percent)
            left_bar_stop_percent = left_rt / edata.parameters.time_fill;
        end
    end
    if right_button_down && all(LPTRaw == [0; 1]) %[1 0 1 1 0]) % if right button was down and then only left button down
        right_button_down = false;
        right_rt = GetSecs - start_time;
        if isnan(right_bar_stop_percent)
            right_bar_stop_percent = right_rt / edata.parameters.time_fill;
        end
    end
    if left_button_down && all(LPTRaw == [1; 1]) %[1 1 1 1 0]) % if left button was down and then neither button down
        left_button_down = false;
        left_rt = GetSecs - start_time;
        if isnan(left_bar_stop_percent)
            left_bar_stop_percent = left_rt / edata.parameters.time_fill;
        end
    end
    if right_button_down && all(LPTRaw == [1; 1]) %[1 1 1 1 0]) % if right button was down and then neither button down
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



