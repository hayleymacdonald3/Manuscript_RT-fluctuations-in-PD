function exp_admin_save_vars(edata, trial_data, practice_data)
    assignin('base', 'edata', edata);
    if ~isempty(trial_data)
        assignin('base', 'trial_data', trial_data);
    end
     if ~isempty(practice_data)
         assignin('base', 'practice_data', practice_data);
     end
    
end
