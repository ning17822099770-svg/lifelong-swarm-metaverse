%PLOT_ZETA_PENALTY_TREND  Computing penalty of each environment versus zeta.
%
%   For every zeta in 0..n, loads mean_new_system_{base,LL}_<zeta>.mat and plots the average
%   computing penalty (-reward) of the five semantic environments and their mean, in one
%   figure for the base learner (Fig. 13(c)) and one for LL (Fig. 13(b)).
%
%   Data: data/results/zeta_sweep.
%   To plot your own runs, point RESULTS_DIR below to fullfile(repo_root(), 'outputs', 'results').
%
%   Produced by: online/sweep_zeta.m

results_dir = fullfile(repo_root(), 'data', 'results', 'zeta_sweep');

clear avgMatrixValuesBase avgMatrixValuesLL;

n = 30;  % zeta = 0..30 as in Fig. 13 of the paper
% Define the sequence of zeta values
zetaValuesNumeric = 0:n;

% Initialize arrays to store the average values of each matrix
avgMatrixValuesBase = zeros(n+1, 5); % n+1 zeta values, each corresponding to 5 environments
avgMatrixValuesLL = zeros(n+1, 5); % Same setup for LL

for zeta = 0:n
    % For Base data
    filenameBase = fullfile(results_dir, sprintf('mean_new_system_base_%d.mat', zeta));
    % For LL data
    filenameLL = fullfile(results_dir, sprintf('mean_new_system_LL_%d.mat', zeta));

    % Read Base data
    if isfile(filenameBase)
        loadedData = load(filenameBase);
        dataField = 'mean_new_system_base'; % Field name for Base files

        if isfield(loadedData, dataField)
            rewardData = loadedData.(dataField);

            for i = 1:5
                matrix = rewardData(i).reward;
                if ~isempty(matrix)
                    avgMatrixValuesBase(zeta + 1, i) = mean(matrix(:));
                else
                    avgMatrixValuesBase(zeta + 1, i) = NaN;
                end
            end
        end
    else
        disp([filenameBase, ' not found.']);
    end

    % Read LL data
    if isfile(filenameLL)
        loadedData = load(filenameLL);
        dataFieldLL = 'mean_new_system_LL'; % Field name for LL files

        if isfield(loadedData, dataFieldLL)
            rewardData = loadedData.(dataFieldLL);

            for i = 1:5
                matrix = rewardData(i).reward;
                if ~isempty(matrix)
                    avgMatrixValuesLL(zeta + 1, i) = mean(matrix(:));
                else
                    avgMatrixValuesLL(zeta + 1, i) = NaN;
                end
            end
        end
    else
        disp([filenameLL, ' not found.']);
    end
end

% The stored "reward" is the negative computing cost of Eq. (21); plot the penalty = -reward
penaltyBase = -avgMatrixValuesBase;
penaltyLL = -avgMatrixValuesLL;

markers = {'o', 's', '^', 'd', 'v'}; % Different markers (point styles)
colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250; 0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880]; % MATLAB predefined colors
lineWidth = 1.2; % Line width

% Fig. 13(c): base learner (solid lines), Fig. 13(b): LL (dashed lines)
methodNames = {'Base', 'LL'};
methodTitles = {'Changes of Average Penalty for Base Learner', 'Changes of Average Penalty for LL'};
penalties = {penaltyBase, penaltyLL};
lineStyles = {'-', '--'};

for m = 1:2
    figure; hold on;
    for i = 1:5
        plot(zetaValuesNumeric, penalties{m}(:, i), [lineStyles{m}, markers{i}], ...
            'DisplayName', sprintf('%s En %d', methodNames{m}, i), 'Color', colors(i,:), ...
            'LineWidth', lineWidth, 'MarkerSize', 8);
    end

    % Average over the five environments for each zeta
    averagePenalty = mean(penalties{m}, 2, 'omitnan');
    plot(zetaValuesNumeric, averagePenalty, [lineStyles{m}, 'k'], 'LineWidth', lineWidth + 0.5, ...
        'DisplayName', sprintf('%s Avg', methodNames{m}));

    legend('show', 'Location', 'southeast');
    title(methodTitles{m});
    xlabel('\zeta');
    ylabel('Average Penalty');
    grid on;
    hold off;
end
