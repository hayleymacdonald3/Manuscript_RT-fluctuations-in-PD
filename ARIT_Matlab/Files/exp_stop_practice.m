function exp_stop_practice(edata, practice_data)
    evalc('clear Screen');
    %ListenChar(0);
    fprintf('Experiment stopped at trial %d\n', edata.current_trial);
    exp_admin_save_vars_practice(edata, practice_data);
    exp_admin_save_subject_behav_practice(edata, practice_data);
end
    