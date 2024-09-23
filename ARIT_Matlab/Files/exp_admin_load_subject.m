function [edata, trial_data] = exp_admin_load_subject(edata)
    
    trial_data = [];

%% get the subject id    
    
    fprintf('Available subjects:\n\t%s\n', mat2str(edata.files.behav.ids'));
    subject_id = input('Load what id: ');
    if isempty(subject_id), return; end
    
%% try loading files

    if edata.files.analysis(subject_id).exists
        response = input('Load ANALYSIS or original BEHAV file? (ENTER for ANALYSIS, "b" for BEHAV) ', 's');
        if isempty(response)
            subject_data = edata.files.analysis(subject_id).load;
        else                
            subject_data = edata.files.behav(subject_id).load;
        end;
    else
        subject_data = edata.files.behav(subject_id).load;
    end
    edata = subject_data.edata;
    trial_data = subject_data.trial_data;
    exp_admin_save_vars(edata, trial_data);
    exp_admin_status
    fprintf('Click to <a href="matlab:[edata, trial_data] = exp_analyze_subject(edata, trial_data);">analyze</a>\n');

end