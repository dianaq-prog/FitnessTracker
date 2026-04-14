% Main_Analysis - Fitness Tracker Heart Rate & Workout Analysis
%
% Team Members: [Kareemat Adeagbo] - Algorithm Developer
%               [Retal Sabbahi] - Data Manager
%               [Diana Quach] - Visualization Specialist
% Date: April 14, 2026
%
% Description:
% This script loads workout data for three athletes (Beginner,
% Intermediate, and Advanced), categorizes workouts into heart rate zones,
% calculates time in each zone, computes recovery rates, generates summary
% statistics, and exports results to CSV and .mat formats for further use.
%
% Inputs:
%   Data/Athletes/athlete1_beginner.csv
%   Data/Athletes/athlete2_intermediate.csv
%   Data/Athletes/athlete3_advanced.csv
%
% Outputs:
%   Results/summary_statistics.csv  - Summary table of key metrics
%   Results/analysis_results.mat    - Full workspace save

%% ------------------- Setup -------------------
clear; clc; close all;

% Create output directories if they don't exist
folder = fullfile('..', 'Results');
if ~isfolder(folder)
    mkdir(folder);
end
figureFolder = fullfile('..', 'Results', 'Figures');
if ~isfolder(figureFolder)
    mkdir(figureFolder);
end

%% ============= Task 1: Load Data =============
% Build file paths using fullfile for cross-platform compatibility
file1 = fullfile('..', 'Data', 'Athletes', 'athlete1_beginner.csv');
file2 = fullfile('..', 'Data', 'Athletes', 'athlete2_intermediate.csv');
file3 = fullfile('..', 'Data', 'Athletes', 'athlete3_advanced.csv');

% Check files exist before loading
if ~isfile(file1) || ~isfile(file2) || ~isfile(file3)
    error('One or more athlete CSV files not found. Check Data/Athletes/ directory.');
end

% Load each athlete's data as a table (preserves column names)
athlete1 = readtable(file1);
athlete2 = readtable(file2);
athlete3 = readtable(file3);

% Verify data loaded correctly
fprintf('=== Data Load Verification ===\n');
fprintf('Athlete 1 (Beginner):     %d rows, %d columns\n', size(athlete1,1), size(athlete1,2));
fprintf('Athlete 2 (Intermediate): %d rows, %d columns\n', size(athlete2,1), size(athlete2,2));
fprintf('Athlete 3 (Advanced):     %d rows, %d columns\n\n', size(athlete3,1), size(athlete3,2));

% Store all athletes in a cell array for easier looping later
athletes     = {athlete1, athlete2, athlete3};
athleteNames = {'Beginner', 'Intermediate', 'Advanced'};

%% ======= Task 2: Heart Rate Zone Categorization =========
% Zones defined by PostWorkoutHR:
%   Resting:  < 100 bpm  (rest days)
%   Light:    100-130 bpm
%   Moderate: 131-160 bpm
%   Vigorous: > 160 bpm

% Pre-allocate a cell array to hold zone labels for each athlete
allZones = cell(3, 1);

for a = 1:3
    data  = athletes{a};
    n     = height(data);
    zones = strings(n, 1); % column of zone labels

    for i = 1:n
        hr = data.PostWorkoutHR(i);
        if data.Duration(i) == 0
            % Rest day: Duration = 0, no HR elevation occurred.
            % PostWorkoutHR is set equal to PreWorkoutHR in the source
            % data, but we detect rest days via Duration == 0 (not the HR value).
            zones(i) = "Resting";
        elseif hr <= 130
            zones(i) = "Light";
        elseif hr <= 160
            zones(i) = "Moderate";
        else
            zones(i) = "Vigorous";
        end
    end

    allZones{a} = zones;
    fprintf('Athlete %d (%s) zones assigned.\n', a, athleteNames{a});
end
fprintf('\n');

%% ======== Task 3: Time in Each Zone ========
% Use logical indexing to sum Duration for each zone per athlete.
%
% NOTE on Resting zone:
%   Rest days have Duration = 0 by definition (no workout performed),
%   so time in Resting zone is correctly 0 minutes for all athletes.
%   This is intentional — rest is the absence of workout time, not a
%   workout category with measurable duration.

zoneNames = {'Resting', 'Light', 'Moderate', 'Vigorous'};

% Results matrix: rows = athletes, cols = zones
timeInZone = zeros(3, 4);

for a = 1:3
    data  = athletes{a};
    zones = allZones{a};

    for z = 1:4
        inZone           = zones == zoneNames{z};       % logical index
        timeInZone(a, z) = sum(data.Duration(inZone));  % total minutes
    end
