% Make a global because I am lazy
clc
clear all
global allTrialSettings;

%% Settings
allTrialSettings.processHC = false;
allTrialSettings.writeOutputFiles = true;
allTrialSettings.trimOutputFiles = false;
allTrialSettings.trialTrimLength = 170;
allTrialSettings.trialTrimLength3SD = 170;
allTrialSettings.trialTrimLength5SD = 170;

if allTrialSettings.processHC
    % Healthy controls
    inputDirectory = fullfile("..", "HC_data_PhD study", "raw");
    outputDirectory = fullfile("..", "HC_data_PhD study", "output");
    outputSummaryFilename = 'output_summary.csv';
    directoryList = cleanDirList(inputDirectory);

    % Get list of trial_data.txt files
    fileList = [];
    for i = 1:length(directoryList)
        behaviouralPath = fullfile(inputDirectory, directoryList(i).name, "Med A", "ARI", "Behavioural");
        subjectCodeDir = cleanDirList(behaviouralPath);
        disp(subjectCodeDir(1).name);
        trial_data_path = dir(fullfile(behaviouralPath, subjectCodeDir(1).name, "trial_data.txt"));
        % check file exists
        if ~isempty(trial_data_path)
            fileList = [fileList; trial_data_path];
        else
            disp(["No trial_data.txt file found: " trial_data_path.folder]);
        end
    end
else
    % PD patients
    inputDirectory = fullfile("..", "PD_data_online study", "raw");
    outputDirectory = fullfile("..", "PD_data_online study", "output");
    outputSummaryFilename = 'output_summary.csv';

    % Load files
    fileList = cleanFilesList(inputDirectory);
    % Remove files without the .iqdat extension
    fileList = fileList(~cellfun(@isempty, regexp({fileList.name}, '\.iqdat$')));
end

allTrialSettings.lowestTrialCount = Inf;
allTrialSettings.lowestTrialCountTrimmed3SD = Inf;
allTrialSettings.lowestTrialCountTrimmed5SD = Inf;
outputSummaryTable = table();

% Loop through files, import, extract data, process and save, write summary data
opts = [];
for k = 1:length(fileList)
    trialData = struct;

    filePath = fullfile(fileList(k).folder, fileList(k).name);
    trialData.inputFile = string(filePath);
    disp(filePath)
    arrayLeft = [];
    arrayRight = [];
    arrayAveraged = [];

    % Turn off warnings to suppress column headers modified warning
    warning off
    if isempty(opts)
        opts = detectImportOptions(filePath, "FileType", "text", "VariableNamingRule", "modify");
    end
    trialInfo = readtable(filePath,opts);
    warning on
    trialData.subjectCode = {trialInfo{1,'subject'}};

    % Extraction of RT for left, right and averaged between the two
    for i = 1:height(trialInfo)
        if allTrialSettings.processHC
            blockNumber = trialInfo.block(i);
            trialType = trialInfo.trial_type(i);
            if blockNumber > 2 && strcmp(trialType, "go")
                arrayLeft(end+1,1) = round(trialInfo.left_rt(i)*1000);
                arrayRight(end+1,1) = round(trialInfo.right_rt(i)*1000);
                arrayAveraged(end+1,1) = round((trialInfo.left_rt(i)*1000 + trialInfo.right_rt(i)*1000) / 2);
            end
        else
            blockType = trialInfo.blockcode(i);
            trialType = trialInfo.list_experimentdata_currentvalue(i);
            if strcmp(blockType, "experimentalblocks") && strcmp(trialType, "na")
                arrayLeft(end+1,1) = round(trialInfo.left_key_lifttime(i));
                arrayRight(end+1,1) = round(trialInfo.right_key_lifttime(i));
                arrayAveraged(end+1,1) = round((trialInfo.left_key_lifttime(i) + trialInfo.right_key_lifttime(i)) / 2);
            end
        end
    end

    trialData = processAndSave(arrayLeft, "left", trialData, outputDirectory);
    trialData = processAndSave(arrayRight, "right", trialData, outputDirectory);
    trialData = processAndSave(arrayAveraged, "averaged", trialData, outputDirectory);

    trialOutputTable = struct2table(trialData);
    % Append trial table to output summary table
    outputSummaryTable = [outputSummaryTable; trialOutputTable];
end

if allTrialSettings.writeOutputFiles
    writetable(outputSummaryTable, fullfile(outputDirectory, outputSummaryFilename));
end

% Print lowest trial counts (across left and right) for untrimmed, trimmed 3SD and trimmed 5SD, so can use them as an input later
fprintf("Lowest trial count untrimmed: %d\n", allTrialSettings.lowestTrialCount);
fprintf("Lowest trial count trimmed 3SD: %d\n", allTrialSettings.lowestTrialCountTrimmed3SD);
fprintf("Lowest trial count trimmed 5SD: %d\n", allTrialSettings.lowestTrialCountTrimmed5SD);


