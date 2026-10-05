%PLOT_ZETA_PENALTY_PER_ENV  Computing penalty per environment for different zeta values.
%
%   For each of the five semantic environments, draws a bar chart of the average computing
%   penalty of the NAC base learner and lifelong learning (LL) for zeta in {0,5,...,25}, plus
%   the "fair" (equal-split) allocation baseline; then draws the average over all
%   environments (cf. Fig. 13(b)-(c) of the paper).
%
%   Data: data/results/zeta_sweep_full.
%   To plot your own runs, point RESULTS_DIR below to fullfile(repo_root(), 'outputs', 'results').
%
%   Produced by: online/sweep_zeta.m and online/run_online_base_learner_fair_alloc.m

results_dir = fullfile(repo_root(), 'data', 'results', 'zeta_sweep_full');

% Result files to compare (base / LL pairs)
dataNames = {
    'mean_new_system_base_fair', 'mean_new_system_LL_fair', ...
    'mean_new_system_base_0', 'mean_new_system_LL_0', ...
    'mean_new_system_base_5', 'mean_new_system_LL_5', ...
    'mean_new_system_base_10', 'mean_new_system_LL_10', ...
    'mean_new_system_base_15', 'mean_new_system_LL_15', ...
    'mean_new_system_base_20', 'mean_new_system_LL_20', ...
    'mean_new_system_base_25', 'mean_new_system_LL_25'
};

% This array directly corresponds to the data names for color mapping
zetaValues = {'Fair', '0', '5', '10', '15', '20', '25'};

% x-tick labels of the per-environment charts
methods = {'Base', 'LL'};

% Loop over environments
for env = 1:5
    figure;
    hold on;

    % Initialize a variable for legend handles
    legendHandles = zeros(1, length(zetaValues));

    % Generate a distinct color for each zeta value
    colors = lines(length(zetaValues)); % Adjust this if you have more zeta values

    % Process each .mat file for the current environment
    for i = 1:length(dataNames)
        % Load the .mat file
        loadedData = load(fullfile(results_dir, [dataNames{i} '.mat']));

        % Dynamically find the correct field name that contains your data
        fieldNames = fieldnames(loadedData);
        fieldName = ''; % Initialize fieldName as empty
        for j = 1:length(fieldNames)
            if ~ismember(fieldNames{j}, {'__header__', '__version__', '__globals__'})
                fieldName = fieldNames{j};
                break;
            end
        end

        if ~isempty(fieldName) && isfield(loadedData.(fieldName), 'reward')
            data = loadedData.(fieldName)(env).reward;
            avgValues(i, env) = -mean(data(:));
        else
            disp(['No valid data field found in ', dataNames{i}]);
            avgValues(i, env) = NaN; % Assign NaN for files where no valid field was identified
        end

        % Extract method and zeta from dataNames using regexp
        tokens = regexp(dataNames{i}, 'mean_new_system_(base|LL)_(fair|\d+)', 'tokens');
        if ~isempty(tokens) && iscell(tokens{1})
            tokens = tokens{1}; % Extract the first match group
            method = tokens{1}; % 'base' or 'LL'
            zeta = tokens{2}; % 'fair' or a number like '0', '5', etc.
        else
            disp(['Failed to parse method and zeta from ', dataNames{i}]);
            continue; % Skip to the next iteration if we can't parse the filename
        end

        % Determine color index
        colorIndex = find(strcmp(zetaValues, zeta));

        if isempty(colorIndex)
            colorIndex = 1; % Default to the first color if not found
        end

        % Only add to legend if it's the first instance of this zeta value
        if legendHandles(colorIndex) == 0
            % Draw the bar and save the handle for the legend
            legendHandles(colorIndex) = bar(i, avgValues(i, env), 'FaceColor', colors(colorIndex,:));
        else
            % Draw the bar without saving the handle
            bar(i, avgValues(i, env), 'FaceColor', colors(colorIndex,:));
        end
    end

    % Customize the plot as needed
    xlabel('Method and \zeta Value');
    ylabel('Average Value (Negative)');
    title(sprintf('The impact of \\zeta on computing in Environment %d', env));
    set(gca, 'xtick', 1:2*(length(zetaValues)), 'xticklabel', ['Base', 'LL', repmat(methods, 1, length(zetaValues))]);
    set(gca, 'FontSize', 10);

    % Create legend entries based on zetaValues
    % Filter out zeros from legendHandles before creating the legend
    validHandles = legendHandles(legendHandles ~= 0);
    validZetaValues = zetaValues(legendHandles ~= 0);
    legendLabels = cellfun(@(x) sprintf('\\zeta=%s', x), validZetaValues, 'UniformOutput', false);
    legend(validHandles, legendLabels, 'Location', 'best', 'Interpreter', 'tex');

    hold off;
