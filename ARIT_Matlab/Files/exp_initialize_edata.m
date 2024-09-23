function [edata] = exp_initialize_edata
    
    edata.subject_id = 0;
    edata.run_mode.debug = false;
    edata.run_mode.practice = false; 
    edata.run_mode.simulate = false;
    edata.files = exp_files;

end