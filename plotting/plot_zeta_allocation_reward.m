%PLOT_ZETA_ALLOCATION_REWARD  Task-allocation reward versus the buffer margin zeta (Fig. 13(a)).
%
%   For every zeta in 0..n, loads loss_for_allocation_{base,LL}_<zeta>.mat, averages the
%   allocation reward and plots it for the NAC base learner and lifelong learning (LL).
%
%   Data: data/results/zeta_sweep.
%   To plot your own runs, point RESULTS_DIR below to fullfile(repo_root(), 'outputs', 'results').
%
%   Produced by: online/sweep_zeta.m

results_dir = fullfile(repo_root(), 'data', 'results', 'zeta_sweep');

clear avgValuesLL;
clear avgValuesBase;

n = 25;

for zeta = 0:n
    filenameBase = fullfile(results_dir, sprintf('loss_for_allocation_base_%d.mat', zeta));
    filenameLL = fullfile(results_dir, sprintf('loss_for_allocation_LL_%d.mat', zeta));

    if isfile(filenameBase)
        disp(['Loading ', filenameBase]); % Debugging information
        loadedData = load(filenameBase);
        fieldName = fieldnames(loadedData);
        disp(['Field name: ', fieldName{1}]); % Display field name
        if ~isempty(fieldName)
            data = loadedData.(fieldName{1});
            data([1, 51]) = []; % Remove specific data points
            avgValuesBase(zeta + 1) = -mean(data);
        else
            disp(['No data in ', filenameBase]);
        end
    else
        disp([filenameBase, ' not found.']); % File not found
    end

    if isfile(filenameLL)
        disp(['Loading ', filenameLL]);
        loadedData = load(filenameLL);
        fieldName = fieldnames(loadedData);
        disp(['Field name: ', fieldName{1}]);
        if ~isempty(fieldName)
            data = loadedData.(fieldName{1});
            data([1, 51]) = []; % Same as above
            avgValuesLL(zeta + 1) = -mean(data);
        else
            disp(['No data in ', filenameLL]);
        end
    else
        disp([filenameLL, ' not found.']);
    end
end

% Array of zeta values
zetaValuesNumeric = 0:n;

% Plotting Base line graph
figure; % New figure window
plot(zetaValuesNumeric, avgValuesBase, '-o', 'DisplayName', 'Base');
hold on; % Keep the current figure to add LL data line graph on the same figure

% Plotting LL line graph
plot(zetaValuesNumeric, avgValuesLL, '-x', 'DisplayName', 'LL');

% Adding legend
legend('show');

% Adding title and axis labels
title('Loss for Allocation vs Zeta for Base and LL');
xlabel('Zeta');
ylabel('Average Loss');

% Displaying grid
grid on;
