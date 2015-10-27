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
%% Setup Eyelink Stuff
if(DP.USING_GAZE)
    % Initialize 'el' eyelink struct with proper defaults for output to
    % window 'DP.WINPTR':
    el=EyelinkInitDefaults(DP.WINPTR);

    % Initialize Eyelink connection (real or dummy). The flag '1' requests
    % use of callback function and eye camera image display:
    if ~EyelinkInit([], 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;
        return;
    end

    % Send any additional setup commands to the tracker
    Eyelink('Command','calibration_type = HV9'); % 9-point calibration
    Eyelink('Command','recording_parse_type = GAZE');
    Eyelink('Command','link_sample_data = LEFT,RIGHT,GAZE,AREA,STATUS');
    Eyelink('Command','link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK');
    Eyelink('Command','sample_rate = 1000'); % 1000 Hz
    Eyelink('Command','heuristic_filter = 1'); % 
    Eyelink('Command','screen_pixel_coords = 0 0 1279 1023'); % screen res 1280 x 1024


    % Perform tracker setup: The flag 1 requests interactive setup with
    % video display:
    result = Eyelink('StartSetup',1);
    Eyelink('StartRecording');
    % this is a local function that grabs the latest gaze position sample
    [x,y,time] = getEyelinkSample(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run the actual experiment
% start block
trial_count=1;

while trial_count <= SP.NR_TRIALS
    speed = 10.0; %deg/sec
    distance = 10.0; %deg
    [valid,targ_position,gaze_record]=trial(speed,distance);
    
    if (valid)
        gaze_records{trial_count}=gaze_record;
        targ_positions{trial_count}=targ_position;
        trial_count=trial_count+1;  
    end
end



trialData.gaze_records = gaze_records;
trialData.targ_positions = targ_positions;

% save the block data in a local file
save('shutter_eyetracking_data.mat', 'trialData');

% shut down Psychtoolbox and the Eyelink connection
Screen('CloseAll');
if(DP.USING_GAZE)
    eyelink_hrt('cleanup');
    Eyelink('Shutdown');
end

