function [edata] = exp_initialize_audio(edata)

%% example 1: create a beep from scratch using a PsychToolbox function   

    beep_duration = 0.1;
    beep_volume = 0.2;
    edata.audio.stop_freq = 20000;
    edata.audio.stop_wav = MakeBeep(edata.audio.stop_freq, beep_duration);
    % change volume
    edata.audio.stop_wav = edata.audio.stop_wav .* beep_volume;    
    % make it 2-channel (stereo)
    edata.audio.stop_wav = repmat(edata.audio.stop_wav, 2, 1);
    
%% example 2: load a sound form a file

    % locate the chord.wav file in the config directory of the experiment directory
    %   filesep() returns the directory separator for the current platform (e.g. / for mac, \ for pc)
    
    % to use this, uncomment the lines below, and comment out the section above
%    wav_file = [edata.file.base_dir filesep() 'config' filesep() 'chord.wav'];
%    [edata.sound.stop_wav, edata.sound.stop_freq] = wavread(wav_file);
    
%% PC Version

    % if running on a PC, no more prepartion is required (not using PsychPortAudio)
    if ispc
        % intentionally left blank
    
%% Mac Version

    % if running on a mac, initialize psychportaudio
    else
        if edata.run_mode.debug
            InitializePsychSound;
            edata.audio.port = ...
                PsychPortAudio('Open', [], [], 0, edata.audio.stop_freq, 2);
        else
            % if not in debug mode, run using evalc()
            %   evalc() captures the many lines of feedback these commands create.
            %   however, if there is an error, you'll want to see these
            %   (so use debug mode)
            edata.audio.messages.init = evalc('InitializePsychSound');
            [edata.audio.messages.port, edata.audio.port] = ...
                evalc('PsychPortAudio(''Open'', [], [], 0, edata.audio.stop_freq, 2)');
        end
    end
        
%% test sound

    exp_audio_prep_stop_signal(edata);
    exp_audio_play_stop_signal(edata);
        
end