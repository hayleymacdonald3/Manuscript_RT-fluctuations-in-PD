function exp_admin_save_vars_practice(ed, p_data)
   display('EXP ADMIN SAVE VARS PRACTIVE');
    assignin('base', 'edata', ed);
%     if ~isempty(trial_data)
%         assignin('base', 'trial_data', trial_data);
%     end
    if ~isempty(p_data)
        assignin('base', 'practice_data', p_data);
    end
    
end
