clc
clear all


% generate the trial pool for all blocks with specified numbers of trial
% conditons and stimulation times
% need unstimulated, single stim and double stim trials for Go and Stop trials
% 760 trials total, 456 Go & 264 Stop - 12/16/18 blocks of 30/45/40 *************************** DECIDE

% Go trials - unstimulated 308
trialPoolOriginal(161:468) = 1000;   

% Go trials for baseline measures of inhibition levels - 40 (348 simple Go in total)
trialPoolOriginal(1:20) = 1200;   % Go trials - single stimulate 200ms, 20NC pulses
trialPoolOriginal(21:40) = 1202;   % Go trials - double stimulate 200ms, 20C pulses (2ms ISI)

% Go trials after Stop trials 120 - to investigate lasting effecs on inhibition levels from stopping
trialPoolOriginal(41:60) = 2200;   % GASL trials, single stim 200ms NC 
trialPoolOriginal(61:80) = 2202;   % GASL trials - double stim 200ms C
trialPoolOriginal(81:100) = 3200;   % GASR trials, single stim 200ms NC 
trialPoolOriginal(101:120) = 3202;   % GASR trials - double stim 200ms C
trialPoolOriginal(121:140) = 4200;   % GASB trials, single stim 200ms NC 
trialPoolOriginal(141:160) = 4202;   % GASB trials - double stim 200ms C

% individual Stop trials 240 - crux of study hypothesis
trialPoolOriginal(481:500) = 5700; % StopRight trials, single stim 700ms NC
trialPoolOriginal(501:520) = 5702; % StopRight trials - double stim 700ms C
trialPoolOriginal(521:540) = 5775; % StopRight trials, single stim 775ms NC
trialPoolOriginal(541:560) = 5777; % StopRight trials - double stim 775ms C

trialPoolOriginal(561:580) = 6700; % StopLeft trials, single stim 700ms NC
trialPoolOriginal(581:600) = 6702; % StopLeft trials - double stim 700ms C
trialPoolOriginal(601:620) = 6775; % StopLeft trials, single stim 775ms NC
trialPoolOriginal(621:640) = 6777; % StopLeft trials - double stim 775ms C

trialPoolOriginal(641:660) = 7750; % StopBoth trials, single stim 750ms NC
trialPoolOriginal(661:680) = 7752; % StopBoth trials - double stim 750ms C
trialPoolOriginal(681:700) = 7825; % StopBoth trials, single stim 825ms NC
trialPoolOriginal(701:720) = 7827; % StopBoth trials - double stim 825ms C


% nuisance trials 12 - StopLeftStop, StopRightStop or StopBothStop 
trialPoolOriginal(469:472) = 8500; % StopRightStop trials - unstimulated - one for each stim time NC/C
trialPoolOriginal(473:476) = 8600; % StopLeftStop trials - unstimulated
trialPoolOriginal(477:480) = 8700; % StopBothStop trials - unstimulated



blockLength = 40; % 40/block gives 18 blocks
blockNumber = length(trialPoolOriginal)/blockLength;
experimentNumber = 1;

