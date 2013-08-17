% cbStaircase
%
%   Purpose:
%       main function for running psychophysical staircase to assess
%       color similarities for color blind people
%
%   Uses generic doStaircase function (RFD) to operate the staircase. Uses
%   functions beginning with 'cb' to generate stimuli.
%
%   History
%      19/11/12: HJ: adapted from cocStairCase (RFD)
%
%   Flow:
%     1. cocStaircase: set parameters for experiment
%     2.   => doStaircase(display,stairParams,stimParams,trialGenFuncName [='cocTrial'], ...);
%     3.       => cocTrial(display, stimParams, data); (prepare trial elements)
%     4.       => doTrial(display,trial,runPriority,showTimingFlag,returnHistory)
%     5.            => showStimulus(display, material.stimulus,runPriority, showTimingFlag);
%     6.                 => [show each frame; no external calls]
%     7.                 => drawFixation(display, colindex)     


AssertOpenGL;
if (exist('./ColorTable.txt','file'))
    delete('ColorTable.txt');
end

%% initialize parameters for display, staircase, stimulus, and subject

display          = cbInitDisplay;

stimParams       = cbInitStimParams(display);
display          = cbInitFixParams(display, stimParams);
stairParams      = cbInitStaircaseParams;
dataDir          = cbInitDataDir;
subjectParams    = getSubjectParams(dataDir);

priorityLevel    = 0;
trialGenFuncName = 'cbTrialDetection'; %function called by doStaircase to make stimuli

%% Subject data and log file
if exist(fullfile(dataDir,[subjectParams.name '.log']),'file')
    delete(fullfile(dataDir,[subjectParams.name '.log']));
end
logFID(1) = fopen(fullfile(dataDir,[subjectParams.name '.log']), 'a+');
%fprintf(logFID(1), '%s\n', datestr(now));
%fprintf(logFID(1), '%s\n', subjectParams.comment);

fprintf(logFID(1), '\n');
logFID(2) = 1;
hideCursor = false;

%% Custumize the instruction Page
instructions{1} = 'Color Test\n';
instructions{2} = 'This test is composed of several trials. In each trial, you will be presented four colors, two at each time\n';
instructions{3} = 'Your task is to tell colors in which group are the same. Press A for first group and L for second\n';
instructions{4} = 'If your answer is correct, you will hear a cheering sound. If your answer is wrong, you will hear beep\n';
instructions{5} = 'Press any key to continue';
stairParams.customInstructions = ['pressKey2Begin(display,0,false,''' cell2mat(instructions) ''')'];

%% do the staircase
tic;
display = openScreen(display,hideCursor);
newDataSum = doStaircase(display, stairParams, stimParams, trialGenFuncName, ...
    priorityLevel, logFID);
display = closeScreen(display);
timeUsed = toc;

disp(['Test Time: ' num2str(timeUsed)]);

fclose(logFID(1));

%% Visualize Data
if exist('ColorTable.txt','file')
    colorHistory = csvread('ColorTable.txt');
    cbPlot(newDataSum,stairParams,...
        fullfile(dataDir,[subjectParams.name '.log']),...
        colorHistory,stimParams.Type);
end





