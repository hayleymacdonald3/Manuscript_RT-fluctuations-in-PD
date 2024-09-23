

clc
clear all

trialPoolOriginal = makeOriginalTrialPool;

blockLength = 31; % 31/block gives 8 blocks
blockNumber = length(trialPoolOriginal)/blockLength;
experimentNumber = 200;

for experiment = 1:experimentNumber
permutation = randperm(length(trialPoolOriginal));
trialPoolRandomized = trialPoolOriginal(permutation);

trialPatternArray = makeComboArray(trialPoolRandomized);
permutation = randperm(length(trialPatternArray));
trialPatternsRandomized = trialPatternArray(permutation);

% loop through each cell of trialFinalPositionArray and add contents of arrays from each cell of
% trialPatternsRandomized - first prefill unstim Go trial at beginning of each block


% prefilling a Go trial at beginning of each block
for i = 1:blockNumber
    keepGoing = 1;
    h = 1;
    while keepGoing        
        if strcmp({trialPatternsRandomized{h}{1}.added_info}, 'extra'); % && strcmp({trialPatternsRandomized.added_info},'none');
            trialFinalPositionArray(i,1) = trialPatternsRandomized{h}{1};
            trialPatternsRandomized(h) = [];
            keepGoing = 0;
        else
            h = h + 1;
        end
    end
end

% separating out combos into individual trials in array
for j = 1:blockNumber
    k = 2;
    while k <= blockLength          
            if length(trialPatternsRandomized{1}) == 3 && k <= blockLength - 2
                trialFinalPositionArray(j,k) = trialPatternsRandomized{1}{1}; 
                trialFinalPositionArray(j,k+1) = trialPatternsRandomized{1}{2};
                trialFinalPositionArray(j,k+2) = trialPatternsRandomized{1}{3}; 
                k = k + 3;
                trialPatternsRandomized(1) = [];  
            elseif length(trialPatternsRandomized{1}) == 1; %&& (strcmp({trialPatternsRandomized{1}{1}.added_info}, 'none') || strcmp({trialPatternsRandomized{1}{1}.added_info}, 'laterGo'))              
                trialFinalPositionArray(j,k) = trialPatternsRandomized{1}{1}; 
                k = k + 1;
                trialPatternsRandomized(1) = []; 
            else
                keepGoing = 1;
                h = 1;
                while keepGoing
                    if strcmp({trialPatternsRandomized{h}{1}.added_info}, 'extra'); 
                        trialFinalPositionArray(j,k) = trialPatternsRandomized{h}{1};
                        trialPatternsRandomized(h) = [];
                        keepGoing = 0;
                        k = k + 1;
                    else
                        h = h + 1;
                    end
                end
            end
    end
end


textArray = cell(blockNumber*blockLength,3);
for i = 1:blockNumber
    for j = 1:blockLength
        strcmp({trialFinalPositionArray(i,j).trial_type}, 'go') &  strcmp({trialFinalPositionArray(i,j).stim_type}, 'none');
        textArray(j+(i-1)*blockLength,1) = {(trialFinalPositionArray(i,j).trial_type)};
        textArray(j+(i-1)*blockLength,2) = {(trialFinalPositionArray(i,j).stop_side)};
        textArray(j+(i-1)*blockLength,3) = {(trialFinalPositionArray(i,j).bar_stop_time)};
        textArray(j+(i-1)*blockLength,4) = {(trialFinalPositionArray(i,j).stim_time_ts)};
        textArray(j+(i-1)*blockLength,5) = {(trialFinalPositionArray(i,j).stim_time_cs)};
    end
end
trialDataArray(:,:,experiment) = textArray;
end


