function [edata, trial_data, practice_data] = exp_admin_menu(edata, trial_data, command, practice_data)
        
    
    while ~isempty(command)
        next_command = {};
    
        switch command

%% basic options

            case 'cancel'
                return

            case {'initialize', 'init'}
                [edata, trial_data] = exp_initialize;

            case 'run'
                [edata, trial_data] = exp_run(edata, trial_data, practice_data);

            case 'reset'
                [edata, trial_data] = exp_reset(edata, trial_data);

            case 'status'
                exp_admin_status();
                
            case {'list files', 'ls'}
                exp_admin_file_links;

%% change settings            

            case 'change settings'
                menu_commands = { ...
                    'Inputs', ...
                    'Display', ...
                    'Sound', ...
                    'Update File Locs', ...
                    'Cancel' ...
                    };
                next_command = menu_str('Change what setup?', menu_commands);

            case 'data'
                [edata, trial_data] = exp_data_generate(edata);
                
            case 'inputs'
                [edata] = exp_initialize_inputs(edata);
                
            case 'display'
                [edata] = exp_initialize_display(edata);
                
            case 'sound'
                [edata] = exp_initialize_audio(edata);
                
            case 'update file locs'
                edata.files = exp_files();


%% show feedback            

            case 'feedback'
                [edata, trial_data] = exp_block_feedback(edata, trial_data);
                cls

%% load/save an existing subject            

            case {'load subject', 'load'}
                [edata, trial_data] = exp_admin_load_subject(edata);

            case {'save subject', 'save'}
                assert(logical(exist('edata', 'var')), 'The edata variable does not exist');
                assert(logical(exist('trial_data', 'var')), 'The trial_data variable does not exist');
                exp_admin_save_subject_analysis(edata, trial_data, practice_data);

%% analysis            

            case 'analyze'
                [edata, trial_data] = exp_analysis_do(edata, trial_data);
                exp_admin_save_vars(edata, trial_data);
                exp_analysis_report

            case 'report'
                exp_analysis_publish(edata, trial_data);
                exp_analysis_open_html(edata, trial_data);

%% administrative options            

            case 'admin'

                next_command = menu_str('Which function?', {'Create Zips', 'Create Help'});

            case 'create zips'
                exp_admin_zip(edata);

            case 'create help'
                if ~exist('m2html', 'file'), fprintf('The <a href="http://www.artefact.tk/software/matlab/m2html/">m2html library</a> could not be found\n'); return; end;
                m2html('mfiles', edata.files.base_dir, 'htmldir','help', 'recursive','on','globalHypertextLinks','on')

%% unrecognized commands

            otherwise
                fprintf('Unrecognized command: %s\n', command);

        end
        
    command = next_command;
    end
    
end