minForcedStartGo = 2;
%%%%%%%%%%%%%%%%%% NEED TO ADD GO_AFTER_STOP TRIALS 2000 < 5000
for experiment = 1:experimentNumber
    trialPoolRandomized = trialPoolOriginal(:,randperm(size(trialPoolOriginal,2)));
    trials = zeros(blockNumber,blockLength);
    % put in first forced go trials (can be double, single or un-stimulated)
    for i = 1:minForcedStartGo
        for j = 1:blockNumber
            % is a go trial
            index = find(trialPoolRandomized >= 1000 & trialPoolRandomized < 2000,1);
            trials(j,i) = trialPoolRandomized(index);
            trialPoolRandomized(index) = [];
        end
    end

    % put in stop trials after a go trial
    stopCount = length(find(trialPoolRandomized >= 5000 & trialPoolRandomized < 8000));
    for i = 1:stopCount;
        spaceFound = false;
        while ~spaceFound
            %%%%%%%%%%%%%%%%%%%%%%% causes problem when blockLength - 2 i.e. need two spaces after
            %%%%%%%%%%%%%%%%%%%%%%% Go trial which are empty, one after Stop trial is empty - but
            %%%%%%%%%%%%%%%%%%%%%%% currently means might not be enough Stop trials with empty following
            %%%%%%%%%%%%%%%%%%%%%%% trials to accommodate all GAS and SS trials (40 + 12 per Stop
            %%%%%%%%%%%%%%%%%%%%%%% condition, out of 80 total)
            trialIndex = randi([minForcedStartGo + 1, blockLength - 1]);
            blockIndex = randi(blockNumber);
            if sum(trials(blockIndex, trialIndex:trialIndex + 1)) == 0
                spaceFound = true;
            end
        end

        % find Go and Stop in trialPool
        indexA = find(trialPoolRandomized >= 1000 & trialPoolRandomized < 2000,1);
        indexB = find(trialPoolRandomized >= 5000 & trialPoolRandomized < 8000,1);
        
        % put found sequence in trials array
        trials(blockIndex, trialIndex) = trialPoolRandomized(indexA);
        trials(blockIndex, trialIndex + 1) = trialPoolRandomized(indexB);
        
        % remove used trials from trialPool
        trialPoolRandomized([indexA indexB]) = [];
    end

    
    % put in all GASL trials (40 total)
    % For all GASL trials, goes through all 80 of Stop Left trials, looks if following trial is 
    % empty - if it is, places GASL trial
    % Count all Go After Stop Left and Stop Left trials
    GASLCount = length(find(trialPoolRandomized >= 2000 & trialPoolRandomized < 3000));
    stopLeftCount = length(find(trialPoolOriginal >= 6000 & trialPoolOriginal < 7000));
    % create an initial vector the same length as number of Stop condition trials
    nArray = [1:stopLeftCount];
    for i = 1:GASLCount;
        spaceFound = false;        
        while ~spaceFound
            % generates a random number within the length of remaining Stop condition trials
            numGen = randi(length(nArray));
            % finds actual nth Stop trial
            n = nArray(numGen);
            % removes that Stop trial number from array as it's already been checked from this
            % point on
            nArray(numGen) = [];
            % finds first occurence of GAS trial
            indexC = find(trialPoolRandomized >= 2000 & trialPoolRandomized < 3000,1);
            % creates two vectors of corresponding row and column numbers for first n number of Stop 
            % condition trials in trial array
            [stopBlockIndex stopTrialIndex] = find(trials >= 6000 & trials < 7000,n);
            % gets value from coordinate in trial array
            chosenStopTrial = trials(stopBlockIndex(n),stopTrialIndex(n));
            % checks if there is empty trial after the Stop trial i.e. if number for stop trial is
            % followed by 0 ********************current problem when stop trial is at end of block,
            % coz stop trial + 1 exceeds matrix dimensions
            if sum(trials(stopBlockIndex(n),stopTrialIndex(n):stopTrialIndex(n)+1)) == chosenStopTrial
                spaceFound = true;
            end
        end
        % places GAS trial after Stop condition trial
        trials(stopBlockIndex(n),stopTrialIndex(n)+1) = trialPoolRandomized(indexC);
        % removes GAS trial from array
        trialPoolRandomized([indexC]) = [];
    end
    
    % put in all GASR trials (40 total)
    GASRCount = length(find(trialPoolRandomized >= 3000 & trialPoolRandomized < 4000));
    stopRightCount = length(find(trialPoolRandomized >= 5000 & trialPoolRandomized < 6000));
    for i = 1:GASRCount;
        spaceFound = false;
        while ~spaceFound
            nArray = [1:stopRightCount];
            n = randi(length(nArray));
            nArray([nArray(n)]) = [];
            indexD = find(trialPoolRandomized >= 3000 & trialPoolRandomized < 4000,1);
            [stopBlockIndex stopTrialIndex] = find(trials >= 5000 & trials < 6000,n);
            chosenStopTrial = trials(stopBlockIndex(n),stopTrialIndex(n));
            if sum(trials(stopBlockIndex(n),stopTrialIndex(n):stopTrialIndex(n)+1)) == chosenStopTrial
                spaceFound = true;
            end
        end
        trials(stopBlockIndex(n),stopTrialIndex(n)+1) = trialPoolRandomized(indexD);
        trialPoolRandomized([indexD]) = [];
    end
