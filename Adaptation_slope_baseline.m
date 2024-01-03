%EXPERIMENT Dr FANG JIANG LAB, testing dynamics of adaptation to facial ethinicity image,
% Each testing duration is 0.25 secs and 1 secs and number of testing
% events are 4 and 16, resulting in 4 conditions.
%PREPARING THE MATLAB
% sub-script for adaptation to sharp image

clc; % clears the command window
clear all;
sca; % closes all screens, windows
clearvars; % clears the workspace where all the variables are listed
% clear all;

format shortG;
PsychDefaultSetup(2);

%% SAVING LOCATION
%%1st option
BaseFolder='C:\Users\nzaman\Documents\MATLAB'; % change this to whatever folder you want


% %2nd option
% Savefolder='C:\Users\ishareef\Desktop';

% cd(Savefolder);

%%Prompt and open file for writing the data
% SubjNum='1';MonitorLen=19.5;ImageChosen='Face';
Prompt = 'Subject Number:';  SubjNum = input(Prompt,'s');
Prompt = 'AdaptCondition:(1 for adaptaiton, 0 for baseline)'; AdaptConds=input(Prompt,'s'); 
AdaptCond = str2double(AdaptConds); 
MonitorLen = 39;
%Prompt = 'Image you want to test (Type Face/nature - as shown):'; 
ImageChosen = 'nature';
DateTime = clock; Date=DateTime(1:3); Time=DateTime(4:end);
FileName=strcat('Adaptation_dynamics_blur_baseline','_', ImageChosen);
Outputname = [SubjNum  '_' FileName '.xls'];
if exist(Outputname,'file')==2 % check to avoid overiding an existing file
    fileproblem = input('That file already exists! Append a .x (1), overwrite (2), or break (3/default)?');
    if isempty(fileproblem) || fileproblem==3
        return;
    elseif fileproblem==1
        Outputname = [Outputname '.x'];
    end
end
%% PARAMETERS OF EXPERIMENT
TestDur = 0.25; % Duration of each image presentation during a trial
BlankScrDur = 0.1; % Duration for which screen is blank, in between events or in between trials
nImages=101; % Number of intermediate morph images
%% Parameters for staircase
CurrRev = 0; %Current reversal number
nRev = 25; % 10 %stop rule for staircase
StepSize = 50; % initial step size
MinStepSize = 5;
FinalTrial = 20;


%% KEYS TO PRESS

KbName('UnifyKeyNames'); % to get the key codes of the keys
EscapeKey=KbName('Escape'); %keyCode 27
SpaceKey=KbName('Space'); %3
Blur = KbName('4');
Sharp = KbName('5');

CorrKeys=[Blur Sharp];


%% SCREEN PARAMETERS

Screen('Preference', 'SkipSyncTests', 1); % to prevent synchronization errors stopping you from running the code, you have to delete this probably once you are done coding
%and fix the sync error
NoOfScreens=Screen('Screens'); %gets the number of screens attached to the computer, The screen with the menu bar is identifi ed with the
%default number “0”
ScreenNum=max(NoOfScreens); %selects the screen without the menubar to avoid crashing coz the screen with menubar can be used to see what error has been thrown.
Screen('Preference','SuppressAllWarnings', 1);
oldEnableFlag = Screen('Preference', 'TextAntiAliasing', 0);
%Luminance levels in gray levels
White = WhiteIndex(ScreenNum); %1
Grey = White/2; %0.5
Black = BlackIndex(ScreenNum); %0
%OPEN WINDOW
[MainWin, Winrect]=PsychImaging('OpenWindow',ScreenNum,Grey,[],[],[]); %opens a window and fills in grey and also gives the size of the window in the name Winrect
%windowPtr mentioned in docs is MainWin here
[screenXpixels, screenYpixels] = Screen('WindowSize', ScreenNum); % Gets the last 2 numbers of Winrect, this can also be got by tmp = Screen('Resolution',0); display.resolution = [tmp.width,tmp.height];

% Aperture Size calc
PixInOneCM=MonitorLen/screenYpixels; %number of pixels in 1cm at monitor
ScrCM=tand(2)*60; % how many cm at monitor in 2 deg
Aperture_r = 97*5; % subtends 2.5 deg from 80 cms, which doubles in square variable to 5deg per image %OLD - 3* (ScrCM/PixInOneCM); %radius of the aperture in pixels
Aperture_r2 = 97*1.5; % subtends 2.5*1.5 = 3.75 deg 

