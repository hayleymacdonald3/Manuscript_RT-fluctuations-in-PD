function exp_analysis_open_html(edata, trial_data)
   
    html_file = edata.files.html(edata.subject_id);
    
    if ~exist(html_file, 'file')
        exp_analysis_publish(edata, trial_data);
    end
                
    system(sprintf('open %s', html_file))
    
end