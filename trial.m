function [result,reference_velocity,comparison_velocity]=trial(delta_speed)
% [result,reference_velocity,comparison_velocity]=trial(delta_speed)
%
% runs a single trial of a simple 2AFC speed discrimination experiment with
% a difference of delta_speed between the two intervals.
%
% returns the result (correct=1,incorrect=0), as well as the reference and
% comparison velocities used in the trial.

% Author: Melchi M. Michel  (07/2015)
%% Compute & Load Global Parameters
global DP; % display parameters
global SP; % block & stimulus parameters

% Set initial values of 'key' and 'fixation_dist' such that the while loop
% below runs at least once.
% I realize this is a bit confusing, but it's necessary because MATLAB does
% not have a do-while loop construct.
key=0;
fixation_dist = SP.FIXATION_TOL+1;
%before the space bar is pressed, check that fixation is within tolerance
%if the key that you pressed is not the spacebar OR your fixation is out of
%the tolerance range, keep waiting
while(~strcmp(key,'space')||(fixation_dist>SP.FIXATION_TOL))
    if(DP.USING_GAZE)
        [x,y,time] = getEyelinkSample(1);
        fixation_dist = norm([x,y]);
        % the code below draws the current gaze position using a small
        % dot.
        Screen('FillRect',DP.WINPTR,SP.MEAN_LUM);
        drawEyeMarker(x,y);
        % draw fixation point
        Screen('FillOval',DP.WINPTR,SP.MARKER_LUM,DP.pixRect([0,0,0.25,0.25]));
        Screen('Flip',DP.WINPTR);
    else
        %if eyetracker is on, check fixation distance, otherwise it is zero 
        fixation_dist = 0;
    end
    [key,keytime] = getResponse();   
end

%% Stimulus setup
% randomly decide whether the reference or the comparison stimulus will be
% shown first and whether the comparison speed will be slower or faster
% than the reference. Set up the stimuli accordingly

isRefFirst = round(rand());
delta_direction = round(rand())*2-1;
if(isRefFirst)
    speed1 = SP.REF_SPEED;
    speed2 = SP.REF_SPEED+delta_speed*delta_direction;
else
    speed1 = SP.REF_SPEED+delta_speed*delta_direction;
    speed2 = SP.REF_SPEED;
end

firstIsFaster = speed1>speed2;

%%
% In this trial, we will wait a brief moment then slowly drift a circular
% fixation target away from the fixation location at a rate determined by
% 'speed' above and in a randomly chosen direction determined by 'direction'
% below.
trial_start_time = GetSecs();

%% Initial Display
Screen('FillRect',DP.WINPTR,SP.MEAN_LUM);
Screen('FillOval',DP.WINPTR,SP.MARKER_LUM,DP.pixRect([0,0,0.25,0.25]));
Screen('Flip', DP.WINPTR);

% wait until SP.SOA_TIME seconds has passed
WaitSecs(SP.SOA_TIME);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Interval 1: Show First Drifting Stimulus
% compute the 'discrete speed' or the amount by which we have to shift
% the target on each frame
frame_speed = speed1/DP.FRAME_RATE;
% randomly choose a direction: -1 (L) or 1 (R)
direction1=round(rand())*2-1; 
% randomly choose a distance between 8 and 10 degrees so that subjects
% can't simply use timing to decide which is faster.
distance = unifrnd(8,10);

current_xpos = 0;
% shift and display the stimulus appropriately across each 10ms frame
% until it has traveled the appropriate distance
while(abs(current_xpos)<=distance)
    % shift the horizontal stimulus location (x position)
    current_xpos = current_xpos+direction1*frame_speed;
    
    % clear the screen
    Screen('FillRect',DP.WINPTR,SP.MEAN_LUM);
    % draw the stimulus
    Screen('FillOval',DP.WINPTR,SP.MARKER_LUM,DP.pixRect([current_xpos,0,0.25,0.25]));
    % swap buffers
    Screen('Flip', DP.WINPTR);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Interstimulus Interval
% clear screen
Screen('FillRect',DP.WINPTR,SP.MEAN_LUM);
% draw fixation point
Screen('FillOval',DP.WINPTR,SP.MARKER_LUM,DP.pixRect([0,0,0.25,0.25]));
% swap buffers
Screen('Flip', DP.WINPTR);

% wait until SP.ISI_TIME seconds has passed
WaitSecs(SP.ISI_TIME);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Interval 2: Show Second Drifting Stimulus
% compute the 'discrete speed' or the amount by which we have to shift
% the target on each frame
frame_speed = speed2/DP.FRAME_RATE;
% randomly choose a direction: -1 (L) or 1 (R)
direction2=round(rand())*2-1; 
% randomly choose a distance between 8 and 10 degrees so that subjects
% can't simply use timing to decide which is faster.
distance = unifrnd(8,10);

current_xpos = 0;
% shift and display the stimulus appropriately across each 10ms frame
% until it has traveled the appropriate distance
while(abs(current_xpos)<=distance)
    % shift the horizontal stimulus location (x position)
    current_xpos = current_xpos+direction2*frame_speed;
    
    % clear the screen
    Screen('FillRect',DP.WINPTR,SP.MEAN_LUM);
    % draw the stimulus
    Screen('FillOval',DP.WINPTR,SP.MARKER_LUM,DP.pixRect([current_xpos,0,0.25,0.25]));
    % swap buffers
    Screen('Flip', DP.WINPTR);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Deterimine Accuracy and Do Cleanup
% clear screen
Screen('FillRect',DP.WINPTR,SP.MEAN_LUM);
% draw fixation point
Screen('FillOval',DP.WINPTR,SP.MARKER_LUM,DP.pixRect([0,0,0.25,0.25]));
% swap buffers
Screen('Flip', DP.WINPTR);

% waiting for a subject's response to "which was faster". ('f' for "first"
% and 'j' for "second")
while(~(strcmp(key,'f'))& ~(strcmp(key,'j')))
    [key,keytime] = getResponse();
end

%show to subject feedback
if(strcmp(key,'f')&firstIsFaster)|(strcmp(key,'j')&~firstIsFaster);
    result=1;
    %SP.CORRECT_SND();
else
    result=0;
    %SP.INCORRECT_SND();
end

if(isRefFirst)
    reference_velocity = speed1*direction1;
    comparison_velocity = speed2*direction2;
else
    reference_velocity = speed2*direction2;
    comparison_velocity = speed1*direction1;
end

end


%draws a marker to show eye position
function drawEyeMarker(x,y)
    global SP;
    global DP;
    Screen('FillOval', DP.WINPTR, SP.MARKER_LUM, DP.pixRect([x,y,0.2,0.2]));
end

