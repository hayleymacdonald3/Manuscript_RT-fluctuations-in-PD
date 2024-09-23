function exp_analysis_publish(edata, trial_data)
    
    report_file = which('exp_analysis_report');
    publish_clean(report_file, edata.files.html(edata.subject_id), 'html', false);
    
end
