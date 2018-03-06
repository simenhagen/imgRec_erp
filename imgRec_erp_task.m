%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               ERP, dog/cat categorization task task

%                        Written by Simen Hagen, 2018
%
%
% run('/home/simen/Dropbox/Research/Experiments/FPVS/Nancy/DogCat_fpvs/ERP/Task')
%
% * This experiment is used to test a category response to dogs and cats.
%
%
%
% To do:
% * finish it. Yay!

% --------------------------------- Explanation -------------------------------%
% * Imports experiment lists from the Lists-folder. Each list specifies trial
% content.
% The lists must be created manually. The length of 'phase' is determined by
% the number of experiment lists.
% * The stimuli is separated in different folders for s1 and s2, species,
% and family. Files are indexed depending on the content of the experiment
% list
% * RT measure starts once S2 is presented. Show image fixed instead?
%
%

clear all; close all; clc

%-------------------------------------------------------------------------------
%                       Pre-experiment: general stuff                          %
%-------------------------------------------------------------------------------

% Check for OpenGL compatibility; otherwise shut down
AssertOpenGL;

% Set keyboard mapping to same across OS
KbName('UnifyKeyNames');

% Reseed the random state generator
rand('state', sum(100*clock));

%---------------------Pre-experiment: variables and parameters------------------

% Image size vector
% s_img_vector = [0.80,0.90,1.00,1.10,1.20];

% Font sizes
instruct_font_size = 20;
response_font_size = 28;

% Set response keys
advance_resp = KbName('space');
dog_resp = KbName('f');
cat_resp = KbName('j');

% Trial list names
%filenames = dir(fullfile(pwd,'Lists/', '*.csv'));

% initiate rt variable
startrt = [];


% Get file names 
files_prac_cats = dir(fullfile(pwd,'Stimuli/cats_practice/', '*.jpg'));
files_prac_dogs = dir(fullfile(pwd,'Stimuli/dogs_practice/', '*.jpg'));
files_test_cats = dir(fullfile(pwd,'Stimuli/cats_test/', '*.jpg'));
files_test_dogs = dir(fullfile(pwd,'Stimuli/dogs_test/', '*.jpg'));

npractice_trials = length(files_prac_cats)*2;
ntest_trials = length(files_test_cats)*2;

% Create trial lists
prac_list = [];
for i = 1:npractice_trials
        if i <= npractice_trials/2
            j = 1; % 'cat';
        else
            j = 2; % 'dog';
        end

    prac_list = [prac_list;i,j];
end

% Create trial lists
prac_list = [1:npractice_trials; ones(1,npractice_trials/2),ones(1,npractice_trials/2)*2; 1:npractice_trials/2,1:npractice_trials/2]';
test_list = [1:ntest_trials; ones(1,ntest_trials/2),ones(1,ntest_trials/2)*2; 1:ntest_trials/2,1:ntest_trials/2]';


