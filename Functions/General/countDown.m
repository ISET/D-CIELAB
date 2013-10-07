function [time0]=countDown(display,cdStartSecs,cdStartScan, triggerType)% function [time0]=countDown(display,cdStartSecs,cdStartScan, [triggerType])%% time0 is the time (GetSecs) at which the scanner started.% cdStartSecs is the (integer) number of seconds for the entire countdown sequence% cdStartScan is the (real) number of seconds remaining in the countdown when scanner%   is to be started%% Purpose:  Counts down from secs to 1,%           displaying the numbers on the%           screen above the fixation point.%%% Original author unknown% 6/2/99 David Ress & Ben Backus: replaced timing loop with a time-based%   loop instead of integer countdown, to allow use of real-valued scanner%   starting times.% 11/01/02 JLiu added try-catch for StartScan.% 06/2005 SOD ported to OSX, added time0if ~exist('cdStartScan', 'var')    cdStartScan = -1;endif ~exist('triggerType', 'var')    triggerType = 'no trigger (manual)';end%loc = display.rect([3,4])/2;% Loop to display countdown and start scannercdStartSecs = round(cdStartSecs);    % Force to integerendTime = cdStartSecs + GetSecs;   % Time at which to end the countdownscanStarted = 0;currentDisplayNumber = cdStartSecs;timeRemaining = cdStartSecs;while timeRemaining > 0        % Check whether to start scanner    if ~scanStarted        if timeRemaining <= cdStartScan            dispStringInCenter(display,'Start Scan',0.6,[],'white');            switch lower(triggerType)                case 'scanner triggers computer'                    % This does not seem to make sense. If the scanner is                    % triggering the computer, then the computer should not                    % send a pulse to start the scanner. Hence we should                    % not have a call to StartScan.                    [s,time0]   = StartScan;                    scanStarted = 1;                case 'computer triggers scanner'                                        [s,time0]   = StartScan;                    scanStarted = 1;                case 'no trigger (manual)'                    time0 = GetSecs;                    scanStarted = 1;                                end        end;    end;        % Update countdown number, if it's time to do so    if ceil(timeRemaining) <= currentDisplayNumber,        dispStringInCenter(display,num2str(currentDisplayNumber),0.61,[],'white');        currentDisplayNumber = currentDisplayNumber-1;    end;    timeRemaining =  endTime - GetSecs;end;% if scanner triggers comptuter then returnswitch lower(triggerType)    case {'no trigger (manual)' 'none' 'scanner triggers computer'}        time0 = GetSecs;        return    case  'computer triggers scanner'               % allow for StartScan == 0 (start at end of countdown)        if ~scanStarted && cdStartScan==0,            [s,time0] = StartScan;        end;        endreturn