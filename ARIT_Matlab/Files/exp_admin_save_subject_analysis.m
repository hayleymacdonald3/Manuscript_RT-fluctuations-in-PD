function exp_admin_save_subject(edata, trial_data, practice_data)
    
    save(edata.files.analysis(edata.subject_id), 'edata', 'trial_data', 'practice_data');
    fprintf('Analysis file for subject %d has been saved\n', edata.subject_id);
    
end
