function [edata] = bar1_block_stats(edata, trial_data)
    
%% calculate statistics for all blocks

    go_trials = trial_data(trial_data.trial_type=='go', :);
    go_trials.rt = nanmean([go_trials.left_rt, go_trials.right_rt], 2) - edata.parameters.time_target;
    go_stats = grpstats(go_trials, 'block', {'mean', 'std'}, 'DataVars', {'rt', 'left_rt', 'right_rt', 'correct'});
    go_stats.correct = go_stats.mean_correct .* 100;
    go_stats.std_correct = [];
    
    stop_trials = trial_data(trial_data.trial_type=='stop', :);
    stop_stats = grpstats(stop_trials, 'block', {@mean}, 'DataVars', {'correct'});
    stop_stats.stopping_correct = stop_stats.mean_correct .* 100;
    
    edata.block_stats = dataset_join(go_stats, stop_stats(:, 'stopping_correct'));
    
    block_max = max(edata.block_stats.block);
    
%% graph formatting    

%     gf.x_label = 'Block';
    gf.x_lim = [0 block_max + 1];
%     gf.x_ticks = [1:block_max];
%     gf.x_tick_labels = horzcat({' '}, mat2cell_same_size(gf.x_ticks), {' '});
    gf.x_increment = 1;
    gf.font_size = 'tiny';

%% Reaction Time graph

    subplot(3,1,1)
    %plot(edata.block_stats.block, edata.block_stats.mean_rt, '-*b');
    errorbar(edata.block_stats.block, edata.block_stats.mean_rt, edata.block_stats.std_rt, '-*b');
    %gf.y_lim = [0 max_rt];
    gf.title = 'Lift time';
    gf.y_label = 'LT (secs)';
    graph_formatter(gf);
    set(gca, 'XTickLabelMode', 'Manual');
    set(gca,'Xtick',[]);

%% Go Accuracy graph

    subplot(3,1,2)
    plot(edata.block_stats.block, edata.block_stats.correct, '-*r');
    gf.y_lim = [0 100];
    gf.y_increment = 25;
    gf.title = 'Accuracy of going with correct fingers';
%     gf.x_label = 'Block';
    gf.y_label = '% Accuracy';
    graph_formatter(gf);
    set(gca, 'XTickLabelMode', 'Manual');
    set(gca,'Xtick',[]);

%% Stopping Accuracy graph

    subplot(3,1,3)
    plot(edata.block_stats.block, edata.block_stats.stopping_correct, '-*r');
    gf.y_lim = [0 100];
    gf.y_increment = 25;
    gf.title = 'Accuracy on stopping trials';
%     gf.x_label = 'Block';
    gf.y_label = '% Accuracy';
    graph_formatter(gf);
    set(gca, 'XTickLabelMode', 'Manual');
    set(gca,'Xtick',[]);

end
