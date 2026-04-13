% GENERATE_ATHLETE_DATA - Generates files containing the workout statistics
%   and profiles of three athletes.
% 
% Team Members: 
%   Diana Quach (Data Manager)
%   Kareemat Adeagbo (Algorithm Developer)
%   Retal Sabbahi (Visualization Specialist)
% Date: April 2026
%
% Description:
%   Generates three .csv files for the workout statistics of each athlete.
%   For each athlete, data is generated for 21 days. Each day a random
%   exercise types is assigned. A random heart rate, duration, and
%   intensity is also generated for each day based on given ranges. Rest
%   days are assigned based on the pattern of their schedule. Athlete 1 has
%   an irregular schedule, so their rest days happen randomly twice a week.
%   Athlete 2 is more consistent with rest days every four days (twice a
%   week). Athlete 3 is very consistent with one rest day a week every 7th
%   day.
%   A .txt file is created to contain the profile descriptions of each
%   athlete.
%
% Inputs: None
% Outputs: athlete1_beginner.csv , athlete2_intermediate.csv ,
%   athlete3_advanced.csv , athlete_profiles.txt

clear; clc; close all;

%% ------------- Creating Directory -------------
folder = fullfile("..", "Data", "Athletes");
if ~isfolder(folder)
    mkdir(folder)
end

%% ------------- Athlete 1 -------------
% PreWorkoutHR: 70-85 bpm
% PostWorkoutHR: 120-150 bpm
% Duration: 10-25 minutes
% Intensity: 3-6
% Pattern: Irregular schedule
% Include 2-3 "Rest" days a week

rng(1); % sets the seed for repeatability

% 2 Random Rest Days a Week
restw1d1 = randi([1,7]); % week 1 rest days; week1 day1
restw1d2 = randi([1,7]); % week 1, rest day 2
while restw1d2 == restw1d1 % ensures unique and random rest days
    restw1d2 = randi([1,7]);
end
restw2d1 = randi([8,14]); % week 2 rest days; week2 day1
restw2d2 = randi([8,14]);
while restw2d2 == restw2d1
    restw2d2 = randi([8,14]);
end
restw3d1 = randi([15,21]); % week 3 rest days; week3 day1
restw3d2 = randi([15,21]);
while restw3d2 == restw3d1
    restw3d2 = randi([15,21]);
end
restDays = [restw1d1, restw1d2, restw2d1, restw2d2, restw3d1, restw3d2];

rowDays = 1:21;

% Randomize workouts on non-rest days
rowExerciseType = strings(1,21);
for i = 1:21
    randomWorkout = randi([1,4]); % 4 workouts: "Running", "Pushups", "Squats", "Cycling"
    if randomWorkout == 1
        rowExerciseType(i) = "Running";
    elseif randomWorkout == 2
        rowExerciseType(i) = "Pushups";
    elseif randomWorkout == 3
        rowExerciseType(i) = "Squats";
    else 
        rowExerciseType(i) = "Cycling";
    end
end

rowPreWorkoutHR = randi([70,85],1,21); % 70-85 bmp
rowPostWorkoutHR = randi([120,150],1,21); % 120-150 bpm
rowDuration = randi([10,25],1,21); % 10-25 min
rowIntensity = randi([3,6],1,21); % 3-6 intensity

rowExerciseType(restDays) = "Rest";
rowPostWorkoutHR(restDays) = rowPreWorkoutHR(restDays);
rowDuration(restDays) = 0;
rowIntensity(restDays) = 0;

Days = rowDays'; % transpose row to column; Capitalized for Table format
PreWorkoutHR = rowPreWorkoutHR'; 
PostWorkoutHR = rowPostWorkoutHR';
ExerciseType = rowExerciseType'; 
Duration = rowDuration'; 
Intensity = rowIntensity';

