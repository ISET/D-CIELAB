function [response, trialHistory] = doTrial(display, trial, runPriority,...                                              showTimingFlag,returnHistory)%% function [response,trialHistory] = doTrial(display, trial, ... %                          [runPriority], [showTimingFlag], [returnHistory])%%	This still needs alot more commenting, but I will tell you this: if you%	want to return keyHit, things around here have changed a bit.  You set%	returnHistory=1 to return trialHistory.%   keyHit will now be a field of said struct.%%   98.12.15    RFD: added material.sampRate option for soundEvent%   2008.05.14  JW:  added 'showTimingFlag' to function calls%   2009.07.01  RFB: added showText case for text presentation%   2009.07.02  AMR: made responses from ISI trials a separate field so it%                    doesn't overwrite responses from previous events% NEEDS MORE COMMENTING HERE% what is 'answer'? it doesn't seem to be usedanswer = NaN; %#ok<NASGU>trialHistory.keyHit = [];if ~exist('runPriority', 'var')    runPriority = 0;endif ~exist('showTimingFlag', 'var')    showTimingFlag = 0;endif ~exist('returnHistory', 'var')    returnHistory = 0;endfor eventNum = 1 : length(trial)    material = trial{eventNum,2};        switch trial{eventNum,1}                case 'stimulusEvent',            % We'll catch a response for any stimulus event- the last            % response will be kept.            response = showStimulus(display, material.stimulus, runPriority, showTimingFlag);                    case 'randomizeStimulusEvent',	% An example randomizeFunction: randomizePeriodicStimulus            if ~isfield(material,'stimulus') || ...               ~isfield(material,'params') || ...               ~isfield(material,'randomizeTable') || ...               ~isfield(material,'randomizeFunction')                error('Fields for randomizeStimulusEvent is missing');            end            functionCall = ['[newStimulus,valuesUsed] = ' ...                material.randomizeFunction ...                '(display, material.stimulus, material.params,' ...                'material.randomizeTable);'];            eval(functionCall);            [response, stimTime] = showStimulus(display,newStimulus,...                                              runPriority, showTimingFlag);            if returnHistory                for ii = 1:size(material.randomizeTable,1)                    disp('Setting a field.');                    trialHistory.(material.randomizeTable{ii,1}) = ...                        valuesUsed{ii};                end            end                    case 'ISIEvent'            if isfield(material,'stimulus')                [response.ISI, stimTime] = showStimulus(display, ...                    material.stimulus,runPriority, showTimingFlag);                if isfield(material,'duration')                    response.ISI = waitTill(material.duration);                end            elseif isfield(material,'duration')                if(isfield(display,'windowPtr'))                    Screen('FillRect', display.windowPtr, ...                        display.backgroundColor);                    drawFixation(display);                    Screen('Flip', display.windowPtr);                end                response.ISI = waitTill(material.duration);            else                error('ISI needs at least a duration or stimulus field!');            end                    case 'ExternalDisp'                        Ttmp = GetSecs;             if isfield(material,'stimulus')                 system(material.stimulus);%                 disp(material.stimulus)                if isfield(material,'duration')                    response = waitTill(material.duration, Ttmp);                end                            elseif isfield(material,'duration')                response = waitTill(material.duration, Ttmp);                            elseif isfield(material,'waitResponse')                eval(material.waitResponse)                            else                error('Device needs duration, response or stimulus field');            end                    case 'ExternalDisp_w_Distractor'                        Ttmp = GetSecs;             if isfield(material,'stimulus')                 system(material.stimulus);                 showStimulus(display, material.distractor, ...                     runPriority, showTimingFlag);                if isfield(material,'duration')                    response = waitTill(material.duration, Ttmp);                end                            elseif isfield(material,'duration')                response = waitTill(material.duration, Ttmp);                if(isfield(display,'windowPtr'))                    Screen('FillRect', display.windowPtr, ...                        display.backgroundColor);                    drawFixation(display);                    Screen('Flip', display.windowPtr);                end            elseif isfield(material,'waitResponse')                eval(material.waitResponse)                            else                error('Device needs duration, response or stimulus field');            end                                case 'soundEvent',            if isfield(material, 'sampRate')                sound(material.sound, material.sampRate);            else                sound(material.sound);            end                    case 'responseEvent',            if isfield(material,'stimulus')  % There's a stimulus to show during the response period                [response, stimTime] = showStimulus(display, ...                    material.stimulus,runPriority, showTimingFlag);            end            response = waitTill(material.duration);            response = getKeyLabel(response);            trialHistory.keyHit = response.keyLabel;            if isempty(trialHistory.keyHit)  % No key was hit during response interval                responseIndex = NaN;            else  				% A key was hit                responseIndex = findstr(material.responseSet, ...                    trialHistory.keyHit);                if isempty(responseIndex)	% Invalid response (was not in responseSet)                    answer = NaN;                elseif isfield(material,'answerType')   % answerType was specified                    switch material.answerType                        case 'binary',                            answer = (responseIndex==1);                        case '1toN',                            answer = responseIndex;                        case 'none',                            answer = [];                        otherwise,                            error('Not a valid answerType (just leave it out for binary).');                    end                else			% assume answerType is the default (i.e., binary)                    answer = (responseIndex==1); % Default answerType is binary                end            end                    case 'feedbackEvent',	% Remember to check whether various feedback strings even exist            if ~exist('responseIndex','var')                feedbackText  = material.noResponseText;                feedbackColor = material.noResponseColor;            elseif isnan(responseIndex)                feedbackText  = material.noResponseText;                feedbackColor = material.noResponseColor;            elseif isempty(responseIndex)                feedbackText  = material.invalidResponseText;                feedbackColor = material.invalidResponseColor;            else                feedbackText  = material.validResponsesText{responseIndex};                feedbackColor = material.validResponsesColor{responseIndex};            end                        vLoc=material.feedbackVerticalLocation;            timeRightNow = getSecs;            dispStringInCenterFast(display,feedbackText,vLoc,display.reservedColor(feedbackColor).fbVal,32);            waitTill(material.duration, timeRightNow);            dispStringInCenterFast(display,feedbackText,vLoc,display.reservedColor(backgroundColor).fbVal,32);                    case 'soundFeedbackEvent',	% Remember to check whether various feedback strings even exist            if ~exist('responseIndex','var')                feedbackSound = material.noResponseSound;            elseif isnan(responseIndex)                feedbackSound = material.noResponseSound;            elseif isempty(responseIndex)                feedbackSound = material.invalidResponseSound;            else                feedbackSound = material.validResponseSound{responseIndex};            end            sound(feedbackSound);                    case 'textEvent', % Present customized text anywhere on the screen            % We'll catch a response for any stimulus event- the last            % response will be kept.            [response, stimTime] = showText(display, material.stimulus, runPriority, showTimingFlag);                    otherwise,            error([trial{eventNum,1} ' is not a valid event type.']);    endendresponse = getKeyLabel(response);return;