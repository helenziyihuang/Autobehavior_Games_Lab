 
clc; 
clear all;
addpath('PTB-Game-Engine/GameEngine');
addpath('Common');
addpath('Main Game');
addpath('Img');

requestInput;
developerMode = isfile('devMode.ignore');


if developerMode
choice = menu('Keyboard or Autobehavior Rig input?','Keyboard','Rig');
usingKeyboard = choice==1;
else
usingKeyboard = false;
end
rect = [0,0,1,1];
if usingKeyboard
    io = Keyboard;
else
    choice = menu('Which circuit board are you using?', 'Gen2 (Purple)','Gen4','Gen2.1 (Gen3 hardware on purple PCB)','Headfixed');
    switch choice
        case 1
            io = HardwareIOGen2(port);
        case 2
            io = HardwareIOGen4(port);
        case 3
            io = HardwareIOGen2_1(port);
        case 4
            io = HardwareHeadfixed(port,str2num(rig));
            rect = [1/3,0,2/3,1];
    end
end

emailer = Emailer('sender','recipients');
results = Results(mouseID,numTrials,sessionNum,'closedLoopTraining');
renderer = Renderer(screenNum,0.5,rect);
grating = GratedCircle;
greenCirc = TargetRing;
background = RandomizedBackground('backgroundDot.png',20);
background.SetParent(grating);
background.RenderAfter(greenCirc)
iescape = EscapeQuit;
sound = SoundMaker;


controller = GratedCircleController(grating,io);

manager = MainGameManager(grating,greenCirc,background,controller,io,sound,results);
manager.SetMaxTrials(numTrials);
manager.SetAllowIncorrect(reward);


ge = GameEngine;
try
    ge.Start(); 
catch e
    if ~developerMode
            msg = char(getReport(e,'extended','hyperlinks','off'));
            subject = "Autobehaviour ERROR: rig "+string(rig)+" mouse "+string(mouseID);
            emailer.Send(subject,msg);
    end
    rethrow(e);
end
if manager.GetNumberOfGamesPlayed()>=numTrials
    msg = char("mouse "+string(mouseID) + " on rig " + string(rig) + " has successfully completed " + string(numTrials) + " trials.");
    subject = "Autobehaviour SUCCESS: rig "+string(rig)+" mouse "+string(mouseID);
    emailer.Send(subject,msg);
end