end

% Display results table
fprintf('=== Time in Each HR Zone (minutes) ===\n');
fprintf('%-15s %8s %8s %10s %9s\n', 'Athlete', 'Resting', 'Light', 'Moderate', 'Vigorous');
fprintf('%s\n', repmat('-', 1, 54));
for a = 1:3
    fprintf('%-15s %8.0f %8.0f %10.0f %9.0f\n', ...
        athleteNames{a}, timeInZone(a,1), timeInZone(a,2), ...
        timeInZone(a,3), timeInZone(a,4));
end
fprintf('  * Resting = 0 min by design: rest days have no workout duration.\n\n');

%% ==== Task 4: Recovery Rate ===========
% Recovery rate = mean(PostWorkoutHR - PreWorkoutHR) on non-rest days
% Lower recovery rate indicates better cardiovascular efficiency

recoveryRate = zeros(1, 3);

for a = 1:3
    data       = athletes{a};
    isWorkout  = data.Duration > 0;                           % exclude rest days
    hrIncrease = data.PostWorkoutHR(isWorkout) - data.PreWorkoutHR(isWorkout);
    recoveryRate(a) = mean(hrIncrease);
end

fprintf('=== Mean Recovery Rate (bpm increase) ===\n');
for a = 1:3
    fprintf('  %s: %.2f bpm\n', athleteNames{a}, recoveryRate(a));
end
fprintf('\n');

%% ================ Task 5: Basic Statistics ================
% For each athlete (excluding rest days):
%   - Mean PostWorkoutHR
%   - Mean Duration
%   - Std of Intensity (consistency; lower = more consistent)
%   - Total workouts completed

meanPostHR    = zeros(1, 3);
meanDuration  = zeros(1, 3);
stdIntensity  = zeros(1, 3);
totalWorkouts = zeros(1, 3);
totalMinutes  = zeros(1, 3);  % kept as row vector — do NOT transpose here
meanIntensity = zeros(1, 3);

for a = 1:3
    data      = athletes{a};
    isWorkout = data.Duration > 0; % logical mask for non-rest days

    meanPostHR(a)    = mean(data.PostWorkoutHR(isWorkout));
    meanDuration(a)  = mean(data.Duration(isWorkout));
    stdIntensity(a)  = std(data.Intensity(isWorkout));
    totalWorkouts(a) = sum(isWorkout);
    totalMinutes(a)  = sum(data.Duration(isWorkout));
    meanIntensity(a) = mean(data.Intensity(isWorkout));
end

fprintf('=== Basic Statistics (workout days only) ===\n');
fprintf('%-15s %12s %13s %14s %10s\n', ...
    'Athlete', 'AvgPostHR', 'AvgDuration', 'Consistency', 'Workouts');
fprintf('%s\n', repmat('-', 1, 66));
for a = 1:3
    fprintf('%-15s %12.2f %13.2f %14.2f %10.0f\n', ...
        athleteNames{a}, meanPostHR(a), meanDuration(a), stdIntensity(a), totalWorkouts(a));
end
fprintf('\n');

%% ====== Comparative Analysis Answers ========
fprintf('=== Comparative Analysis ===\n');

% Q1: Which athlete spent the most time in the vigorous zone?
[~, maxVigIdx] = max(timeInZone(:, 4));
fprintf('1. Most time in Vigorous zone: %s (%d min)\n', ...
    athleteNames{maxVigIdx}, round(timeInZone(maxVigIdx, 4)));

% Q2: Most consistent training (lowest std of intensity)
[~, mostConsistIdx] = min(stdIntensity);
fprintf('2. Most consistent training:   %s (std = %.1f)\n', ...
    athleteNames{mostConsistIdx}, stdIntensity(mostConsistIdx));

% Q3: Best cardiovascular efficiency (lowest mean recovery rate)
[~, bestCardioIdx] = min(recoveryRate);
fprintf('3. Best cardiovascular efficiency: %s (%d bpm avg increase)\n', ...
    athleteNames{bestCardioIdx}, round(recoveryRate(bestCardioIdx)));

% Q4: Workout pattern summary
fprintf('4. Workout patterns by fitness level:\n');
for a = 1:3
    fprintf('   %s: %d workouts over 21 days, avg %d min, avg intensity %.1f\n', ...
        athleteNames{a}, totalWorkouts(a), round(meanDuration(a)), meanIntensity(a));
end
fprintf('\n');

%% ============ Task 6: Save Results ========================