athlete1 = table(Days, ExerciseType, PreWorkoutHR, PostWorkoutHR, Duration, Intensity);
writetable(athlete1, fullfile(folder, "athlete1_beginner.csv"))


%% ------------- Athlete 2 -------------
% PreWorkoutHR: 65-75 bpm
% PostWorkoutHR: 130-165 bpm
% Duration: 20-40 minutes
% Intensity: 5-8
% Pattern: More consistent (e.g., Mon/Wed/Fri/Sat schedule)
% Include 1-2 "Rest" days a week

Days = (1:21)';

restDays = (1:4:21); % regular rest days, every 4 days (twice a week)

ExerciseType = strings(1,21)';
for i = 1:21
    randomWorkout = randi([1,4]); % 4 workouts: "Running", "Pushups", "Squats", "Cycling"
    if randomWorkout == 1
        ExerciseType(i) = "Running";
    elseif randomWorkout == 2
        ExerciseType(i) = "Pushups";
    elseif randomWorkout == 3
        ExerciseType(i) = "Squats";
    else 
        ExerciseType(i) = "Cycling";
    end
end

PreWorkoutHR = randi([65,75],1,21)'; % 65-75 bmp
PostWorkoutHR = randi([130,165],1,21)'; % 130-165 bpm
Duration = randi([20,40],1,21)'; % 20-40 min
Intensity = randi([5,8],1,21)'; % 5-8 intensity

% Accounting for Rest Days
ExerciseType(restDays) = "Rest";
PostWorkoutHR(restDays) = PreWorkoutHR(restDays);
Duration(restDays) = 0;
Intensity(restDays) = 0;

athlete2 = table(Days, ExerciseType, PreWorkoutHR, PostWorkoutHR, Duration, Intensity);
writetable(athlete2, fullfile(folder, "athlete2_intermediate.csv"))


%% ------------- Athlete 3 -------------
% PreWorkoutHR: 55-65 bpm
% PostWorkoutHR: 145-180 bpm
% Duration: 30-60 minutes
% Intensity: 7-10
% Pattern: Very consistent (5-6 days per week)
% Include 1 "Rest" day

Days = (1:21)';

restDays = (7:7:21); % regular rest days, every 7 days (once a week)

ExerciseType = strings(1,21)'; % Random workouts
for i = 1:21
    randomWorkout = randi([1,4]); % 4 workouts: "Running", "Pushups", "Squats", "Cycling"
    if randomWorkout == 1
        ExerciseType(i) = "Running";
    elseif randomWorkout == 2
        ExerciseType(i) = "Pushups";
    elseif randomWorkout == 3
        ExerciseType(i) = "Squats";
    else 
        ExerciseType(i) = "Cycling";
    end
end

PreWorkoutHR = randi([55, 65],1,21)'; % 55-65 bmp
PostWorkoutHR = randi([145, 180],1,21)'; % 145-180 bpm
Duration = randi([30, 60], 1, 21)'; % 30-60 min
Intensity = randi([7, 10], 1, 21)'; % 7-10 intensity

% Accounting for Rest Days
ExerciseType(restDays) = "Rest";
PostWorkoutHR(restDays) = PreWorkoutHR(restDays);
Duration(restDays) = 0;
Intensity(restDays) = 0;

athlete3 = table(Days, ExerciseType, PreWorkoutHR, PostWorkoutHR, Duration, Intensity);
writetable(athlete3, fullfile(folder, "athlete3_advanced.csv"))


%% ------------- Athlete Profile .txt creation -------------
athleteProfile1 = "Athlete 1: Beginner - Just started fitness journey, irregular schedule";
athleteProfile2 = "Athlete 2: Intermediate - Consistent training, moderate intensity";
athleteProfile3 = "Athlete 3: Advanced - Highly trained, structured program";

athleteProfiles = [athleteProfile1; athleteProfile2; athleteProfile3];

writelines(athleteProfiles, fullfile(folder, "athlete_profiles.txt"))
