%COMPARE_ONLINE_RESULTS  Compare base learner and LL on the UAV servers (Figs. 9-12).
%
%   Uses the workspace left by RUN_ONLINE_BASE_LEARNER / RUN_ONLINE_LIFELONG
%   (mean_new_system_base, mean_new_system_LL, loss_for_allocation_*, Dealta_max). For each
%   of the five server types/environments it plots the penalty, the average task lifespan
%   against the required latency, the scaled energy cost (right axis: number of tasks) and the
%   queue length. It also plots the task-allocation reward and the PSO mobility reward.

% Define field names
fields = {'reward', 'Averagelifespan', 'ScaledEC', 'queue_length'};


% fields = {'reward'};
% fields = {'Averagelifespan'};
% fields = {'ScaledEC'};
% fields = {'queue_length'};




% Define different denominators
denominators = [2.5*1e9, 1.75*1e9, 2*1e9, 2.25*1e9, 1.5*1e9];

% save('mean_new_system_base.mat', 'mean_new_system_base');
% save('mean_new_system_LL.mat', 'mean_new_system_LL');

% save('mean_new_system_random.mat', 'mean_new_system_random');


% For each field
for i = 1:length(fields)
    % Create a new figure window
    h = figure;

    if strcmp(fields{i}, 'reward')

        % Set the figure title
        sgtitle(['Comparison of ', 'penalty']);

    elseif strcmp(fields{i}, 'queue_length')

        % Set the figure title
        sgtitle(['Comparison of ', 'queue length']);

    else

        % Set the figure title
        sgtitle(['Comparison of ' fields{i}]);

    end

    % For each category
    for j = 1:5
        % Select the j-th position in a 2x3 subplot
        subplot(2, 3, j);

        % Extract data for the j-th category from the struct array
        data1 = mean_new_system_base(j).(fields{i});
        data2 = mean_new_system_LL(j).(fields{i});
        % data3 = mean_new_system_random(j).(fields{i}); % New data added

        % Calculate the mean of data1 and data2
        meanData1(j) = mean(data1);
        meanData2(j) = mean(data2);

        
        if strcmp(fields{i}, 'reward')
            data1 = -data1;
            data2 = -data2;
            % Calculate the mean of data1 and data2
            meanData1(j) = mean(data1);
            meanData2(j) = mean(data2);
            % Plot the data from mean_new_system_base
            plot(data1, 'b', 'LineWidth', 2);
            hold on; % Maintain the current plot to overlay the next data on the same subplot

            % Plot the data from mean_new_system_LL
            plot(data2, 'r', 'LineWidth', 2);

            % Plot the data from mean_new_system_random using deep yellow color
            % plot(data3, 'Color', [0.9, 0.7, 0.0], 'LineWidth', 2);


            % Plot the mean lines for data1 and data2
            plot(xlim, [meanData1(j) meanData1(j)], '--', 'Color', [1, 0.5, 0], 'LineWidth', 3); % Mean of data1, orange dashed line
            plot(xlim, [meanData2(j) meanData2(j)], '--', 'Color', 'k', 'LineWidth', 3); % Mean of data2, cyan dashed line
            % Add legends
            legend('base', 'LL', 'Mean base', 'Mean LL');


            % Add subplot title
            title(['Environment ' num2str(j)]);

            % Add axis labels
            xlabel('Trajectory id');
            if strcmp(fields{i}, 'reward')

                ylabel('penalty');

            else

                ylabel(fields{i});

            end
            % Release the hold state
            hold off;



        elseif strcmp(fields{i}, 'Averagelifespan')
            data4 = Dealta_max(:, j);

            % Plot the data from mean_new_system_base
            plot(data1, 'b', 'LineWidth', 2);
            hold on; % Maintain the current plot to overlay the next data on the same subplot

            % Plot the data from mean_new_system_LL
            plot(data2, 'r', 'LineWidth', 2);

            % Plot the data from the newly added mean_new_system_random using deep yellow color
            % plot(data3, 'Color', [0.9, 0.7, 0.0], 'LineWidth', 2);


            plot(data4, 'LineWidth', 2);


            % Plot the mean lines for data1 and data2
            plot(xlim, [meanData1(j) meanData1(j)], '--', 'Color', [1, 0.5, 0], 'LineWidth', 3); % Mean of data1, orange dashed line
            plot(xlim, [meanData2(j) meanData2(j)], '--', 'Color', 'k', 'LineWidth', 3); % Mean of data2, cyan dashed line

            % Add legends
            legend('base', 'LL', 'required latency', 'Mean base', 'Mean LL');

            % Add subplot title
            title(['Environment ' num2str(j)]);


        elseif strcmp(fields{i}, 'ScaledEC')
            % Plot the data from mean_new_system_base
            yyaxis left; % Switch to left Y-axis
            plot(data1, 'b', 'LineStyle', '-', 'LineWidth', 2);
            hold on; % Maintain the current plot to overlay the next data on the same subplot

            % Plot the data from mean_new_system_LL
            plot(data2, 'r', 'LineStyle', '-', 'LineWidth', 2);

            % Plot the newly added data from mean_new_system_random
            % plot(data3, 'Color', [0.9, 0.7, 0.0], 'LineStyle', '-', 'LineWidth', 2); % Use deep yellow solid line

            % Plot the mean lines for data1 and data2
            plot(xlim, [meanData1(j) meanData1(j)], '--', 'Color', [1, 0.5, 0], 'LineWidth', 3); % Mean of data1, orange dashed line
            plot(xlim, [meanData2(j) meanData2(j)], '--', 'Color', 'k', 'LineWidth', 3); % Mean of data2, cyan dashed line


            % Set the left Y-axis label
            ylabel('ScaledEC');
            set(gca, 'YColor', 'k'); % 'k' represents black

            % Apply a transformation formula to each data point on the left Y-axis to compute the corresponding points on the right Y-axis
            % Assuming data1, data2, and data3 are the data points on the Y-axis that need to be transformed
            % Transform the values of data1
            transformedData1 = nthroot(data1 ./ (1e-27 * 3e-6), 3) ./ denominators(j);
            % Transform the values of data2
            transformedData2 = nthroot(data2 ./ (1e-27 * 3e-6), 3) ./ denominators(j);
            % Transform the values of data3
            % transformedData3 = nthroot(data3 ./ (1e-27 * 3e-6), 3) ./ denominators(j);

            % Activate the right Y-axis
            yyaxis right;

            % Plot the transformed data points, set as transparent and not shown in the legend
            scatter(1:length(transformedData1), transformedData1, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'none');
            scatter(1:length(transformedData2), transformedData2, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'none');
            % scatter(1:length(transformedData3), transformedData3, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'none');

            % Set the right Y-axis label
            ylabel('Number of tasks');
            set(gca, 'YColor', 'k'); % 'k' represents black

            % Set the legend, showing only the data on the left Y-axis
            legend({'base', 'LL', 'Mean base', 'Mean LL'});

            % Add subplot title
            title(['Environment ' num2str(j)]);

            % Release the hold state
            hold off;

        else

            % Plot the data from mean_new_system_base
            plot(data1, 'b', 'LineWidth', 2);
            hold on; % Maintain the current plot to overlay the next data on the same subplot

            % Plot the data from mean_new_system_LL
            plot(data2, 'r', 'LineWidth', 2);

            % Plot the data from mean_new_system_random using deep yellow color
            % plot(data3, 'Color', [0.9, 0.7, 0.0], 'LineWidth', 2);


            % Plot the mean lines for data1 and data2
            plot(xlim, [meanData1(j) meanData1(j)], '--', 'Color', [1, 0.5, 0], 'LineWidth', 3); % Mean of data1, orange dashed line
            plot(xlim, [meanData2(j) meanData2(j)], '--', 'Color', 'k', 'LineWidth', 3); % Mean of data2, cyan dashed line
            % Add legends
            legend('base', 'LL', 'Mean base', 'Mean LL');


            % Add subplot title
            title(['Environment ' num2str(j)]);

            % Add axis labels
            xlabel('Trajectory id');
            if strcmp(fields{i}, 'queue_length')

                ylabel('queue length');

            else

                ylabel(fields{i});

            end
            % Release the hold state
            hold off;

        end

        % % Save the figure as a PNG file, including the field name in the filename
        % filename = sprintf('comparison_%s.png', fields{i});
        % saveas(h, filename);
    end
