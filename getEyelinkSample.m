function [x,y,time] = getEyelinkSample(eye_used)
% [x,y,time] = getEyelinkSample(eye_used)
%
% returns the latest sample for 'eye used' (0=left eye, 1=right eye)

% Author: Melchi M. Michel  (03/2013)

global DP;
global SP;


Eyelink( 'NewFloatSampleAvailable') > 0
% get the sample in the form of an event structure
evt = Eyelink( 'NewestFloatSample');
% eye_used should be 0 (for left eye) or 1 (for right eye)
                
xPix = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
yPix = evt.gy(eye_used+1);
pt = DP.scrP2D(xPix,yPix);
x = pt(1);
y = pt(2);
time = evt.time;