end
        
        
%     % count remaining stop trials
%     stopTrialCount = length(find(trialPoolRandomized >= 5000 & trialPoolRandomized < 8000));
%     spaceCount = 0;
%     spaces = [];
%     for j = 1:blockNumber
%        for i = minForcedStartGo + 1:blockLength
%             a = trials(j,i);
%             b = trials(j,i-1);
%             if a == 0 && (b == 0 || (b >= 5000 && b < 8000))
%                 spaceCount = spaceCount + 1;
%                 spaces(size(spaces,1)+1,1) = j;
%                 spaces(size(spaces,1),2) = i;
%             end
%         end
%     end
%     assert(spaceCount >= stopTrialCount, 'Insufficient spaces for stop trials, either overconstrained, or rerun and try again');
% 
%     % search for all spaces preceded by a go trial, or empty space
%     % put stop trials in a random one of these spaces, if there are none, start
%     % again
%     for i = 1:stopTrialCount
%         index = find(trialPoolRandomized >= 5000 & trialPoolRandomized < 8000,1);
%         spaceIndex = randi(size(spaces,1));
% 
%         trials(spaces(spaceIndex,1), spaces(spaceIndex,2)) = trialPoolRandomized(index);
%         trialPoolRandomized(index) = [];
% 
%         if spaceIndex == size(spaces,1)
%             if spaces(spaceIndex,2) == spaces(spaceIndex - 1,2) + 1
%                 spaces([spaceIndex - 1, spaceIndex],:) = [];
%             else
%                 spaces(spaceIndex,:) = [];
%             end
%         elseif spaceIndex == 1
%             if spaces(spaceIndex + 1,2) == spaces(spaceIndex,2) + 1
%                 spaces([spaceIndex + 1, spaceIndex],:) = [];
%             else
%                 spaces(spaceIndex,:) = [];
%             end
%         elseif spaces(spaceIndex,2) == spaces(spaceIndex - 1,2) + 1 && spaces(spaceIndex + 1,2) == spaces(spaceIndex,2) + 1
%             spaces([spaceIndex spaceIndex + 1 spaceIndex - 1],:) = [];
%         elseif spaces(spaceIndex,2) == spaces(spaceIndex - 1,2) + 1
%             spaces([spaceIndex spaceIndex - 1],:) = [];
%         elseif spaces(spaceIndex + 1,2) == spaces(spaceIndex,2) + 1
%             spaces([spaceIndex spaceIndex + 1],:) = [];
%         else
%             spaces(spaceIndex,:) = [];
%         end
%     end
% 
%     % fill rest of space with go trials
%     k = 1;
%     for j = 1:blockNumber
%        for i = 1:blockLength
%            if trials(j,i) == 0
%                trials(j,i) = trialPoolRandomized(k);
%                k = k + 1;
%            end
%        end
%     end
%     trialPoolRandomized = [];
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     textArray = cell(blockNumber*blockLength,3);
%     for i = 1:blockNumber
%         for j = 1:blockLength
%             if trials(i,j) == 1000
%                 textArray(j+(i-1)*blockLength,1) = {'go'};
%                 textArray(j+(i-1)*blockLength,2) = {'na'};
%                 textArray(j+(i-1)*blockLength,3) = {NaN};
%                 textArray(j+(i-1)*blockLength,4) = {NaN};
%             elseif trials(i,j) > 1000 && trials(i,j) < 2000
%                 textArray(j+(i-1)*blockLength,1) = {'go'};
%                 textArray(j+(i-1)*blockLength,2) = {'na'};
%                 textArray(j+(i-1)*blockLength,3) = {NaN};
%                 stimulationTime = trials(i,j) - 1000;
%                 textArray(j+(i-1)*blockLength,4) = {stimulationTime};
%             elseif trials(i,j) == 2000
%                 textArray(j+(i-1)*blockLength,1) = {'stop'};
%                 textArray(j+(i-1)*blockLength,2) = {'right'};
%                 textArray(j+(i-1)*blockLength,3) = {2};
%                 textArray(j+(i-1)*blockLength,4) = {NaN};
%             elseif trials(i,j) > 2000 && trials(i,j) < 3000
%                 textArray(j+(i-1)*blockLength,1) = {'stop'};
%                 textArray(j+(i-1)*blockLength,2) = {'right'};
%                 textArray(j+(i-1)*blockLength,3) = {2};
%                 stimulationTime = trials(i,j) - 2000;
%                 textArray(j+(i-1)*blockLength,4) = {stimulationTime}; 
%             elseif trials(i,j) == 3000 || trials(i,j) == 6000
%                 textArray(j+(i-1)*blockLength,1) = {'stop'};
%                 textArray(j+(i-1)*blockLength,2) = {'left'};
%                 textArray(j+(i-1)*blockLength,3) = {1};
%                 textArray(j+(i-1)*blockLength,4) = {NaN};  
%             elseif trials(i,j) == 4000 || trials(i,j) == 7000
%                 textArray(j+(i-1)*blockLength,1) = {'stop'};
%                 textArray(j+(i-1)*blockLength,2) = {'both'};
%                 textArray(j+(i-1)*blockLength,3) = {3};
%                 textArray(j+(i-1)*blockLength,4) = {NaN};  
%             elseif trials(i,j) == 5000 
%                 textArray(j+(i-1)*blockLength,1) = {'stop'};
%                 textArray(j+(i-1)*blockLength,2) = {'right'};
%                 textArray(j+(i-1)*blockLength,3) = {2};
%                 textArray(j+(i-1)*blockLength,4) = {NaN};
%             end            
%         end
%     end
%     outputArray(:,:,experiment) = textArray;
%end
