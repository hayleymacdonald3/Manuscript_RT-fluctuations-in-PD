function [edata, trial_data, practice_data] = exp_run_practice(edata, trial_data, practice_data)
   
   edata.run_mode.practice = false;
   edata.run_mode.stop_asap = false;
   
   %% start the PsychToolbox screen
   
   [edata] = exp_display_start(edata);
   
%     while ~all(practice_data.complete) && ~edata.run_mode.stop_asap
%         if get_key_press(edata.inputs.main_keyboard_index, -1, edata.inputs.quit_key, false)
%             edata.run_mode.stop_asap = true;
%             exp_stop
%             return
%         end
%         edata.current_trial = find(~practice_data.complete, 1, 'first');
%         [edata, practice_data] = exp_trial(edata, practice_data);
%     end
   
   
   % copied from exp_run
   
   while ~all(practice_data.complete) && ~edata.run_mode.stop_asap
      % save data variables in current state
      exp_admin_save_vars(edata, trial_data, practice_data);
      
      % find first incomplete trial
      edata.current_trial = find(~practice_data.complete, 1, 'first');
      
      % take any needed action at the beginning of a new block
      [edata, practice_data] = exp_block_start_practice(edata, practice_data);
      
      % actual trial - get response and process
      [edata, practice_data] = exp_trial_practice(edata, practice_data);
      
      % save after each trial
      %exp_admin_save_subject_behav(edata, trial_data, practice_data);
      
      % provide feedback before transition to next block and on last trial
      [edata, practice_data] = exp_block_end_practice(edata, practice_data);
      
      % if the stop flag has been set, exit nicely
      if edata.run_mode.stop_asap
         exp_stop(edata, trial_data, practice_data)
      end
      
   end
   
   %% end experiment
   if all(practice_data.complete)
      exp_stop(edata, trial_data, practice_data)
      fprintf('Experiment complete!\n')
   end
   
   
   
end