% makePracticeDataStructs - same struct will be used for practice option as
% well as first two blocks of proper experiment

clc
clear all
close all

% Control variables
blockLength = 31;
blockNumber = 2;
experimentNumber = 200;

[practiceDataStructs(1:61).trial_type] = deal('go');
[practiceDataStructs(1:61).stop_side] = deal('na');
[practiceDataStructs(1:61).bar_stop_time] = deal(NaN);
[practiceDataStructs(1:61).stim_time_ts] = deal(NaN);
[practiceDataStructs(1:61).stim_time_cs] = deal(NaN);
[practiceDataStructs(1:61).stim_type] = deal('none');
[practiceDataStructs(1:61).added_info] = deal('practice');

% totalLength = 1;
% while totalLength <= (blockLength*blockNumber)
    for insertStop = blockLength:blockLength:(blockLength*blockNumber)
        [practiceDataStructs(insertStop).trial_type] = deal('stop');
        [practiceDataStructs(insertStop).stop_side] = deal('both');
        [practiceDataStructs(insertStop).bar_stop_time] = deal(4);
        [practiceDataStructs(insertStop).stim_time_ts] = deal(NaN);
        [practiceDataStructs(insertStop).stim_time_cs] = deal(NaN);
        [practiceDataStructs(insertStop).stim_type] = deal('none');
        [practiceDataStructs(insertStop).added_info] = deal('practice');
    end
% end


practiceArray = cell(blockNumber*blockLength,3);
for i = 1:blockNumber
    for j = 1:blockLength       
        practiceArray(j+(i-1)*blockLength,1) = {(practiceDataStructs(1).trial_type)};
        practiceArray(j+(i-1)*blockLength,2) = {(practiceDataStructs(1).stop_side)};
        practiceArray(j+(i-1)*blockLength,3) = {(practiceDataStructs(1).bar_stop_time)};
        practiceArray(j+(i-1)*blockLength,4) = {(practiceDataStructs(1).stim_time_ts)};
        practiceArray(j+(i-1)*blockLength,5) = {(practiceDataStructs(1).stim_time_cs)};
        practiceDataStructs(1) = [];
    end
end


for experiment = 1:experimentNumber
    practiceDataArray(:,:,experiment) = practiceArray;
end