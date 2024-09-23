function [edata, trial_data] = exp_run(edata, trial_data, practice_data)

    % ensure that we are not in practice mode and the stop flag is cleared
    edata.run_mode.practice = false;
    edata.run_mode.stop_asap = false;

%% start the PsychToolbox screen

    [edata] = exp_display_start(edata);

%% iterate until all lines have been completed

    while ~all(trial_data.complete) && ~edata.run_mode.stop_asap
        
        % save data variables in current state
        exp_admin_save_vars(edata, trial_data, practice_data);

        % find first incomplete trial
        edata.current_trial = find(~trial_data.complete, 1, 'first');

        % take any needed action at the beginning of a new block
        [edata, trial_data] = exp_block_start(edata, trial_data);

        % actual trial - get response and process
        [edata, trial_data] = exp_trial(edata, trial_data);

        % save after each trial
        %exp_admin_save_subject_behav(edata, trial_data, practice_data);

        % provide feedback before transition to next block and on last trial
        [edata, trial_data] = exp_block_end(edata, trial_data);

        % if the stop flag has been set, exit nicely
        if edata.run_mode.stop_asap
           exp_stop(edata, trial_data, practice_data) 
        end

    end

%% end experiment    
    if all(trial_data.complete)
        exp_stop(edata, trial_data, practice_data)
        fprintf('Experiment complete!\n')
    end
    
end
