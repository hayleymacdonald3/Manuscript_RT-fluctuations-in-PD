function [edata, trial_data] = exp_reset(edata, trial_data)
% Change current trial    

%% determine current trial    
    
    if isfield(edata, 'current_trial')
       trial = edata.current_trial;
    else
       fprintf('There is no trial variable, defaulting to trial=1\n');
       trial = 1;
    end

    fprintf('\nCurrently in block %d, at trial %d\n\n', trial_data{trial, 'block'}, trial);

%% get the menu choice

    menu_choices = {'Beginning', 'To Specific Block', 'To Specific Trial', 'Rewind # of Trials'};
    menu_choice = menu_str('How do you want to reset?', menu_choices);

%% calculate the trial number

    switch menu_choice
        case 'beginning'
            trial = 1;

        case 'to specific block'
            block_num = input('Enter block to reset to beginning of: ');
            if isempty(block_num), return; end;
            try
                trial = find(trial_data.block==block_num, 1, 'first');
            catch
                fprintf('Could not reset to block %d, cancelling reset\n', block_num)
                return
            end

        case 'to specific trial'
            trial = input('Enter trial to reset to: ');
            assert(trial >= 1, 'Trial can not be less than 1');
            assert(trial <= size(trial_data,1), 'Trial can not be more than total number of trials (%d)', size(trial_data,1));

        case 'rewind # of trials'
            rewind_count = input('Enter number of trial to rewind: ');
            if isempty(rewind_count), return; end;
            trial = max(1, trial - rewind_count);
            
        case 'cancel'
            return
    end
    
    edata.current_trial = trial;

%% adjust the trial data

    fprintf('Reseting to trial %d\n\n', trial);
    last_complete_trial = find(trial_data.complete, 1, 'last');
    skipped_trials = [last_complete_trial+1 : trial - 1]; %#ok<NBRAK>
    
    % if trials are being skipped, confirm this
    if any(skipped_trials)
        button = questdlg('WARNING: You are attempting to reset to a point that has not yet been reached','Reset Trials','Reset','Cancel','Reset');
        if strcmpi(button, 'reset')
            trial_data.complete(skipped_trials) = 1;
            trial_data.start_time(skipped_trials) = 0;
            trial_data.duration(skipped_trials) = 0;
        end
        
    % otherwise just mark past and future trials accordingly
    else
        trial_data.complete(trial:end) = 0;
        trial_data.start_time(trial:end) = NaN;
        trial_data.duration(skipped_trials) = NaN;
    end
    
    
end
