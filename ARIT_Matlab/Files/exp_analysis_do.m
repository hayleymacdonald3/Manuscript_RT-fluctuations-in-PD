function [edata, trial_data] = exp_analysis_do(edata, trial_data)
    
    fprintf('Beginning analysis of subject %d...\n', edata.subject_id);
    
    fprintf('Only analysis implemented is block stats')
    edata = stop1_block_stats(edata, trial_data);

    fprintf('\n');
    fprintf('Completed analysis of subject %d.\n', edata.subject_id);    
    
end