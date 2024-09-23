function td2csv(trial_data, edata)

% Set cols to be the names of the columns you want in the final CSV, must
% be the same as the column names in trial_data
trialcols = {'subject', 'block', 'trial_num', 'trial_type', 'stop_side', 'bar_stop_time', 'ssd', 'start_time', 'duration', 'complete', 'left_rt', 'right_rt', 'outcome', 'correct'};
blockcols = {'block', 'GroupCount', 'mean_rt', 'std_rt', 'mean_left_rt', 'std_left_rt', 'mean_right_rt', 'std_right_rt', 'mean_correct', 'correct', 'stopping_correct'};

trialstats{length(trial_data),length(trialcols)} = {};
for j = 1:length(trialcols)
    y = char(trialcols(j));
    for i = 1:length(trial_data)
        z = eval(sprintf('trial_data.%s(i)', y));
        if isa(z, 'nominal')
            trialstats{i,j} = char(z);
        elseif isa(z, 'logical')
            if z
                trialstats{i,j} = 'true';
            else
                trialstats{i,j} = 'false';
            end
        else
            trialstats{i,j} = z;
        end
    end
end

blockstats{length(edata.block_stats),length(blockcols)} = {};
for j = 1:length(blockcols)
    y = char(blockcols(j));
    for i = 1:length(edata.block_stats)
        z = eval(sprintf('edata.block_stats.%s(i)', y));
        if isa(z, 'nominal')
            blockstats{i,j} = char(z);
        elseif isa(z, 'logical')
            if z
                blockstats{i,j} = 'true';
            else
                blockstats{i,j} = 'false';
            end
        else
            blockstats{i,j} = z;
        end
    end
end

trialdata = [trialcols ; trialstats];
blockdata = [blockcols; blockstats];

trialfilename = sprintf('data/s%d/%s_s%d_behav_trial_%s.csv', edata.subject_id, edata.files.exp_abbr, edata.subject_id, date);
blockfilename = sprintf('data/s%d/%s_s%d_behav_block_%s.csv', edata.subject_id, edata.files.exp_abbr, edata.subject_id, date);
% trialfilename = 'test.csv';
% blockfilename = 'test2.csv';

cellwrite(trialfilename, trialdata)
cellwrite(blockfilename, blockdata)
