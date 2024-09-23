function trialPatternArray = makeComboArray(tPR)
% fill from most important type of trial to least specific 
% first fill GoStopStop combos, then GoStopGo (no stimulations to worry
% about)

% % for i = 1:20
% %     % first generated combo of single stim GASL trials 
% %     index = find(strcmp({tPR.trial_type},'go') & strcmp({tPR.stim_type},'single') & strcmp({tPR.added_info},'none'),1); % find single stim Go trial @ 200ms
% %     trialPatternArray{i}{3} = tPR(index);
% %     tPR(index) = [];
% %     index = find(strcmp({tPR.trial_type},'stop') & strcmp({tPR.stop_side},'left') & (strcmp({tPR.stim_type},'single') | strcmp({tPR.stim_type},'double')),1); % find stimulated stop left trial
% %     trialPatternArray{i}{2} = tPR(index);
% %     tPR(index) = [];
% % 
% % 
% %     % second generated combo of double stim GASL trials 
% %     index = find(strcmp({tPR.trial_type},'go') & strcmp({tPR.stim_type},'double') & strcmp({tPR.added_info},'none'),1); % find double stim Go trial @ 200ms
% %     trialPatternArray{i+20}{3} = tPR(index);
% %     tPR(index) = [];
% %     index = find(strcmp({tPR.trial_type},'stop') & strcmp({tPR.stop_side},'left') & (strcmp({tPR.stim_type},'single') | strcmp({tPR.stim_type},'double')),1); 
% %     trialPatternArray{i+20}{2} = tPR(index);
% %     tPR(index) = [];
% % 
% %     % first generated combo of single stim GASR trials 
% %     index = find(strcmp({tPR.trial_type},'go') & strcmp({tPR.stim_type},'single') & strcmp({tPR.added_info},'none'),1); % find single stim Go trial
% %     trialPatternArray{i+40}{3} = tPR(index);
% %     tPR(index) = [];
% %     index = find(strcmp({tPR.trial_type},'stop') & strcmp({tPR.stop_side},'right') & (strcmp({tPR.stim_type},'single') | strcmp({tPR.stim_type},'double')),1); % find stop right trial
% %     trialPatternArray{i+40}{2} = tPR(index);
% %     tPR(index) = [];
% % 
% % 
% %     % second generated combo of double stim GASR trials 
% %     index = find(strcmp({tPR.trial_type},'go') & strcmp({tPR.stim_type},'double') & strcmp({tPR.added_info},'none'),1); % find double stim Go trial
% %     trialPatternArray{i+60}{3} = tPR(index);
% %     tPR(index) = [];
% %     index = find(strcmp({tPR.trial_type},'stop') & strcmp({tPR.stop_side},'right') & (strcmp({tPR.stim_type},'single') | strcmp({tPR.stim_type},'double')),1); 
% %     trialPatternArray{i+60}{2} = tPR(index);
% %     tPR(index) = [];
% %     
% % 
% %     % first generated combo of single stim GASB trials 
% %     index = find(strcmp({tPR.trial_type},'go') & strcmp({tPR.stim_type},'single') & strcmp({tPR.added_info},'none'),1); % find single stim Go trial
% %     trialPatternArray{i+80}{3} = tPR(index);
% %     tPR(index) = [];
% %     index = find(strcmp({tPR.trial_type},'stop') & strcmp({tPR.stop_side},'both') & (strcmp({tPR.stim_type},'single') | strcmp({tPR.stim_type},'double')),1); % find stop both trial
% %     trialPatternArray{i+80}{2} = tPR(index);
% %     tPR(index) = [];
% % 
% % 
% %     % second generated combo of double stim GASB trials 
% % index = find(strcmp({tPR.trial_type},'go') & strcmp({tPR.stim_type},'double') & strcmp({tPR.added_info},'none'),1); % find double stim Go trial
% %     trialPatternArray{i+100}{3} = tPR(index);
% %     tPR(index) = [];
% %     index = find(strcmp({tPR.trial_type},'stop') & strcmp({tPR.stop_side},'both') & (strcmp({tPR.stim_type},'single') | strcmp({tPR.stim_type},'double')),1); 
% %     trialPatternArray{i+100}{2} = tPR(index);
% %     tPR(index) = [];
% % end

for j = 1:3 %length(trialPatternArray)+1:length(trialPatternArray)+4
    % first generated combo of stop after stop left trials 
    index = find(strcmp({tPR.trial_type},'stop'),1); % find stop trial
    trialPatternArray{j}{3} = tPR(index);
    tPR(index) = [];
    index = find(strcmp({tPR.trial_type},'stop') & strcmp({tPR.stop_side},'left'),1); % find stop left trial
    trialPatternArray{j}{2} = tPR(index);
    tPR(index) = [];

    % first generated combo of unstim stop after stop right trials 
    index = find(strcmp({tPR.trial_type},'stop'),1); % find stop trial
    trialPatternArray{j+3}{3} = tPR(index);
    tPR(index) = [];
    index = find(strcmp({tPR.trial_type},'stop') & strcmp({tPR.stop_side},'right'),1); % find stop right trial
    trialPatternArray{j+3}{2} = tPR(index);
    tPR(index) = [];

    % first generated combo of unstim stop after stop both trials 
    index = find(strcmp({tPR.trial_type},'stop'),1); % find unstim stop trial
    trialPatternArray{j+6}{3} = tPR(index);
    tPR(index) = [];
    index = find(strcmp({tPR.trial_type},'stop') & strcmp({tPR.stop_side},'both'),1); % find stop both trial
    trialPatternArray{j+6}{2} = tPR(index);
    tPR(index) = [];
end

for k = length(trialPatternArray)+1:length(trialPatternArray)+60 
    % combo of stop and go trial - any types
    index = find(strcmp({tPR.trial_type},'go') & strcmp({tPR.added_info},'none'),1); % find  non-extra go trial
    trialPatternArray{k}{3} = tPR(index);
    tPR(index) = [];
    index = find(strcmp({tPR.trial_type},'stop'),1); % find any stop trial
    trialPatternArray{k}{2} = tPR(index);
    tPR(index) = [];
end

for l = 1:length(trialPatternArray)
    index = find(strcmp({tPR.trial_type},'go') & strcmp({tPR.added_info},'none'),1); % find any non-extra go trial
    trialPatternArray{l}{1} = tPR(index);
    tPR(index) = [];
end
    
% length(trialPatternArray)+1
% length(trialPatternArray)+length(tPR)

for m = length(trialPatternArray)+1:length(trialPatternArray)+length(tPR)
    index = find(strcmp({tPR.trial_type},'go') & strcmp({tPR.added_info},'extra'),1); % find any extra go trial
    trialPatternArray{m}{1} = tPR(index);
    tPR(index) = [];
end



end





