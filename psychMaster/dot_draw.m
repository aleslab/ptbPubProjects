%Adapted from Peter Scarfe's Single Dot Demo that generates a
%randomly-positioned red dot on a black background which is available at: 
%http://peterscarfe.com/singleDotDemo.html
% Clear the workspace and the screen
close all;
clear all;
sca

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer. For help see: Screen Screens?
screens = Screen('Screens');

% Draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen. When only one screen is attached to the monitor we will draw to
% this.
screenNumber = max(screens);

% Define black and white (white will be 1 and black 0). This is because
% luminace values are (in general) defined between 0 and 1.
% For help see: help WhiteIndex and help BlackIndex
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
%% A piece of code that asks you where you want to position the dot
%X coordinate needs to be within 0-1920 for lilac room screen and the 
%primary screen in the lab; will be different for the lab CRT screen and 
%other computers with different screen dimensions. 
%Ideally need to  check the screen size to check the range but worry about
%that later.
%to check screen size use:
%[width, height]=Screen('WindowSize', screenNumber) 
%xrange = [0:1920]; %in the lilac room. this is the actual range.
%yrange = [0:1200]; %in the lilac room 

%for the looming + CD experiment (||) you will want the same start and end
%x coordinate for the line -- the code allows you to input only 1 x 
%coordinate and 2 y coordinates. want two lots of these coordinates.

%for the looming only experiment (=) you will want the opposite -- 2 x
%coordinates and 1 y coordinate. want two lots of these coordinates.

% for the possible CD only experiment discussed (|) you will want only one
% line -- will need one x coordinate and 2 y coordinates.

%For now this asks for 1x and 2y.

% xRange = false; %not the same as xrange. this is a boolean, but the values 
% %should still be within 0 and 1920 for this to be true.
% while (~ xRange) %while not xRange
% 
%     xquestion = ['Your X coordinate? ']; %asks for your x coordinate
%     
%    x = input(xquestion); %x coordinate is the input
%     
%     if x <= 1920 && x >= 0 %if the x answer is outside the 
%     %specified range
%         
%     xRange = true;
%     
%     else
%         
%         xRange = false;
%         disp('Please enter a value in the range 0-1920');
%          
%     end
% end 

% y1Range = false; %not the same as yrange. this is a boolean, but the values 
% %should still be within 0 and 1200.
% while (~ y1Range) %the same loop but to get the Y coordinate instead of X
% 
%     y1question = ['Your first Y coordinate? '];
%     
%     answery1 = input(y1question);
%     
%     if answery1 <= 1200 && answery1 >= 0
%         
%     y1Range = true;
%     
%     else
%         
%         y1Range = false;
%         disp('Please enter a value in the range 0-1200');
%          
%     end
% end 
% y2Range = false; %not the same as yrange. this is a boolean, but the values 
% %should still be within 0 and 1200.
% while (~ y2Range) %the same loop but to get the Y coordinate instead of X
% 
%     y2question = ['Your second Y coordinate? '];
%     
%     answery2 = input(y2question);
%     
%     if answery2 <= 1200 && answery2 >= 0
%         
%     y2Range = true;
%     
%     else
%         
%         y2Range = false;
%         disp('Please enter a value in the range 0-1200');
%          
%     end
% end 

%% Generating the window with the line
% Opens a grey window.
%stereoMode = 4; This isn't fully functional yet, I just wanted to put it
%in to keep it in mind

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

%[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey,...
    %[], 32, 2, stereoMode); %the 32 and 2 might not be right, taken from
    %another of Peter Scarfe's demos

% Get the size of the on screen window in pixels.
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window); %taken from PTB-3 MovingLineDemo
vbl=Screen('Flip', window); %taken from PTB-3 MovingLineDemo
% Get the centre coordinate of the window in pixels
[xCenter, yCenter] = RectCenter(windowRect);

% Enable alpha blending for anti-aliasing
%This is not really openGL. It just sets how the alpha channel gets
%interpreted.  This, and a bunch of other things are already set in the
%wrapper scripts.
%Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 


% basically for adapting this code into the wrapper you just need to start
% here. The wrapper script handles everything above.
%-------------------------------------------------------
% function [trialData] = drawDotTrial(screenInfo, conditionInfo)
%
x=100;
xv = 100;

x=mod(x+xv, screenXpixels);

%Remember that if the dot/line is drawn at the edge of the screen some of it 
%might not be visible.

% Draw the dot to the screen. Draws a black line in the grey window from
% start(x,y1) to end(x,y2)

%Screen('DrawLine', window, black, answerx, answery1, answerx, answery2);
Screen('DrawLines', window, [x, x ; 0, screenYpixels]); %this is drawing 
%the start and end x coordinates and then the start and end y coordinates

%HOW DO I GET IT TO GO FROM THIS ^ TO ANOTHER SITUATION JUST LIKE THIS?!
 
%Screen('DrawLines', window, [x+xv, x+xv ; 0, screenYpixels]);
% Flip to the screen. This command basically draws all of our previous
% commands onto the screen. See later demos in the animation section on more
% timing details. And how to demos in this section on how to draw multiple
% rects at once.
% For help see: Screen Flip?
%Screen('Flip', window);
vbl=Screen('Flip', window,vbl+ifi/2); %taken from PTB-3 MovingLineDemo
%vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

% Now we have drawn to the screen we wait for a keyboard button press (any
% key) to terminate the demo. For help see: help KbStrokeWait
KbStrokeWait;

%This would be the end of your trial script. 
%%%%%
%--------------------------
% This also gets handled by the wrapper script. 
% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them if you want.
% For help see: help sca
sca;