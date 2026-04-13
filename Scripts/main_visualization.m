% MAIN_VISUALIZATION - Generates project plots and figures
%
% Team Members: [Your Name] (Visualization Specialist), [Teammate 1], [Teammate 2]
% Date: April 2026
%
% Description:
% Loads athlete fitness data, calculates necessary plotting variables, 
% and generates 5 appropriately formatted figures, saving them as PNGs.
%
% Inputs: athlete1_beginner.csv, athlete2_intermediate.csv, athlete3_advanced.csv
% Outputs: 5 PNG figures in Results/Figures/ directory

clear; clc; close all;

%% 1. Directory Setup
% Create output directories if they don't exist
if ~isfolder(fullfile('..', 'Results', 'Figures'))
    mkdir(fullfile('..', 'Results', 'Figures'));
end

%% 2. Load Data
% Note: Assuming script is run from inside the Scripts/ folder
try
    ath1 = readtable(fullfile('..', 'Data', 'Athletes', 'athlete1_beginner.csv'));
    ath2 = readtable(fullfile('..', 'Data', 'Athletes', 'athlete2_intermediate.csv'));
    ath3 = readtable(fullfile('..', 'Data', 'Athletes', 'athlete3_advanced.csv'));
catch
    % Fallback if files are in the same directory for testing
    ath1 = readtable('athlete1_beginner.csv');
    ath2 = readtable('athlete2_intermediate.csv');
    ath3 = readtable('athlete3_advanced.csv');
end

%% 3. Pre-Processing for Plots (Helper Calculations)
% Extract zones for Figure 1 (Resting <100, Light 100-130, Mod 130-160, Vig >160)
% We calculate the total duration spent in each zone per athlete
zones = zeros(3, 4); % 3 athletes, 4 zones
athletes = {ath1, ath2, ath3};

for i = 1:3
    data = athletes{i};
    % Zone 1: Resting (Duration on rest days is 0, so we count days * 0, but 
    % if they had active minutes < 100 HR, it goes here)
    zones(i,1) = sum(data.Duration(data.PostWorkoutHR < 100));
    % Zone 2: Light
    zones(i,2) = sum(data.Duration(data.PostWorkoutHR >= 100 & data.PostWorkoutHR < 130));
    % Zone 3: Moderate
    zones(i,3) = sum(data.Duration(data.PostWorkoutHR >= 130 & data.PostWorkoutHR <= 160));
    % Zone 4: Vigorous
    zones(i,4) = sum(data.Duration(data.PostWorkoutHR > 160));
end

%% 4. Plot 1: Heart Rate Zone Comparison (Grouped Bar Chart)
figure('Name', 'HR Zones', 'Position', [100, 100, 800, 500]);
bar(zones, 'grouped');
title('Total Time Spent in Heart Rate Zones per Athlete');
xlabel('Athlete Level');
ylabel('Total Time (minutes)');
set(gca, 'xticklabel', {'Beginner', 'Intermediate', 'Advanced'});
legend('Resting (<100)', 'Light (100-129)', 'Moderate (130-160)', 'Vigorous (>160)', 'Location', 'northwest');
grid on;
saveas(gcf, fullfile('..', 'Results', 'Figures', 'hr_zone_comparison.png'));

%% 5. Plot 2: Recovery Rate Analysis (Post - Pre Workout HR)
% Lower recovery rate (difference) means better fitness
rec1 = mean(ath1.PostWorkoutHR(ath1.Duration > 0) - ath1.PreWorkoutHR(ath1.Duration > 0));
rec2 = mean(ath2.PostWorkoutHR(ath2.Duration > 0) - ath2.PreWorkoutHR(ath2.Duration > 0));
rec3 = mean(ath3.PostWorkoutHR(ath3.Duration > 0) - ath3.PreWorkoutHR(ath3.Duration > 0));

figure('Name', 'Recovery Rate', 'Position', [150, 150, 600, 400]);
bar([rec1, rec2, rec3], 'FaceColor', [0.2 0.6 0.5]);
title('Average Heart Rate Increase During Workout (Recovery Rate)');
xlabel('Athlete Level');
ylabel('Average HR Increase (bpm)');
set(gca, 'xticklabel', {'Beginner', 'Intermediate', 'Advanced'});
grid on;
saveas(gcf, fullfile('..', 'Results', 'Figures', 'avg_recovery_rate.png'));

%% 6. Plot 3: Intensity Consistency (Standard Deviation)
% Lower standard deviation means more consistent training
std1 = std(ath1.Intensity(ath1.Duration > 0));
std2 = std(ath2.Intensity(ath2.Duration > 0));
std3 = std(ath3.Intensity(ath3.Duration > 0));

figure('Name', 'Intensity Consistency', 'Position', [200, 200, 600, 400]);
bar([std1, std2, std3], 'FaceColor', [0.8 0.4 0.3]);
title('Workout Intensity Consistency (Standard Deviation)');
xlabel('Athlete Level');
ylabel('Standard Deviation of Intensity');
set(gca, 'xticklabel', {'Beginner', 'Intermediate', 'Advanced'});
grid on;
saveas(gcf, fullfile('..', 'Results', 'Figures', 'intensity_consistency.png'));

%% 7. Plot 4: Workout Duration vs. Post-Workout HR (Scatter Plot)
figure('Name', 'Duration vs HR', 'Position', [250, 250, 700, 500]);
hold on;
scatter(ath1.Duration(ath1.Duration>0), ath1.PostWorkoutHR(ath1.Duration>0), 100, 'b', 'filled', 'MarkerEdgeColor', 'k');
scatter(ath2.Duration(ath2.Duration>0), ath2.PostWorkoutHR(ath2.Duration>0), 100, 'g', 'filled', 'MarkerEdgeColor', 'k');
scatter(ath3.Duration(ath3.Duration>0), ath3.PostWorkoutHR(ath3.Duration>0), 100, 'r', 'filled', 'MarkerEdgeColor', 'k');
hold off;
title('Workout Duration vs. Post-Workout Heart Rate');
xlabel('Duration (minutes)');
ylabel('Post-Workout HR (bpm)');
legend('Beginner', 'Intermediate', 'Advanced', 'Location', 'best');
grid on;
saveas(gcf, fullfile('..', 'Results', 'Figures', 'duration_vs_hr_scatter.png'));

%% 8. Plot 5: 21-Day Heart Rate Trends
figure('Name', '21 Day Trend', 'Position', [300, 300, 800, 400]);
hold on;
plot(ath1.Days, ath1.PostWorkoutHR, '-ob', 'LineWidth', 1.5);
plot(ath2.Days, ath2.PostWorkoutHR, '-sg', 'LineWidth', 1.5);
plot(ath3.Days, ath3.PostWorkoutHR, '-^r', 'LineWidth', 1.5);
hold off;
title('Post-Workout Heart Rate Trends Over 21 Days');
xlabel('Day');
ylabel('Heart Rate (bpm)');
legend('Beginner', 'Intermediate', 'Advanced', 'Location', 'best');
grid on;
saveas(gcf, fullfile('..', 'Results', 'Figures', '21_day_hr_trend.png'));

disp('All 5 figures successfully generated and saved to Results/Figures/');

%new version