end


% Generate a distinct color for each zeta value
colors = lines(length(zetaValues));

% Initialize arrays for overall average values
overallAvgValues = zeros(1, length(dataNames));
methods = cell(1, length(dataNames)); % To store 'base' or 'LL' for x-tick labels

figure;
hold on;

% Initialize a variable for legend handles and labels
legendHandles = [];
legendLabels = {};

% Process each .mat file to calculate overall average
for i = 1:length(dataNames)
    sumAvgValues = 0;

    % Load the .mat file
    loadedData = load(fullfile(results_dir, [dataNames{i} '.mat']));

    % Dynamically find the correct field name that contains your data
    fieldNames = fieldnames(loadedData);
    fieldName = '';
    for j = 1:length(fieldNames)
        if ~ismember(fieldNames{j}, {'__header__', '__version__', '__globals__'})
            fieldName = fieldNames{j};
            break;
        end
    end

    if ~isempty(fieldName) && isfield(loadedData.(fieldName), 'reward')
        % Calculate the average across all environments
        for env = 1:5
            data = loadedData.(fieldName)(env).reward;
            sumAvgValues = sumAvgValues + -mean(data(:));
        end
        overallAvgValues(i) = sumAvgValues / 5;
    else
        disp(['No valid data field found in ', dataNames{i}]);
    end

    % Extract method and zeta from dataNames using regexp for x-tick labels
    tokens = regexp(dataNames{i}, 'mean_new_system_(base|LL)_(fair|\d+)', 'tokens');
    if ~isempty(tokens) && iscell(tokens{1})
        tokens = tokens{1};
        method = tokens{1}; % 'base' or 'LL'
        zeta = tokens{2}; % 'fair' or a number like '0', '5', etc.
        methods{i} = method;
    else
        disp(['Failed to parse method and zeta from ', dataNames{i}]);
    end

    % Determine color index
    colorIndex = find(strcmp(zetaValues, zeta));
    if isempty(colorIndex)
        colorIndex = 1; % Default to the first color if not found
    end

    % Draw the bar with specific color
    barHandle = bar(i, overallAvgValues(i), 'FaceColor', colors(colorIndex,:));

    % Only add to legend if it's the first instance of this zeta value
    if ~any(strcmp(legendLabels, sprintf('\\zeta=%s', zeta)))
        legendHandles(end+1) = barHandle;
        legendLabels{end+1} = sprintf('\\zeta=%s', zeta);
    end
end

% Customize the plot as needed
xlabel('Method and \zeta Value');
ylabel('Overall Average Value (Negative)');
title('Overall Impact of \zeta Across All Environments');
set(gca, 'xtick', 1:2*(length(zetaValues)), 'xticklabel', ['Base', 'LL', repmat(methods, 1, length(zetaValues))]);
set(gca, 'FontSize', 10);

% Create legend using the handles and labels prepared earlier
legend(legendHandles, legendLabels, 'Location', 'best', 'Interpreter', 'tex');

hold off;