% Randomize test lists and stimuli lists
% Use object indicator to index either dogs or cats (e.g., if 2, then
% current file = files_test_cats(1).name -> then delete the row once done.

%-----------------------------------------
% Pre-experiment: file/subject information
%-----------------------------------------

% Poll subject information and create output file
repeat=1;
while (repeat)
    prompt= {'Participant number (format: 001)', 'Age', 'Gender', 'CB group'};
    defaultAnswer={'','','',''};
    options.Resize = 'on';
    answer=inputdlg(prompt,'Participant Information',1, defaultAnswer, options);
    [subjNo, subjAge, subjGender, subjGroup]=deal(answer{:});
    if isempty(str2num(subjNo)) || ~isreal(str2num(subjNo)) || isempty(str2num(subjAge)) || ~isreal(str2num(subjAge)) || isempty(num2str(subjGender) || isempty(str2num(subjGroup)) || ~isreal(str2num(subjGroup)))
        h=errordlg('Please fill in all information correctly','Input Error');
        repeat=1;
        uiwait(h);
    else
        if str2num(subjGroup) == 1
            subjGroup_label = 'CBgroup01';
            OutputFile = sprintf('Data/subj_%s_CBgroup01.txt', subjNo);
        elseif str2num(subjGroup) == 2
            subjGroup_label = 'CBgroup02';
            OutputFile = sprintf('Data/subj_%s_CBgroup02.txt', subjNo);
        end
        if exist(OutputFile,'file')~=0
            button=questdlg(['Overwrite subj' subjNo '.txt?']);
            if strcmp(button,'Yes'); repeat=0; end
        else
            repeat=0;
        end
        % create .txt file to store data
        datafilepointer = fopen(OutputFile, 'wt');
    end
end

%------------------------------------------------------------------------------%
%                                 Eperiment                                    %
%-------------------------------------------------------------------------------

try

    % Hide mouse cursor
    HideCursor;

    % Screen
    screens = Screen('Screens');
    screenNumber = max(screens);

    % Get mean gray and white values of screen
    Gray = GrayIndex(screenNumber);
    White = WhiteIndex(screenNumber);

    %% Screen resolution
    screenRes = [800 600];
    Screen('Resolution', screenNumber, screenRes(1), screenRes(2));

    % Open double buffered window on stimulation screen
    %[w, wRect] = Screen('OpenWindow', screenNumber, White, [0 0 1000 700]);
    [w, wRect] = Screen('OpenWindow', screenNumber, White);

    % Get center dimensions of screen
    [cRect(1), cRect(2)] = RectCenter(wRect);

%     % compute frames per second - used to present dynamic noise-mask
%     fps = Screen('FrameRate', w);  % frames per second
%     ifi = Screen('GetFlipInterval', w);
%     if fps==0
%         fps=1/ifi;
%     end;

    % Text size
    Screen('TextSize', w, instruct_font_size);

    % Load GetSecs; WaitSecs; KbCheck
    KbCheck;
    GetSecs;
    WaitSecs(0.1);

    % Realtime priority for script execution
    priorityLevel = MaxPriority(w);
    Priority(priorityLevel);

    % Initiate KbCheck and variables
    [KeyIsDown, startRT, KeyCode] = KbCheck;

    % MESSAGE: intro
    msg_intro_01 = 'Welcome!\n\n Your task is to discriminate between dogs and cats.\n In a given trial, you will see an image for 0.3 seconds.\n Press _ f _ if you see a dog. Press _ j_ if you see a cat.';
    msg_advanceTrial = 'Press _ MOUSE _ to continue';
    msg_intro = [msg_intro_01, '\n\n\n', msg_advanceTrial];
    DrawFormattedText(w, msg_intro, 'center', 'center');
    Screen('Flip', w);

    GetClicks(w);

%     repeat = 1;
%     while repeat
%         if KeyCode(advance_resp)==1
%             repeat = 0;
%             break;
%         end
%         [KeyIsDown, temprt, KeyCode] = KbCheck;
%         WaitSecs(0.001);
%     end


skip_pract = 1;

    if skip_pract == 0
       startPhase = 1;
       nPhase = 2; % practice and test session
    else
       startPhase = 2;  % skip practice.
       nPhase = 2;
    end

    % Loop over phase (practice/test)
   for phase = startPhase:nPhase   % phase 1 = practice; phase 2 = test
        
        % Load variables conditional on phase (prac vs. exp)
        if phase == 1
            phase_label = 'Practice';
            ntrials = length(files_prac_cats)+length(files_prac_dogs);
        else
            phase_label = 'Test';
            ntrials = length(files_test_cats)+length(files_test_dogs);
        end
        
        % Timing parameters
        iti = (1.6 + (1.8-1.6).*rand(ntrials,1))*1000;  % 1600 - 1800 ms
        stim_dur = 0.300;
        isi = (0.2 + (0.3-0.2).*rand(ntrials,1))*1000;  % 200 - 300 ms
        %waitframes = 1;

        % Customize trial list
        trial_conds_name = filenames(phase).name;
        %[trial_id, obj_fam, trial_type, s1_species, s2_species, s1_exemplar, s2_exemplar] = textread([pwd, '/Lists/', trial_conds_name],'%n%n%n%n%n%n%n%*[^\n]','delimiter',',');

        % Randomize trial list
        ntrials = length(trial_id);
        randomorder = randperm(ntrials);
        trial_id = trial_id(randomorder);
        obj_fam = obj_fam(randomorder);
        trial_type = trial_type(randomorder);
        s1_species = s1_species(randomorder);
        s2_species = s2_species(randomorder);
        s1_exemplar = s1_exemplar(randomorder);
        s2_exemplar = s2_exemplar(randomorder);


        % Initiate KbCheck and variables
        WaitSecs(0.1);
        [KeyIsDown, temprt, KeyCode] = KbCheck;

        % MESSAGE screen: phase instructions
        msg_phase = sprintf('%s Session\n\n Press _ f _ for SAME and _ j _ for DIFFERENT.', phase_label);
        DrawFormattedText(w, [msg_phase, '\n\n', msg_advanceTrial], 'center', 'center');
        Screen('Flip', w);
        GetClicks(w);

%         repeat = 1;       % Wait for _ SPACE _ press
%         while repeat
%            if KeyCode(advance_resp)==1
%                repeat = 0;
%                break;
%            end
%         [KeyIsDown, temprt, KeyCode] = KbCheck;
%         WaitSecs(0.001);
%         end

        WaitSecs(1.000);  % Wait fixed time before starting first trial


        % Trial loop
        for trial = 1:ntrials

            % Take a break.
            if trial == round(ntrials*0.1) || trial == ntrials*0.5 || trial == ntrials*0.75
                break_msg = sprintf('Please take a break.\n\n You have finished %i percentage.\n\n\n%s.',round(trial/ntrials*100),msg_advanceTrial);
                Screen('TextSize', w, instruct_font_size);
                DrawFormattedText(w,break_msg,'center','center',[0,0,0]);
                Screen('Flip',w);
                GetClicks(w);
            end


            % inter-trial-interval
            WaitSecs(iti);

            % Initiate KbCheck and such
            [KeyIsDown, temprt, KeyCode] = KbCheck;

            % randomly select horizontal orientation
            if randi(2) == 1
                orientFolder_label_s1 = 'left';
                orientFolder_label_s2 = 'right';
            else
                orientFolder_label_s1 = 'right';
                orientFolder_label_s2 = 'left';
            end

            if subjSession == '1'
                stim_folder_label = 'pretest';
            elseif subjSession == '2';
                stim_folder_label = 'posttest01';
            elseif subjSession == '3';
                stim_folder_label = 'posttest02';
            end

            % Load stimuli
            if phase == 1
                s1_path = sprintf('%s/Stimuli/practice/family0%i/Species0%i/%s/', pwd, obj_fam(trial), s1_species(trial),orientFolder_label_s1);
                s2_path = sprintf('%s/Stimuli/practice/family0%i/Species0%i/%s/', pwd, obj_fam(trial), s2_species(trial),orientFolder_label_s2);
            elseif phase == 2
                s1_path = sprintf('%s/Stimuli/%s/family0%i/Species0%i/%s/', pwd, stim_folder_label, obj_fam(trial), s1_species(trial),orientFolder_label_s1);
                s2_path = sprintf('%s/Stimuli/%s/family0%i/Species0%i/%s/', pwd, stim_folder_label, obj_fam(trial), s2_species(trial),orientFolder_label_s2);
            end
            family = sprintf('family0%i',obj_fam(trial));
            s1_list = dir(fullfile(s1_path, '*.bmp'));
            s1_name = s1_list(s1_exemplar(trial)).name;
            s2_list = dir(fullfile(s2_path, '*.bmp'));
            s2_name = s2_list(s2_exemplar(trial)).name;

            imdata_s1 = imread([s1_path, s1_name]);
            tex_s1 = Screen('MakeTexture', w, imdata_s1);
            imdata_s2 = imread([s2_path, s2_name]);
            tex_s2 = Screen('MakeTexture', w, imdata_s2);

            % Display Stimulus 1
            s1_img_scalar = s_img_vector(randi(length(s_img_vector)));
            sx_img_s1 = size(imdata_s1,1)*s1_img_scalar;
            sy_img_s1 = size(imdata_s1,2)*s1_img_scalar;
            Screen('DrawTexture', w, tex_s1,[],[cRect(1)-sx_img_s1/2, cRect(2)-sy_img_s1/2, (cRect(1)-sx_img_s1/2)+sx_img_s1,(cRect(2)-sy_img_s1/2)+sy_img_s1]);
            Screen('Flip', w);
            WaitSecs(stim_dur);
            Screen('Flip', w);
            WaitSecs(isi);

            vbl = Screen('Flip', w);
            % Noise-mask (dynamic)
            Sz =  size(imdata_s1);
            s = 96;
            t1 = GetSecs;
            for noiseloop = 1:15
                noise = 128 + 127*(2*(rand(Sz(1), Sz(2)) > 0.5)-1);
                tex_noise = Screen('MakeTexture', w, noise);
                Screen('DrawTexture', w, tex_noise);
                %Screen('Flip', w);
                vbl = Screen('Flip', w, vbl + 2*((waitframes - 0.5)*ifi));
            end
            t2(trial) = GetSecs - t1;
            Screen('Flip', w);

            WaitSecs(isi);

            % Display Stimulus 2
            s2_img_scalar = s_img_vector(randi(length(s_img_vector)));

            while s1_img_scalar == s2_img_scalar
                s2_img_scalar = s_img_vector(randi(length(s_img_vector)));
            end

            sx_img_s2 = size(imdata_s2,1)*s2_img_scalar;
            sy_img_s2 = size(imdata_s2,2)*s2_img_scalar;
            Screen('DrawTexture',w,tex_s2,[],[cRect(1)-sx_img_s2/2, cRect(2)-sy_img_s2/2, (cRect(1)-sx_img_s2/2)+sx_img_s2,(cRect(2)-sy_img_s2/2)+sy_img_s2]);
            Screen('Flip', w);
            WaitSecs(stim2_dur);
            Screen('Flip', w);
            WaitSecs(isi);

%            [VBLTimestamp, startrt] = Screen('Flip', w);  % rt is recorded once s2 is presented.
%             repeat = 1;
%             while (GetSecs - startrt) <= stim2_dur
%                 if KeyCode(same_resp) == 1 || KeyCode(diff_resp) == 1
%                     repeat = 0;
%                     break;
%                 end
%                 [KeyIsDown, endrt, KeyCode] = KbCheck;
%                 WaitSecs(0.001);
%             end

           % Wait a bit to avoid overload
%           WaitSecs(0.001);

           % LOAD RESPONSE SCREEN
           resp_msg = 'Press _ f _ for SAME and _ j _ for DIFFERENT ';
           Screen('TextSize', w, response_font_size);
           DrawFormattedText(w, resp_msg, 'center', 'center');
           [VBLTimestamp, startrt] = Screen('Flip', w);

           repeat = 1;
           while repeat
              if KeyCode(same_resp) == 1 || KeyCode(diff_resp) == 1
                  repeat = 0;
                  break;
              end
              [KeyIsDown, endrt, KeyCode] = KbCheck;
              WaitSecs(0.001);
           end

           % Clear to background
           Screen('Flip', w);

           % Wait a bit to avoid overload
           WaitSecs(0.001);

           % Get first response (in case of multiple keypresses)
           resp = KbName(find(KeyCode, 1, 'first'));

           % Compute RT
           rt = round(1000*(endrt-startrt));

           % Compute ACC
           if ((KeyCode(same_resp) == 1 && trial_type(trial) == 1) || (KeyCode(diff_resp) == 1 && trial_type(trial) == 2))
               acc = 1;
           else
               acc = 0;
           end

           % Write data to file
           fprintf(datafilepointer, '%s\t %s\t %s\t %s\t %s\t %i\t %i\t %i\t %i\t %i\t %s\t %i\t %s\t %s\t %i\t %s\t %s\t %i\t %i\t \n ', ...
           subjNo, ...
           subjAge, ...
           subjGroup, ...
           subjGroup_label, ...
           subjSession, ...
           phase, ...
           trial, ...
           trial_id(trial), ...
           trial_type(trial) ,...
           obj_fam(trial), ...
           orientFolder_label_s1, ...
           s1_species(trial) ,...
           s1_name, ...
           orientFolder_label_s2, ...
           s2_species(trial), ...
           s2_name, ...
           resp, ...
           acc, ...
           rt);

        end % trial

    end % phase

    % Show closing screen
    ending_msg = 'Congratulations! You finished the task. Press _MOUSE_ to end the program.';
    Screen('TextSize', w, instruct_font_size);
    DrawFormattedText(w,ending_msg,'center','center',[0,0,0]);
    Screen('Flip',w);

    % Clean up
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    return;

catch
   Screen('CloseAll');
   ShowCursor;
   fclose('all');
   close all
   Priority(0)
   psychrethrow(psychlasterror);   % Output last error msg

end  % try...catch
