function [valid, marker_loc, gaze_record]=trial(speed,distance)
%% Compute & Load Global Parameters
global DP; % display parameters
global SP; % block & stimulus parameters


key=0;
%if eyetracker is on, check fixation distance, otherwise it is zero
if (DP.USING_GAZE)
    fixation_dist = norm(eyetribe_hrt('position'));
    %x = eyetribe_hrt('position');
    %drawEyeMarker(x(1),x(2));
else
    fixation_dist = 0;
end

%before the space bar is pressed, check that fixation is within tolerance
%if the key that you pressed is not the spacebar OR your fixation is out of
%the tolerance range, keep waiting
while(~strcmp(key,'space')||(fixation_dist>SP.FIXATION_TOL))
    if(DP.USING_GAZE)
        [x,y,time] = getEyelinkSample(1);
        
        Screen('FillRect',DP.WINPTR,SP.MEAN_LUM);
        drawEyeMarker(x,y);
        % draw fixation point
        Screen('FillOval',DP.WINPTR,SP.MARKER_LUM,DP.pixRect([0,0,0.25,0.25]));
        Screen('Flip',DP.WINPTR);
    end

    [key,keytime] = getResponse();
    if(key==-1); return; end;
%if eyetracker is on, check fixation distance, otherwise it is zero    
    if (DP.USING_GAZE)
        %fixation_dist = norm(eyetribe_hrt('position'));
        fixation_dist = norm([x,y]);
        
    else
        fixation_dist = 0;
    end
end

%%
% In this trial, we will wait a brief moment then slowly drift a circular
% fixation target away from the fixation location at a rate determined by
% 'speed' above and in a randomly chosen direction determined by 'direction'
% below.
% During this time, we will track the gaze position. This gaze position 
% will be returned and stored for analysis.

direction=round(rand())*2-1;
frame_speed = speed/DP.FRAME_RATE_S;
current_xpos = 0;
marker_loc = [];

if(DP.USING_GAZE)
    eyelink_hrt('start');
end
trial_start_time = GetSecs();

%% Initial Display
Screen('FillRect',DP.WINPTR,SP.MEAN_LUM);
Screen('FillOval',DP.WINPTR,SP.MARKER_LUM,DP.pixRect([0,0,0.25,0.25]));
Screen('Flip', DP.WINPTR);
       
WaitSecs(SP.SOA_TIME);

%% Drifting Stimulus
while(abs(current_xpos)<=distance)
    current_xpos = current_xpos+direction*frame_speed;
    
    Screen('FillRect',DP.WINPTR,SP.MEAN_LUM);
    Screen('FillOval',DP.WINPTR,SP.MARKER_LUM,DP.pixRect([current_xpos,0,0.25,0.25]));
    Screen('Flip', DP.WINPTR);
    
    marker_loc = [marker_loc;[current_xpos,0,GetSecs()-trial_start_time]];
end

% clear screen
Screen('FillRect',DP.WINPTR,SP.MEAN_LUM);
% draw fixation point
Screen('FillOval',DP.WINPTR,SP.MARKER_LUM,DP.pixRect([0,0,0.25,0.25]));
% swap buffers
Screen('Flip', DP.WINPTR);


if(DP.USING_GAZE)
    gaze_record = eyelink_hrt('stop');
    gaze_record(:,1:2) = DP.scrP2D(gaze_record(:,1),gaze_record(:,2));
    fixation_broken = 0;
else
    gaze_record=[];
    fixation_broken = 0;
end


% decide what to do if fixation was broken
valid = 1;
end


%draws a marker to show eye position
function drawEyeMarker(x,y)
    global SP;
    global DP;
    Screen('FillOval', DP.WINPTR, SP.MARKER_LUM, DP.pixRect([x,y,0.2,0.2]));
end

function smoothEye = GaussBlur(gaze_record)
x=gaze_record(:,1);
y=gaze_record(:,2);
t=gaze_record(:,3);
    scale = 0.032; %one sample every 32 miliseconds
    gaze_size = length(t);
    support = [0.001:0.001:(5*scale)];
    kernel = normpdf(support, mean(support), scale);
    smooth_x = conv(x, kernel/sum(kernel), 'same');
    smooth_y = conv(y, kernel/sum(kernel), 'same');
    smoothEye = [smooth_x, smooth_y];
end
