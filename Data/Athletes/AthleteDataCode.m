% ------------- Athlete 1 -------------
% PreWorkoutHR: 70-85 bpm (higher resting heart rate)
% PostWorkoutHR: 120-150 bpm (moderate elevation)
% Duration: 10-25 minutes (shorter workouts)
% Intensity: 3-6 (lower intensity)
% Pattern: Irregular schedule (e.g., workout on days 1, 3, 5, 8, 10, 12, 15, 17, 20)
% Include 2-3 "Rest" days where Duration=0 and PreWorkoutHR=PostWorkoutHR

rng(1); % sets the seed

restDay1 = randi([1,21]);
restDay2 = randi([1,21]);
while restDay2 == restDay1 % ensures unique and random rest days
    restDay2 = randi([1,21]);
end
restDay3 = randi([1,21]);
while restDay3 == restDay1 || restDay3 == restDay2
    restDay3 = randi([1,21]);
end
restDays = [restDay1, restDay2, restDay3];

rowDays = 1:21;

rowExerciseType = strings(1,21);
for i = 1:21
    randomWorkout = randi([1,4]); % 4 types of workouts: "Running", "Pushups", "Squats", "Cycling"
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

Days = rowDays'; %transpose row to column
PreWorkoutHR = rowPreWorkoutHR'; 
PostWorkoutHR = rowPostWorkoutHR';
ExerciseType = rowExerciseType'; 
Duration = rowDuration'; 
Intensity = rowIntensity';

athlete1 = table(Days, ExerciseType, PreWorkoutHR, PostWorkoutHR, Duration, Intensity);
writetable(athlete1, "athlete1.csv")
open("athlete1.csv")

% ------------- Athlete 2 -------------
% PreWorkoutHR: 65-75 bpm
% PostWorkoutHR: 130-165 bpm
% Duration: 20-40 minutes
% Intensity: 5-8
% Pattern: More consistent (e.g., Mon/Wed/Fri/Sat schedule)
% Include 1-2 "Rest" days

Days = (1:21);
restDays = (8:8:21); % regular rest days, every 8 days
