function [trialData] = MoveLineTrial(expInfo, conditionInfo)
%Trial code for AL's moving line experiments
%% Setting up
[screenXpixels, screenYpixels] = Screen('WindowSize', expInfo.curWindow);
%get the number of pixels in the window
%this is already in the code somewhere, I should find where and make it
%consistent.

trialData.validTrial = false;
trialData.abortNow   = false;

vbl=Screen('Flip', expInfo.curWindow); %flipping to the screen

%eye information
IOD = 6; %Interocular distance.
%Eventually need to ask this at the beginning of the experiment
cycDist = 0.5 * IOD; %the distance between each eye and the cyclopean point
fixation = [0, 0, expInfo.viewingDistance]; %the fixation point in our coordinate system
eyeL = [-cycDist, 0, 0]; %the left eye's position in our coordinate system
eyeR = [cycDist, 0, 0]; %the right eye's position in our coordinate system

lw = 1; %linewidth in pixels

screenXCentre = screenXpixels/2; %again this is already in the code and I
%should change it to be consistent. %middle of X
screenYCentre = screenYpixels/2; %middle of Y

fixCrossDimPix = 20; %the size of the arms of our fixation cross

fixXCoords = [-fixCrossDimPix fixCrossDimPix 0 0]; %fixation cross x coordinates
fixYCoords = [0 0 -fixCrossDimPix fixCrossDimPix]; %fixation cross y coordinates
FixCoords = [fixXCoords; fixYCoords]; %combined fixation cross coordinates
fixWidthPix = 1; %the line width of the fixation cross

%box surrounding fixation cross when you can make a response
leftPointX = screenXCentre - 30;
rightPointX = screenXCentre + 30;
PointY1 = screenYCentre + 30;
PointY2 = screenYCentre - 30;

boxXcoords = [leftPointX leftPointX rightPointX rightPointX leftPointX rightPointX leftPointX rightPointX];
boxYcoords = [PointY1 PointY2 PointY1 PointY2 PointY1 PointY1 PointY2 PointY2];
boxCoords = [boxXcoords; boxYcoords];

nFrames = round(conditionInfo.stimDuration / expInfo.ifi); %number of
%frames displayed during JMA: added round because  it needs to be an
%integer. the duration (in seconds) that is specified
nFramesPreStim = round(conditionInfo.preStimDuration/expInfo.ifi);
velCmPerFrame  = conditionInfo.velocityCmPerSec*expInfo.ifi;