end

% Assume there are two matrices: loss_for_allocation_base and loss_for_allocation_compare

% Calculate the row-wise averages of the first matrix
row_averages_base = - mean(loss_for_allocation_base, 2);

% Calculate the row-wise averages of the second matrix
row_averages_LL = - mean(loss_for_allocation_LL, 2);

% Calculate the row-wise averages of the third matrix
% row_averages_initial = - mean(loss_for_allocation_initial, 2);
% row_averages_random = - mean(loss_for_allocation_random, 2);

% Create a new figure window
figure;

% Plot the row-wise averages of the first matrix
plot(row_averages_base, 'b'); % 'b' specifies blue color
hold on; % Maintain the current plot to overlay more data on top
% Plot the row-wise averages of the second matrix
plot(row_averages_LL, 'r'); % 'r' specifies red color
hold on;

% plot(row_averages_random, 'Color', [0.4660, 0.6740, 0.1880]);

% Add legend
% legend('Base', 'LL', 'random policy');
legend('base', 'LL');

% Set title and axis labels
title('Average reward of task allocation');
xlabel('Trajectory');
ylabel('Average value');

% 
% 
% % % Assume the figure window number is 1
% % saveas(1, 'comparison reward.png');
% 


% Mobility reward of PSO-CEMA (Fig. 5). The exhaustive-search curve is only available when
% exhaustive_search_mobility is enabled in run_online_base_learner.m (commented out by default).
if exist('loss_for_UAV_moving_PSO', 'var')
    % Create a figure
    figure;

    if exist('loss_for_UAV_moving_exathustive_search', 'var')
        plot(loss_for_UAV_moving_exathustive_search, 'LineWidth', 2);
        hold on;
        plot(loss_for_UAV_moving_PSO, 'LineWidth', 2);
        legend('Exhaustive Search', 'PSO');
    else
        plot(loss_for_UAV_moving_PSO, 'LineWidth', 2);
        legend('PSO');
    end

    % Add title and axis labels
    title('Average Reward for UAV Moving');
    xlabel('Trajectory Index');
    ylabel('Reward Value');

    % Optional: Add grid lines
    grid on;
end
