function exp_stop(edata, trial_data, practice_data)
    evalc('clear Screen');
    %ListenChar(0);
    fprintf('Experiment stopped at trial %d\n', edata.current_trial);
    exp_admin_save_vars(edata, trial_data, practice_data);
    exp_admin_save_subject_behav(edata, trial_data, practice_data);
end
    