%% Choosing and running the stimulus
if strcmp(conditionInfo.stimType, 'cd'); %%strcmp seems to work better than == for this.
    %Checking if the stimulus type is CD only.
    % Changing disparity stimulus -- single vertical line for each eye
    objectStart = [conditionInfo.startPos, 0, expInfo.viewingDistance];
    %the single line "object" starting position
    
    objectCurrentPosition = objectStart;
    [screenL, screenR] = calculateScreenLocation(fixation, objectCurrentPosition, eyeL, eyeR);
    %trig for the object's current position on the screen
    
    pixelDistanceL = expInfo.pixPerCm * screenL(1); %the non-adjusted position
    %of the line on the screen in pixels for the left eye
    LinePosL = round(screenXCentre + pixelDistanceL); %the adjusted position
    %of the line on the screen in pixels -- relative to the centre of X for
    %the left eye
    
    %same as for the left eye above but for the right eye
    pixelDistanceR = expInfo.pixPerCm * screenR(1);
    LinePosR = round(screenXCentre + pixelDistanceR);
    
    for iFrame = 1:nFramesPreStim %during the pre stimulus duration
         Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0); %choosing the left eye
        Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0) %drawing the fixation cross in the left eye
        Screen('DrawLines', expInfo.curWindow, [LinePosL, LinePosL ; 0, screenYpixels], lw); %drawing the line in the left eye
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1); %choosing the right eye
        Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0)%drawing the fixation cross in the right eye
        Screen('DrawLines', expInfo.curWindow, [LinePosR, LinePosR ; 0, screenYpixels], lw);
        
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
    end
    
    for iFrame = 1:nFrames, %for each frame until you reach the maximum number of frames
        %For the left eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0); %choosing the left eye
        Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0) %drawing the fixation cross in the left eye
        Screen('DrawLines', expInfo.curWindow, [LinePosL, LinePosL ; 0, screenYpixels], lw); %drawing the line in the left eye
        %For the right eye
        Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1); %choosing the right eye
        Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0)%drawing the fixation cross in the right eye
        Screen('DrawLines', expInfo.curWindow, [LinePosR, LinePosR ; 0, screenYpixels], lw); %drawing the line in the right eye
        
        vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
        
        objectCurrentPosition(3) = objectCurrentPosition(3) + velCmPerFrame; %changing the object's current position in space (cm) with the velocity (cm)
        [screenL, screenR] = calculateScreenLocation(fixation, objectCurrentPosition, eyeL, eyeR); %calculating the new position of the line on the screen for both eyes
        %For the left eye
        pixelDistanceL = expInfo.pixPerCm * screenL(1); %the non-adjusted position
        %of the line on the screen in pixels for the left eye
        LinePosL = round(screenXCentre + pixelDistanceL); %the adjusted position
        %of the line on the screen in pixels -- relative to the centre of X for
        %the left eye
        %For the right eye
        %same as for the left eye above but for the right eye
        pixelDistanceR = expInfo.pixPerCm * screenR(1);
        LinePosR = round(screenXCentre + pixelDistanceR);
    end
    
    
