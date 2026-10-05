%PLOT_TASK_ALLOCATION_MOBILITY  Impact of the mobility model on the task-allocation reward.
%
%   Bar chart of the average task-allocation reward (LDF-DPTAA, Eq. (31)) for the NAC base
%   learner and lifelong learning (LL), with and without the PSO-CEMA mobility model
%   (cf. Fig. 7 of the paper, without the Q-learning baseline).
%
%   Data: data/results/main_runs (zeta = 5).
%   To plot your own runs, point RESULTS_DIR below to fullfile(repo_root(), 'outputs', 'results').
%
%   Produced by: online/run_online_base_learner.m and
%                online/run_online_base_learner_no_mobility.m

results_dir = fullfile(repo_root(), 'data', 'results', 'main_runs');

clear b;
% Result files (each holds a T-by-trajectory matrix of allocation losses)
dataNames = {
    'loss_for_allocation_base_5', 'loss_for_allocation_LL_5', 'loss_for_allocation_base_nopso', 'loss_for_allocation_LL_nopso'};

n = 2;

% Recalculate the size of the array for average values
avgValues = zeros(1, length(dataNames));

% Iterate through the data name array, load the data, and compute averages
for i = 1:length(dataNames)
    % Load the data (first variable stored in the .mat file)
    loadedData = load(fullfile(results_dir, [dataNames{i} '.mat']));
    fieldName = fieldnames(loadedData);
    data = loadedData.(fieldName{1});

    % Remove the 1st and 51st data points
    data([1, 51]) = [];

    % Calculate the mean
    avgValues(i) = mean(data);
end

zetaValues = ['With Mobility Model', 'Without Mobility Model'];

methods = {'Base', 'LL'};


% Plot the bar chart
figure;
hold on;

colors = [
    0.1, 0.2, 0.5;    % Dark blue
    0.97, 0.91, 0.56;  % Soft yellow
    0.2, 0.7, 0.3;    % Soft green
    0.9, 0.6, 0.2    % Soft orange
 ];

bar(1, avgValues(1), 'FaceColor', colors(1,:)); % Base
bar(2, avgValues(2), 'FaceColor', colors(2,:)); % LL
bar(3, avgValues(3), 'FaceColor', colors(3,:)); % Base-nopso
bar(4, avgValues(4), 'FaceColor', colors(4,:)); % LL-nopso


% Legend: correspondence between colors and labels
legendEntries = {'Base with Mobility', 'LL with Mobility' , 'Base without Mobility', 'LL without Mobility'};
colorsForLegend = [
    0.1, 0.2, 0.5;    % Dark blue
    0.97, 0.91, 0.56;  % Soft yellow
    0.2, 0.7, 0.3;    % Soft green
    0.9, 0.6, 0.2    % Soft orange
];


% Create a temporary array of bar chart objects to generate the legend
for i = 1:length(colorsForLegend)
    b(i) = bar(nan, 'FaceColor', colorsForLegend(i,:));
end

% Generate the legend
legend(b, legendEntries, 'Location', 'best');

hold off;

% Other settings
xlabel('Method');
ylabel('Average Reward');
title('The Impact of Mobility Model on Task Allocation');
set(gca, 'xtick', 1:4, 'xticklabel', [repmat(methods, 1, length(zetaValues))]);
set(gca, 'FontSize', 10);
grid on;
