 %function main()
clear all; close all;

%% Compute & Load Global Parameters
global DP; % display parameters
global SP; % block & stimulus parameters

% Initialize display parameter (DP) and stimulus parameter (SP) structures
[DP,SP] = exptParams();
%% Set up unified key names for (keyboard keypresses)
KbName('UnifyKeyNames');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup Screen Preferences and Display Window
% The following 'Preference' commands remove the blue screen flash and 
% minimize extraneous warnings.
Screen('Preference', 'VisualDebugLevel', 3);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'SkipSyncTests', 1);

% Create the main display window
[DP.WINPTR, DP.RECT] =Screen('OpenWindow', DP.DISPLAY_NR, 0);

Screen('BlendFunction', DP.WINPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% 
% clear display
Screen('FillRect',DP.WINPTR,SP.MEAN_LUM);
% draw fixation point
Screen('FillOval',DP.WINPTR,SP.MARKER_LUM,DP.pixRect([0,0,0.25,0.25]));
% swap buffers
Screen('Flip', DP.WINPTR);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Display something and wait for keypress to exit

% 1. Display something (e.g., a blank gray screen)
% clear display
Screen('FillRect',DP.WINPTR,SP.MEAN_LUM);
% draw fixation point
Screen('FillOval',DP.WINPTR,SP.MARKER_LUM,DP.pixRect([0,0,0.25,0.25]));
% swap buffers
Screen('Flip', DP.WINPTR);

% wait for the user to press a key (e.g., spacebar)
key=0;
while(~strcmp(key,'space'))
    [key,keytime] = getResponse();   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% shut down Psychtoolbox
Screen('CloseAll');


