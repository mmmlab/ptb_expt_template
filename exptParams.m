function [dp,sp] = exptParams()
% [dp,sp] = exptParams()
%
% returns display parameter (dp) and stimulus parameter (sp) structures
% for a simple experiment

% Author: Melchi M. Michel  (07/2015)
global display_params
global stimulus_params

%% Set all display parameters here
displays = Screen('Screens'); % get a list of all the displays
display_params.USING_GAZE    = 0; % boolean flag indicating whether we're using the eyetracker
display_params.DISPLAY_NR    = displays(end); % automatically choose appropriate display
display_params.DISPLAY_DIAG  = 0.49;% lab CRT 0.546; % for 21.5 in monitor
display_params.SUBJ_DIST     = 0.7; % lab display (meters)
display_params.FRAME_RATE    = 100; % for lab display (make sure to test this)
display_params.FRAME_RATE_S  = display_params.FRAME_RATE/2; % effective frame rate for stereo displays
computeDisplayParams();
display_params.pixRect       = @degRect2Pix; %converts dva rectangle to screen pixels
display_params.scrP2D        = @screenPt2Deg; %converts dva location to screen pixel units
display_params.scrD2P        = @degPt2Screen; %converts screen pixel units to dva location

%% Set all block & stimulus parameters here
stimulus_params.REF_SPEED      = 20;  % reference stimulus speed (in dva/sec)
stimulus_params.DELTA_SPEEDS   = [1.0,2.5,5.0,10]; % differences for comparison speeds
stimulus_params.NR_CONDS       = length(stimulus_params.DELTA_SPEEDS);
stimulus_params.TRIALS_PER_COND= 2;
stimulus_params.NR_TRIALS      = stimulus_params.NR_CONDS*stimulus_params.TRIALS_PER_COND; % number of test trials to run
stimulus_params.FIXATION_TOL   = 1.0;% tolerance (deg) for monitoring fixation
stimulus_params.TARG_LUM       = 200;
stimulus_params.MARKER_LUM     = 64;
stimulus_params.MARKER_SIZE    = 0.25; % degrees
stimulus_params.RECT_LUM       = [100 10 50];
stimulus_params.MEAN_LUM       = 128;
stimulus_params.STIM_TIME      = 0.5; % stimulus duration (seconds)
stimulus_params.ISI_TIME       = 0.5; % duration of interstimulus interval (secs)
stimulus_params.SOA_TIME       = 0.5; % stimulus onset asynchrony
%stimulus_params.CORRECT_SND    = audioread('shortding.wav')';
%stimulus_params.INCORRECT_SND  = audioread('donk.wav')';
%stimulus_params.RESP_SND       = audioread('shortbeep.wav')';
%stimulus_params.SND_FS         = 22050; % sound sampling rate (Hz)
%stimulus_params.SND_HANDLE     = 0; % this must be set in exptMain() function

dp = display_params;
sp = stimulus_params;
end

function computeDisplayParams()
    % Retrieves the display resolution using the video API and computes the
    % pixel-to-degree conversion constants
    global display_params;
    scrn_res = Screen('Resolution',display_params.DISPLAY_NR);
    display_params.W_WIDTH = scrn_res.width;
    display_params.W_HEIGHT = scrn_res.height;
    %% below, I'm assuming that the the screen pixels are square (in
    %% aggregate)
    screen_diag_pix = sqrt(display_params.W_WIDTH^2+display_params.W_HEIGHT^2);
    screen_diag_deg = 2*atand(0.5*display_params.DISPLAY_DIAG/display_params.SUBJ_DIST);
    display_params.DEG2PIX = screen_diag_pix/screen_diag_deg; 
    display_params.PIX2DEG = 1/display_params.DEG2PIX;
end

function pix_rect = degRect2Pix(deg_rect)
    % converts a [x_center,y_center,width,height] deg VA rectangle to the
    % [u,l,b,r] screen pixel format required by various Screen() functions 
    global display_params;
    D2P = display_params.DEG2PIX;
    WW = display_params.W_WIDTH;
    WH = display_params.W_HEIGHT;
    
    pix_rect(1) = deg_rect(1)*D2P+0.5*(WW-deg_rect(3)*D2P);
    pix_rect(3) = pix_rect(1)+deg_rect(3)*D2P;
    pix_rect(2) = 0.5*(WH-deg_rect(4)*D2P)-deg_rect(2)*D2P;
    pix_rect(4) = pix_rect(2)+deg_rect(4)*D2P;
    pix_rect = round(pix_rect);
end

function pxpt = degPt2Screen(xdeg,ydeg)
    % converts a point specified in degrees of visual angle
    % (from screen center) to screen pixels (from upper left of screen)
    global display_params;
    P2D = display_params.PIX2DEG;
    WW = display_params.W_WIDTH;
    WH = display_params.W_HEIGHT;
    x = 0.5*WW+xdeg/P2D;
    y = 0.5*WH-ydeg/P2D;
    pxpt = [x,y];
end

function pt = screenPt2Deg(x,y)
    % computes the inverse function of degPt2Screen above
    global display_params;
    P2D = display_params.PIX2DEG;
    WW = display_params.W_WIDTH;
    WH = display_params.W_HEIGHT;
    xdeg = (x-0.5*WW)*P2D;
    ydeg = (0.5*WH-y)*P2D;
    pt = [xdeg,ydeg]; 
end