else if strcmp(conditionInfo.stimType, 'combined');
        % Combination stimulus -- two vertical lines for each eye
        objectOneStart = [conditionInfo.objectOneStartPos, 0, expInfo.viewingDistance];
        %the start position of the first line
        objectTwoStart = [conditionInfo.objectTwoStartPos, 0, expInfo.viewingDistance];
        %the start position of the second line
        objectOneCurrentPosition = objectOneStart;
        [screenLone, screenRone] = calculateScreenLocation(fixation, objectOneCurrentPosition, eyeL, eyeR);
        %transferring this initial position for the first line onto the
        %screen
        
        objectTwoCurrentPosition = objectTwoStart;
        [screenLtwo, screenRtwo] = calculateScreenLocation(fixation, objectTwoCurrentPosition, eyeL, eyeR);
        %transferring this initial position for the second line onto the
        %screen
        
        pixelDistanceLone = expInfo.pixPerCm * screenLone(1);
        LinePosLone = round(screenXCentre + pixelDistanceLone);
        %finding the position of the first line in the left eye in pixels
        
        pixelDistanceLtwo = expInfo.pixPerCm * screenLtwo(1);
        LinePosLtwo = round(screenXCentre + pixelDistanceLtwo);
        %finding the position of the second line in the left eye in pixels
        pixelDistanceRone = expInfo.pixPerCm * screenRone(1);
        LinePosRone = round(screenXCentre + pixelDistanceRone);
        %finding the position of the first line in the right eye in pixels
        
        pixelDistanceRtwo = expInfo.pixPerCm * screenRtwo(1);
        LinePosRtwo = round(screenXCentre + pixelDistanceRtwo);
        %finding the position of hte second line in the right eye in pixels
        
        for iFrame = 1:nFramesPreStim %during the pre stimulus duration
             %For the left eye
            Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
            Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0); %drawing the fixation cross
            Screen('DrawLines', expInfo.curWindow, [LinePosLone, LinePosLone ; 0, screenYpixels], lw); %drawing the first line (left)
            Screen('DrawLines', expInfo.curWindow, [LinePosLtwo, LinePosLtwo ; 0, screenYpixels], lw); %drawing the second line (right)
            %For the right eye
            Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
            Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0) %drawing the fixation cross
            Screen('DrawLines', expInfo.curWindow, [LinePosRone, LinePosRone ; 0, screenYpixels], lw); %drawing the first line (left)
            Screen('DrawLines', expInfo.curWindow, [LinePosRtwo, LinePosRtwo ; 0, screenYpixels], lw); %drawing the second line (right)
            
            vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
        end
        
        for iFrame = 1:nFrames, %same as above
            %For the left eye
            Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
            Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0); %drawing the fixation cross
            Screen('DrawLines', expInfo.curWindow, [LinePosLone, LinePosLone ; 0, screenYpixels], lw); %drawing the first line (left)
            Screen('DrawLines', expInfo.curWindow, [LinePosLtwo, LinePosLtwo ; 0, screenYpixels], lw); %drawing the second line (right)
            %For the right eye
            Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
            Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0) %drawing the fixation cross
            Screen('DrawLines', expInfo.curWindow, [LinePosRone, LinePosRone ; 0, screenYpixels], lw); %drawing the first line (left)
            Screen('DrawLines', expInfo.curWindow, [LinePosRtwo, LinePosRtwo ; 0, screenYpixels], lw); %drawing the second line (right)
            
            vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
            
            objectOneCurrentPosition(3) = objectOneCurrentPosition(3) + velCmPerFrame; %finding the new object position for the first line
            [screenLone, screenRone] = calculateScreenLocation(fixation, objectOneCurrentPosition, eyeL, eyeR);
            %transferring this new position into positions on the two halves of the screen
            
            objectTwoCurrentPosition(3) = objectTwoCurrentPosition(3) + velCmPerFrame; %finding the new object position for the second line
            [screenLtwo, screenRtwo] = calculateScreenLocation(fixation, objectTwoCurrentPosition, eyeL, eyeR);
            %transferring this new position into positions on the two halves of the screen
            
            %For the left eye
            pixelDistanceLone = expInfo.pixPerCm * screenLone(1);
            %the new unadjusted pixel distance for the first line in the left eye
            LinePosLone = round(screenXCentre + pixelDistanceLone);
            %the new adjusted position of the line (in X) on the screen
            
            pixelDistanceLtwo = expInfo.pixPerCm * screenLtwo(1);
            %the new unadjusted pixel distance for the second line in the
            %left eye
            LinePosLtwo = round(screenXCentre + pixelDistanceLtwo);
            %the new adjusted position in X for the second line in the left
            %eye
            
            %For the right eye -- the same commands as above but for the
            %right eye rather than the left.
            pixelDistanceRone = expInfo.pixPerCm * screenRone(1);
            LinePosRone = round(screenXCentre + pixelDistanceRone);
            %first line in the right eye
            pixelDistanceRtwo = expInfo.pixPerCm * screenRtwo(1);
            LinePosRtwo = round(screenXCentre + pixelDistanceRtwo);
            %second line in the right eye
        end
        
        %% Looming only stimulus -- two horizontal lines
    else if strcmp(conditionInfo.stimType, 'looming');

            %One and two in the names refer to the first and second horizontal line
            %-- screenOne = the screen position of the first line, etc. At
            %the moment the top line is line one.
            
            HorizontalObjectOneStart = [0, conditionInfo.horizontalOneStartPos, expInfo.viewingDistance];
            %the start position for the first horizontal line
            HorizontalObjectTwoStart = [0, conditionInfo.horizontalTwoStartPos, expInfo.viewingDistance];
            %the start position for the second horizontal line
            
            objectOneCurrentHorizontalPosition = HorizontalObjectOneStart;
            [screenOne] = calculateHorizontalScreenLocation(fixation, objectOneCurrentHorizontalPosition);
            %uses new calculateHorizontalScreenLocation function which
            %is very similar to calculateScreenLocation but in terms of
            %y and z rather than x and z. -- finds screenY
            
            %line 1
            HorizontalOnePixelDistance = expInfo.pixPerCm * screenOne(2);
            HorizontalOneLinePos = round(screenYCentre + HorizontalOnePixelDistance);
            %finds the line position in a similar way to how it is found
            %previously
            
            %line 2
            objectTwoCurrentHorizontalPosition = HorizontalObjectTwoStart;
            [screenTwo] = calculateHorizontalScreenLocation(fixation, objectTwoCurrentHorizontalPosition);
            %again uses calculateHorizontalScreenLocation to find screenY
            %and work out the position on the screen in pixels (below)
            HorizontalTwoPixelDistance = expInfo.pixPerCm * screenTwo(2);
            HorizontalTwoLinePos = round(screenYCentre + HorizontalTwoPixelDistance);
            
              for iFrame = 1:nFramesPreStim %during the pre-stimulus duration have the lines appear in a fixed position
                   % For the left eye
                Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
                Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0); %draw fixation cross
                Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalOneLinePos, HorizontalOneLinePos], lw); %draw line 1 = top line
                Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalTwoLinePos, HorizontalTwoLinePos], lw); %draw line 2 = bottom line
                %For the right eye
                Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
                Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0); %these are the same drawing commands as above but for the right eye
                Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalOneLinePos, HorizontalOneLinePos], lw);
                Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalTwoLinePos, HorizontalTwoLinePos], lw);
                
                vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2);
              end
            
            for iFrame = 1:nFrames, %same as for the other stimuli
                % For the left eye
                Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
                Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0); %draw fixation cross
                Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalOneLinePos, HorizontalOneLinePos], lw); %draw line 1 = top line
                Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalTwoLinePos, HorizontalTwoLinePos], lw); %draw line 2 = bottom line
                %For the right eye
                Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
                Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0); %these are the same drawing commands as above but for the right eye
                Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalOneLinePos, HorizontalOneLinePos], lw);
                Screen('DrawLines', expInfo.curWindow, [0, screenXpixels ; HorizontalTwoLinePos, HorizontalTwoLinePos], lw);
                
                vbl=Screen('Flip', expInfo.curWindow,vbl+expInfo.ifi/2); %taken from PTB-3 MovingLineDemo
                
                %Calculating the new screen position for horizontal line 1
                %in a similar way to how the new positions are calculated
                %above.
                %uses new calculateHorizontalScreenLocation function which
                %is very similar to calculateScreenLocation but in terms of
                %y and z rather than x and z.
                objectOneCurrentHorizontalPosition(3) = objectOneCurrentHorizontalPosition(3) + velCmPerFrame;
                [screenOne] = calculateHorizontalScreenLocation(fixation, objectOneCurrentHorizontalPosition);
                
                HorizontalOnePixelDistance = expInfo.pixPerCm * screenOne(2);
                HorizontalOneLinePos = round(screenYCentre + HorizontalOnePixelDistance);
                
                %Calculating the new screen position for horizontal line 2
                %in a similar way to how the new positions are calculated
                %above.
                objectTwoCurrentHorizontalPosition(3) = objectTwoCurrentHorizontalPosition(3) + velCmPerFrame;
                [screenTwo] = calculateHorizontalScreenLocation(fixation, objectTwoCurrentHorizontalPosition);
                
                HorizontalTwoPixelDistance = expInfo.pixPerCm * screenTwo(2);
                HorizontalTwoLinePos = round(screenYCentre + HorizontalTwoPixelDistance);
                
                %Doing calculations for the second line position similarly
                %to above.
                
            end
        end
    end
end

Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0);
Screen('DrawLines', expInfo.curWindow, boxCoords, lw);

Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
Screen('DrawLines', expInfo.curWindow, FixCoords, fixWidthPix, [], expInfo.center, 0);
Screen('DrawLines', expInfo.curWindow, boxCoords, lw);

Screen('Flip', expInfo.curWindow); %the final necessary flip.

end