[xCenter, yCenter] = RectCenter(Winrect); % finds the center of the screen
ifi = Screen('GetFlipInterval', MainWin); % ifi is the inter-frame in terval, This refers to the minimum possible time between
%drawing to the screen - this syntax does not work without exceuting it along with 'Openwindow' syntax coz the screen has to be open for this to work.
Hertz=FrameRate(MainWin); % Hertz is Refresh rate of the screen. this is equal to 1/ifi

% nFrames=ceil(Hertz*AdaptDur);% Frames through which adaptation images are shown in total
Screen('BlendFunction', MainWin, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % for anti-aliasing- to make the dots appear un-pixelated.
% Square aperture
Square=[(xCenter-Aperture_r) (yCenter-Aperture_r) (xCenter+Aperture_r) (yCenter+Aperture_r)];
% TestSquare = [(xCenter-Aperture_r)+80 (yCenter-Aperture_r) (xCenter+Aperture_r)+80 (yCenter+Aperture_r)];

fixCrossDimPix = 10;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0]; % for fixation cross 
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix]; % for fixation cross 
allCoords = [xCoords; yCoords];
lineWidthPix = 1;

%% SAVING FOLDER LOCATION

Savefolder = strcat(BaseFolder,'\','Output');
if ~exist(Savefolder, 'dir')%checks if folder already exists, otherwise creates one
  mkdir(Savefolder);
end
cd(Savefolder);

%%INSTRUCTIONS
DrawFormattedText(MainWin, 'If image is BLURRED, press 4 or if image is SHARP press 5 \n Press spacebar to start the experiment' , 'center', 'center',Black, [],[],[],2);
Screen('Flip',MainWin );

keyIsDown=0;
while 1
    [keyIsDown, timeSecs, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(SpaceKey)
            break ;
        elseif keyCode(EscapeKey)
            ShowCursor;
            sca;
            Screen('CloseAll');
            return;
        end
    end
end
resultsAll=[];
 HideCursor; 
 % LOOP
    
    Trial = 0;
    KeyPressedArray=[];
    CurrRev=0;
    TestingCondition = 1;
    NumEvents = 1;
    PerImageAdaptDur = TestDur;

    % cd('C:\Users\nzaman\Documents\MATLAB\videoframes')
    % AdaptImage = imread('6_nature_34-0.5_-1.53_-1.7_6_.jpg');
    % AdaptTex = Screen('MakeTexture', MainWin, AdaptImage);
    % Screen('DrawTexture', MainWin, AdaptTex, [], Square, [], 0);
    % Screen('Flip', MainWin, Grey); % Flip to the screen
    % WaitSecs(5);

    cd('C:\Users\nzaman\Documents\MATLAB'); 
    % End of video presentation 
    while CurrRev<nRev
        Trial=Trial+1; %counts the number of trials
               
                
        %% test image location and selecting 1st test image
        D = [-40 -20 20 40]; % displacement in pixels 
        RHD = D(randi(numel(D))); % random horizontal displacement 
        RVD = D(randi(numel(D))); % random vertical displacement 
        TestSquare = [(xCenter-Aperture_r2)+RHD (yCenter-Aperture_r2) (xCenter+Aperture_r2)+RHD (yCenter+Aperture_r2)]; 
        % TestImageLoc=strcat(BlurImageLoc,'\',char(ContainStrings(2)));%Location of test images in the computer
        TestImageLoc='C:\Users\nzaman\Documents\MATLAB\nature';
        TestImages = dir(fullfile(TestImageLoc,'*.jpg')); % lists the images with this name https://www.mathworks.com/matlabcentral/answers/385-how-to-read-images-in-a-folder
        NumTestImg = length(TestImages); % https://www.mathworks.com/help/matlab/import_export/process-a-sequence-of-files.html
        TestPix = cell(1, NumTestImg); % creates a blank cell array for filling in the pixels later
        
        if Trial ==1
            FirstTestImges = Shuffle([1:10 nImages-10:nImages]);% to select the first test image which is either obviously focused or obviously blurred
            PresentTestImge = FirstTestImges(1); % selects one test image 'number' from the shuffled first test image possibilities
        end
        
        
        
        % TestImageBlur=[];
        
        TestImgString=strcat('_',num2str(PresentTestImge),'_'); % the string containing the selected test image number
        TestImgName=cell(1,NumTestImg);
        
        for b=1:NumTestImg
            %         if(~contains(BlurImages(b).name,TestImgString)==1)
            %         if((~isempty(strfind(TestImages(b).name,TestImgString))) && (~isempty(strfind(TestImages(b).name,TestMatch))) && ~TestImages(b,:).isdir) % checks if the file names contain the string
            if contains(TestImages(b).name,TestImgString) && contains(TestImages(b).name,ImageChosen) && ~TestImages(b,:).isdir
                TestImgName{b}=TestImages(b).name; % if yes, then saves it to the preallocated cell array
                TestImgName=TestImgName(~cellfun('isempty',TestImgName)); % deletes the empty elements from the cell array
                SplitTestImgNames=strsplit(string(TestImgName),'_');
                Unknown=SplitTestImgNames{2};
            end
        end
        
        %     TestImgNames=Shuffle(TestImgNames); % shuffles the selected test images
        % TestImgName=TestImgNames(1);% test image name
        % %to extract the name of the Orignal image to select the test image matching the original image
        % SplitFN=strsplit(string(TestImgName),'_');
        % TestMatch=SplitFN{1};
            % Video presentation 

            Top_Start = Shuffle([200 400 600]); 
            Start = Top_Start(1); 
cd('C:\Users\nzaman\Documents\MATLAB\TopUp'); 
AdaptImages = dir("*.jpg"); 
Mins = 3; % Change this to adaptation duration 
   
    if AdaptCond == 1 % Adaptation condition (short/long; 
    t1 = clock;
    for AdaptNum = Start:Start+30
        Number = num2str(AdaptNum); 
        nameofimage = strcat(Number,'.jpg'); 
        %nam = strcat(nameofimage,'.jpg');
        Image = imread(nameofimage);
        ImageTex = Screen('MakeTexture',MainWin,Image);
        Screen('DrawTexture', MainWin, ImageTex,[],Square,[],0);
        Screen('Flip',MainWin);
        WaitSecs(1/15);   % 15 frames per second. 
       end % end of adaptation phase 
    end 

    cd('C:\Users\nzaman\Documents\MATLAB'); 
    % End of video presentation 
        
        TestImage = char(strcat(TestImageLoc,filesep,ImageChosen,'_',Unknown,  TestImgString,'.jpg')); 
        %     TestImage = char(strcat(TestImageLoc,'\', TestImgName)); %exact location of the image for imread to display, needs char because test image is a cellarray
        TestPix = imread(TestImage); % reads the image to say how many pixels-opens file from current directory or from the file location specified.
        MakeTextureT = Screen('MakeTexture', MainWin, TestPix); % converts image into texture for it to be drawn in PTB
        Screen('DrawTexture', MainWin, MakeTextureT, [], TestSquare, [], 0);
        %     Screen('DrawText',MainWin,'Test' ,xCenter-400,yCenter,White);
        Screen('Flip', MainWin, Grey); % Flip to the screen
        WaitSecs(TestDur);
        if PresentTestImge== NumTestImg || PresentTestImge== 1%upper limit
                    Beeper('med')
                else  % lower limit
                    Beeper('high')
        end
        T1 = GetSecs; 
        clear TestPix ;
        Screen('FillRect', MainWin ,Grey);
        Screen('Flip', MainWin);
        WaitSecs(BlankScrDur);
        
        %%%%% for keyboard responses:
        keyIsDown = 0;
        StartTime = GetSecs;  %read the current time on the clock
        RT=0;
        correct=0;
        RestrictKeysForKbCheck ([100, 101, 27]);
        
        
        %       Screen('FillRect', MainWin ,Grey);
        %       Screen('Flip', MainWin);
        %     WaitSecs(BlankScrDur)
        % Start
        while 1
            [keyIsDown, timeSecs, keyCode, deltaSecs] = KbCheck;
            %         FlushEvents('keyDown');
            if keyIsDown
                nKeys = sum(keyCode);
                if nKeys==1
                    if keyCode(Blur) ||keyCode(Sharp) % 4- Focused, 5- Blurred
                        RT = (timeSecs-StartTime);
                        Keypressed= find(keyCode);
                        break;
                    elseif keyCode(EscapeKey)
                        ShowCursor; Screen('CloseAll'); return
                    end
                    keyIsDown=0; keyCode=0;
                end
            end
        end
        RestrictKeysForKbCheck([]);
        RecTime = StartTime-T1; 
        KeyPressedArray(1, Trial) = Keypressed ;
        
        if Trial>1 % don't do counting for the first trial because there is no response collected yet
            % to count reversals
            %         [~,KeypressedIdx]=find(resultsAll==Keypressed); % finds the column number of keypressed in resultsAll
            %         PrevKeypressed=resultsAll(Trial-1,KeypressedIdx); % finds the previous keypressed to compare with current keypress
            PrevKeypressed=KeyPressedArray(1,Trial-1);
            if Keypressed==PrevKeypressed
                CurrRev;
            else
                CurrRev=CurrRev+1; % adds the reversal if the responses are different
            end
        end
        
        TI=PresentTestImge;% test image number
        keypress=Keypressed; % finds the key that was pressed
        if keypress == Blur
            Response="Blur";
        elseif keypress == Sharp
            Response="Sharp";
        end
        
        TestImgName=string(TestImgName);
        Unknown=string(Unknown);
        if contains(Unknown,'n') % negative is blur
            Unknown=strrep(Unknown,'n','-');
        else
            Unknown=Unknown;
        end
        Slope= flip(-1:0.02:1); ImageRange=1:nImages;
        SlopeTable=[Slope', ImageRange'];
        [indexS, ~]=find(SlopeTable(:,2)==PresentTestImge); % finds indices of reversals
        CurrSlope=SlopeTable(indexS,1);
        
        results=[TestingCondition PerImageAdaptDur NumEvents Trial CurrRev TI TestImgName Unknown CurrSlope Response RT]; % all data that I need from the iteration
        resultsAll=[resultsAll;results];
        
        %%%%%% to change step size if reversal has happened
        if Trial>1
            % to change the step size after every reversal
            [~,CurrRevIdx]=find(resultsAll(Trial,:)==num2str(CurrRev)); % finds the column number of keypressed in resultsAll, since resultsAll is a string coz of response variable, CurrRev had to be converted to string!!
            PrevTrialRev=resultsAll(Trial-1,CurrRevIdx);
            if CurrRev==str2double(PrevTrialRev) % since resultsall is string, prevtrialRev is string, matching cant be done between string and num
                StepSize;
            else
                StepSize=round(StepSize/2);
                if StepSize<MinStepSize
                    StepSize=StepSize*2;
                end
            end
        end
        if Trial==1
            CurrRev=CurrRev;
        end
        
        
        %%%%% changing test images after the step size for the next trial is determined
        if Keypressed==CorrKeys(1) % CorrKeys=[Focused Blurred]
            PresentTestImge=PresentTestImge+StepSize;
        elseif Keypressed==CorrKeys(2)
            PresentTestImge=PresentTestImge-StepSize;
        end
        
        %%%%% test image to present when limits reached
        if PresentTestImge>nImages %upper limit
            PresentTestImge=nImages;
            % Beeper('low')
        elseif PresentTestImge<1 % lower limit
            PresentTestImge=1;
            %  Beeper('low')
        end
        
        Screen('FillRect', MainWin ,Grey);
        Screen('Flip', MainWin);
        WaitSecs(0.25);
        
        
    end
fullFileName = fullfile(Savefolder, Outputname); % full excel file name

resultsHead = {'TestingCondition' 'PerImageAdaptDur' 'NumEvents' 'Trial' 'CurrRev' 'TI' 'TestImageName' 'Unknown1' 'Slope' 'Response'}; % all data that I need from the iteration
xlswrite(fullFileName,resultsHead,1,'A1');
xlswrite(fullFileName,resultsAll,1,'A2');


DrawFormattedText (MainWin, 'End of block, Take 10 min break before the next block', 'center', 'center', Black, [],[],[],2);
Screen ('Flip', MainWin);
WaitSecs(2);
%% close the window

Screen('Close', MainWin);
% Screen('CloseAll');


%% writing data