% bob = arrayLeft;
% bob(bob==0) = 1000;
% bob(isnan(bob)) = 5000;
% bar = std(bob);
% foo = mean(bob);
% bob(bob>(foo+3*bar)) = (foo+3*bar);
% bob(bob<(foo-3*bar)) = (foo-3*bar);
% (foo+3*bar)
% histogram(bob, 40)
% figure()
% plot(bob)

function trialData = processAndSave(inputArray, name, trialData, outputDirectory)
    global allTrialSettings;    

    % Replace zeroes and NaN with 1000
    trialData.(name+"Zeroes") = sum(inputArray == 0);
    trialData.(name+"NaNs") = sum(isnan(inputArray));
    inputArray(inputArray == 0) = 1000;
    inputArray(isnan(inputArray)) = 1000;

    % Trim to 3 standard deviations
    arrayTrimmed3SD  = trimSD(inputArray, 3);
    trialData.(name+"NumTrimmed3SD") = length(arrayTrimmed3SD);
    
    % Trim to 5 standard deviations
    arrayTrimmed5SD  = trimSD(inputArray, 5);
    trialData.(name+"NumTrimmed5SD") = length(arrayTrimmed5SD);

    % Calculate stats
    trialData.(name+"Mean") = mean(arrayTrimmed3SD);
    trialData.(name+"Median") = median(arrayTrimmed3SD);
    trialData.(name+"Std") = std(arrayTrimmed3SD);
    trialData.(name+"Tau") = calculateTau(arrayTrimmed3SD);
    trialData.(name+"Skewness") = skewness(arrayTrimmed3SD);
    trialData.(name+"CoeffVariation") = trialData.(name+"Std") / trialData.(name+"Mean");
    trialData.(name+"NumTrials") = length(arrayTrimmed3SD);

    % If trim output files is true, trim each array to the lowest trial count
    if allTrialSettings.trimOutputFiles
        inputArray = inputArray(1:allTrialSettings.trialTrimLength);
        arrayTrimmed3SD = arrayTrimmed3SD(1:allTrialSettings.trialTrimLength3SD);
        arrayTrimmed5SD = arrayTrimmed5SD(1:allTrialSettings.trialTrimLength5SD);
    end

    
    
    % Create the directory if it does not exist
    if ~exist(outputDirectory, 'dir')
        mkdir(outputDirectory);
    end

    % Write the files to the output directory
    if allTrialSettings.writeOutputFiles
        writematrix(inputArray, fullfile(outputDirectory, ""+trialData.subjectCode+"_"+name+".txt"))
        writematrix(arrayTrimmed3SD, fullfile(outputDirectory, ""+trialData.subjectCode+"_"+name+"_3SD.txt"))
        writematrix(arrayTrimmed5SD, fullfile(outputDirectory, ""+trialData.subjectCode+"_"+name+"_5SD.txt"))
    end

    % Find lowest trial counts
    allTrialSettings.lowestTrialCount = min([allTrialSettings.lowestTrialCount, length(inputArray)]);
    allTrialSettings.lowestTrialCountTrimmed3SD = min([allTrialSettings.lowestTrialCountTrimmed3SD, length(arrayTrimmed3SD)]);
    allTrialSettings.lowestTrialCountTrimmed5SD = min([allTrialSettings.lowestTrialCountTrimmed5SD, length(arrayTrimmed5SD)]);
end

function inputArray = trimSD(inputArray, numDeviations)
    sd = std(inputArray);
    avg = mean(inputArray);

    inputArray(inputArray < (avg - numDeviations*sd)) = round(avg - numDeviations*sd);
    inputArray(inputArray > (avg + numDeviations*sd)) = round(avg + numDeviations*sd);
end

% Calculates the exponential decay parameter (tau)
% TODO: look at using fancy curve fitting toolbox stuff
function tau = calculateTau(inputArray)
    m = mean(inputArray);
    s = std(inputArray);
    sk = abs(skewness(inputArray));

    % t = s * (y/2) ^ (1/3)
    tau = s * (sk / 2) ^ (1/3);
end

function directoryList = cleanDirList(path)
    directoryList = dir(path);
    % Remove any non-directories
    directoryList = directoryList([directoryList.isdir]);
    % Remove directories starting with '.'
    directoryList = directoryList(~ismember({directoryList.name}, {'.', '..'}));
end

function fileList = cleanFilesList(path)
    fileList = dir(path);
    % Remove any directories
    fileList = fileList(~[fileList.isdir]);
    % Remove files starting with '.'
    fileList = fileList(~ismember({fileList.name}, {'.', '..'}));
end