% Build summary table
% NOTE: transpose totalMinutes into a new variable TotalMinutes for the
% table only — totalMinutes stays a row vector so the extension works
AthleteLevel = athleteNames';
AvgHeartRate = round(meanPostHR', 2);
TotalMinutes = totalMinutes';          % column for table — does NOT overwrite totalMinutes
Consistency  = round(stdIntensity', 2);

summaryTable = table(AthleteLevel, AvgHeartRate, TotalMinutes, Consistency);

% Export summary table to CSV
csvOut = fullfile('..', 'Results', 'summary_statistics.csv');
writetable(summaryTable, csvOut);
fprintf('Summary table saved to: %s\n', csvOut);

% Save full workspace to .mat file
matOut = fullfile('..', 'Results', 'analysis_results.mat');
save(matOut);
fprintf('Workspace saved to:     %s\n\n', matOut);

fprintf('=== Analysis complete. Ready for visualization. ===\n\n');

%% ==== Extension: Option C - Simple Fitness Score =====
% Compute a single 0-100 fitness score per athlete using four metrics:
%   (1) Total workout time     -> higher is better (normalize directly)
%   (2) Average intensity      -> higher is better (normalize directly)
%   (3) Consistency            -> lower std is better (normalize inversely)
%   (4) Recovery efficiency    -> lower HR increase is better (normalize inversely)
%
% All four metrics weighted equally (25% each).
% Normalization:
%   Direct:  score = (value - min) / (max - min) * 100
%   Inverse: score = (max - value) / (max - min) * 100
% If all athletes tie on a metric, that metric defaults to 50 for everyone.

% Helper: safe normalize (direct) — higher raw value = higher score
normalizeDir = @(v) deal( ...
    (max(v) - min(v)) < 1e-9, ...
    (v - min(v)) ./ max(max(v) - min(v), 1e-9) * 100);

% Helper: safe normalize (inverse) — lower raw value = higher score
normalizeInv = @(v) deal( ...
    (max(v) - min(v)) < 1e-9, ...
    (max(v) - v) ./ max(max(v) - min(v), 1e-9) * 100);

% (1) Total workout time — uses totalMinutes row vector (never transposed)
[eqFlag, scoreTime] = normalizeDir(totalMinutes);
if eqFlag, scoreTime = ones(1,3) * 50; end

% (2) Average intensity
[eqFlag, scoreIntensity] = normalizeDir(meanIntensity);
if eqFlag, scoreIntensity = ones(1,3) * 50; end

% (3) Consistency — lower std = more consistent = fitter
[eqFlag, scoreConsistency] = normalizeInv(stdIntensity);
if eqFlag, scoreConsistency = ones(1,3) * 50; end

% (4) Recovery efficiency — lower HR increase = better cardio = fitter
[eqFlag, scoreRecovery] = normalizeInv(recoveryRate);
if eqFlag, scoreRecovery = ones(1,3) * 50; end

% Combine with equal weighting (25% each)
weights = [0.25, 0.25, 0.25, 0.25]; % must sum to 1

compositeScore = weights(1) * scoreTime        + ...
                 weights(2) * scoreIntensity   + ...
                 weights(3) * scoreConsistency + ...
                 weights(4) * scoreRecovery;

% Display detailed breakdown
fprintf('=== Extension: Composite Fitness Score (0-100) ===\n');
fprintf('%-15s %10s %11s %13s %12s | %10s\n', ...
    'Athlete', 'WorkTime', 'Intensity', 'Consistency', 'Recovery', 'TOTAL');
fprintf('%s\n', repmat('-', 1, 76));
for a = 1:3
    fprintf('%-15s %10.1f %11.1f %13.1f %12.1f | %10.1f\n', ...
        athleteNames{a}, ...
        scoreTime(a), scoreIntensity(a), scoreConsistency(a), scoreRecovery(a), ...
        compositeScore(a));
end

% Identify winner
[topScore, topIdx] = max(compositeScore);
fprintf('\nTop composite fitness score: %s (%.1f / 100)\n\n', ...
    athleteNames{topIdx}, topScore);

% Add composite scores to summary table and re-save
% NOTE: compositeScore is never recalculated after this point
CompositeScore = round(compositeScore', 1);
summaryTable.CompositeScore = CompositeScore;
writetable(summaryTable, csvOut);
fprintf('Updated summary table (with composite scores) saved to: %s\n', csvOut);

% Re-save workspace with composite score variables included
save(matOut);
fprintf('Workspace re-saved to: %s\n', matOut);