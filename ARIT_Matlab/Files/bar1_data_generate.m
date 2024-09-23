function [edata, trial_data, practice_data] = bar1_data_generate(edata)

    trial_data = [];
    practice_data = [];
    
    % seed random generator
    rand('state', edata.subject_id);    
    
%% parameters    
    
    edata.parameters.block_count = 10;
    edata.parameters.trials_per_block = 31;
    edata.parameters.trial_count = 310;
    edata.parameters.practice_block_count = 2;
    edata.parameters.practice_trials_per_block = 31;
    edata.parameters.practice_trial_count = 62;
%     edata.parameters.trialset_length = 12;
%     edata.parameters.trialsets_count = edata.parameters.trial_count / edata.parameters.trialset_length;
    
    edata.parameters.time_fill = 1; % 1 second to fill bars
    edata.parameters.time_target = 0.8; % 800 ms target release time
    edata.parameters.time_tolerance = 0.03; % must be within 30 ms of the target
    
%% staircases

    %   1 - stopping left
    %   2 - stopping right
    %   3 - stopping both
    %   4 - stopping both really early

    edata.parameters.ssd.staircase_values = [.500 .500 .500 .050];
    edata.parameters.ssd.increment = .025;
    edata.parameters.ssd.minimum = .050;

%% build data

    load('C:\Users\Hayley\My Documents\University\PhD\PhD\MATLAB\ARI task Impulsivity study\New\trialDataArray');
    load('C:\Users\Hayley\My Documents\University\PhD\PhD\MATLAB\ARI task Impulsivity study\New\practiceDataArray');

%     load('C:\Documents and Settings\Boss\Desktop\MatLab task Neurophys 2\New\outputArray');
%     load('C:\Documents and Settings\Boss\Desktop\MatLab task Neurophys 2\New\finalAdditionArray');
    
    subjectNumber = edata.subject_id;
    trial_data = dataset({[practiceDataArray(:,:,subjectNumber);trialDataArray(:,:,subjectNumber)], 'trial_type', 'stop_side', 'bar_stop_time', 'stimulation_time_ts', 'stimulation_time_cs'});
    practice_data = dataset({practiceDataArray(:,:,subjectNumber), 'trial_type', 'stop_side', 'bar_stop_time', 'stimulation_time_ts', 'stimulation_time_cs'});
    
    %trial_data = dataset({[finalAdditionArray(:,:,subjectNumber);outputArray(:,:,subjectNumber)],'trial_type', 'stop_side', 'staircase'}); %example from Uncoupling
    %Response Inhibition script showing joining practice and trial arrays
    
%     trialset_data = dataset({{...
%                 'go'      'na'     NaN  ;...
%                 'go'      'na'     NaN  ;...
%                 'go'      'na'     NaN  ;...
%                 'go'      'na'     NaN  ;...
%                 'go'      'na'     NaN  ;...
%                 'go'      'na'     NaN  ;...
%                 'go'      'na'     NaN  ;...
%                 'go'      'na'     NaN  ;...
%                 'go'      'na'     NaN  ;...
%                 'stop'    'left'   1    ;...
%                 'stop'    'right'  2    ;...
%                 'stop'    'both'   3    ;...
%             }, 'trial_type', 'stop_side', 'staircase'});
        
    trial_data = dataset_nominalize_fields(trial_data, {'trial_type', 'stop_side', 'bar_stop_time', 'stimulation_time_ts', 'stimulation_time_cs'});
    practice_data = dataset_nominalize_fields(practice_data, {'trial_type', 'stop_side', 'bar_stop_time', 'stimulation_time_ts', 'stimulation_time_cs'}); 
    
    % add block number
    trial_data.block = expandmat([1:edata.parameters.block_count]', size(trial_data,1) ./ edata.parameters.block_count);
    practice_data.block = expandmat([1:edata.parameters.practice_block_count]', size(practice_data,1) ./ edata.parameters.practice_block_count);
                        
%% finish
  
    [edata, trial_data] = bar1_data_finish(edata, trial_data);
    [edata, practice_data] = bar1_data_finish_practice(edata, practice_data);

end