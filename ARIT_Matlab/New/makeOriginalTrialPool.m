function trialPoolOriginal = makeOriginalTrialPool

% generate the trial pool for all blocks with specified numbers of trial
% conditons - no stimulated trials
% 248 trials total, 170 Go & 78 Stop - 8 blocks of 31 currently 


% Go trials - unstimulated 
[trialPoolOriginal(1:129).trial_type] = deal('go');
[trialPoolOriginal(1:129).stop_side] = deal('na');
[trialPoolOriginal(1:129).bar_stop_time] = deal(NaN);
[trialPoolOriginal(1:129).stim_time_ts] = deal(NaN);
[trialPoolOriginal(1:129).stim_time_cs] = deal(NaN);
[trialPoolOriginal(1:129).stim_type] = deal('none');
[trialPoolOriginal(1:129).added_info] = deal('none');

% Extra Go trials - not put into combos, stay separate
[trialPoolOriginal(130:162).trial_type] = deal('go');
[trialPoolOriginal(130:162).stop_side] = deal('na');
[trialPoolOriginal(130:162).bar_stop_time] = deal(NaN);
[trialPoolOriginal(130:162).stim_time_ts] = deal(NaN);
[trialPoolOriginal(130:162).stim_time_cs] = deal(NaN);
[trialPoolOriginal(130:162).stim_type] = deal('none');
[trialPoolOriginal(130:162).added_info] = deal('extra');

% Stop Left trials - unstimulated
[trialPoolOriginal(163:188).trial_type] = deal('stop');
[trialPoolOriginal(163:188).stop_side] = deal('left');
[trialPoolOriginal(163:188).bar_stop_time] = deal(1);
[trialPoolOriginal(163:188).stim_time_ts] = deal(NaN);
[trialPoolOriginal(163:188).stim_time_cs] = deal(NaN);
[trialPoolOriginal(163:188).stim_type] = deal('none');
[trialPoolOriginal(163:188).added_info] = deal('none');

% Stop Right trials - unstimulated
[trialPoolOriginal(189:214).trial_type] = deal('stop');
[trialPoolOriginal(189:214).stop_side] = deal('right');
[trialPoolOriginal(189:214).bar_stop_time] = deal(2);
[trialPoolOriginal(189:214).stim_time_ts] = deal(NaN);
[trialPoolOriginal(189:214).stim_time_cs] = deal(NaN);
[trialPoolOriginal(189:214).stim_type] = deal('none');
[trialPoolOriginal(189:214).added_info] = deal('none');

% Stop Both trials - unstimulated
[trialPoolOriginal(215:240).trial_type] = deal('stop');
[trialPoolOriginal(215:240).stop_side] = deal('both');
[trialPoolOriginal(215:240).bar_stop_time] = deal(3);
[trialPoolOriginal(215:240).stim_time_ts] = deal(NaN);
[trialPoolOriginal(215:240).stim_time_cs] = deal(NaN);
[trialPoolOriginal(215:240).stim_type] = deal('none');
[trialPoolOriginal(215:240).added_info] = deal('none');

% Additional extra go trials needed (extra 1 per block, making 31 trials
% per block)
[trialPoolOriginal(241:248).trial_type] = deal('go');
[trialPoolOriginal(241:248).stop_side] = deal('na');
[trialPoolOriginal(241:248).bar_stop_time] = deal(NaN);
[trialPoolOriginal(241:248).stim_time_ts] = deal(NaN);
[trialPoolOriginal(241:248).stim_time_cs] = deal(NaN);
[trialPoolOriginal(241:248).stim_type] = deal('none');
[trialPoolOriginal(241:248).added_info] = deal('extra');
end
