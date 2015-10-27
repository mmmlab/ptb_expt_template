function [keyname,keytime] = getResponse(isBlocking,startSecs)
% function [keyname,keytime] = getResponse(isBlocking,startSecs)
% 
% returns pressed key and time offset of keypress (keytime only valid when
% optional arguments are provided)

% Author: Melchi M. Michel  (03/2013)

global DP;
global SP;

if nargin<1
    isBlocking = false;
end
if nargin<2
    startSecs = 0;
end

escapeKey = KbName('ESCAPE');
if(isBlocking)
    startSecs = GetSecs;
    timeSecs = KbWait;
end
[ keyIsDown, t, keyCode ] = KbCheck;

% shuts down Eyelink connection and Psychtoolbox resources if Esc is pressed
if keyCode(escapeKey)
    Screen('CloseAll');
    if(DP.USING_GAZE)
        Eyelink('Shutdown');
        setDACGamma(0);
    end
    keyname = -1; keytime = 0;
    return;
end

% compute elapsed time since input 'startSecs'
% note that keytime is meaningless if no value was input for 'startSecs'
keytime = GetSecs - startSecs;

% If 'isBlocking' is true (1) the code will hang here until a key is
% pressed. Otherwise, this function will return immediately.
if(isBlocking)
    while KbCheck; end
end
keyname = KbName(keyCode);
if(iscell(keyname))
    % returns an invalid response if two keys are pressed simultaneously
    keyname = -1;
end
return