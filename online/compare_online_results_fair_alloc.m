%COMPARE_ONLINE_RESULTS_FAIR_ALLOC  Plot the results of the equal-split allocation baseline.
%
%   Same figures as COMPARE_ONLINE_RESULTS for the *_fair workspace variables.

% Define field names
fields = {'reward', 'Averagelifespan', 'ScaledEC', 'queue_length'};


% fields = {'reward'};
% fields = {'Averagelifespan'};
% fields = {'ScaledEC'};
% fields = {'queue_length'};




% Define different denominators for square root
denominators = [2.5*1e9, 1.75*1e9, 2*1e9, 2.25*1e9, 1.5*1e9];
% 
% save('mean_new_system_base_nopso.mat', 'mean_new_system_base_nopso');
% save('mean_new_system_LL_nopso.mat', 'mean_new_system_LL_nopso');

% save('mean_new_system_random.mat', 'mean_new_system_random');


% For each field
for i = 1:length(fields)
    % Create a new figure window
    h = figure;

    if strcmp(fields{i}, 'queue_length')

        % Set the title of the figure
        sgtitle(['Comparison of ', 'queue length']);

    else

        % Set the title of the figure
        sgtitle(['Comparison of ' fields{i}]);

    end

    % For each category
    for j = 1:5
        % Select the j-th position in a 2x3 subplot
        subplot(2, 3, j);

        % Extract data for the j-th category from the structure array
        data1 = mean_new_system_base_fair(j).(fields{i});
        data2 = mean_new_system_LL_fair(j).(fields{i});
        data3 = mean_new_system_base(j).(fields{i});
        data4 = mean_new_system_LL(j).(fields{i});
        % data3 = mean_new_system_random(j).(fields{i}); % Added new data

        % Calculate the mean of data1 and data2
        meanData1(j) = mean(data1);
        meanData2(j) = mean(data2);
        meanData3(j) = mean(data3);
        meanData4(j) = mean(data4);

        if strcmp(fields{i}, 'Averagelifespan')
            data5 = Dealta_max(:, j);

            % Plot the data from mean_new_system
            plot(data1, 'b', 'LineWidth', 2);
            hold on; % Keep the current figure to plot more data on it

            % Plot the data from mean_new_system_LL
            plot(data2, 'r', 'LineWidth', 2);
            hold on;

            % Plot the third dataset
            plot(data3, 'g', 'LineWidth', 2);
            hold on;

            % Plot the fourth dataset
            plot(data4, 'y', 'LineWidth', 2);
            hold on;

            % Plot the data from mean_new_system_random using a deep yellow color
            plot(data5, 'Color', [0.9, 0.7, 0.0], 'LineWidth', 2);
            hold on;

            % Plot the mean of data1 and data2
            plot(xlim, [meanData1(j) meanData1(j)], '--', 'Color', [1, 0.5, 0], 'LineWidth', 3); % Mean of data1, orange thick dashed line
            plot(xlim, [meanData2(j) meanData2(j)], '--', 'Color', 'k', 'LineWidth', 3); % Mean of data2, black thick dashed line

            % If necessary, add lines for the mean of data3 and data4 as well
            plot(xlim, [meanData3(j) meanData3(j)], '--', 'Color', [0.5, 0, 0.5], 'LineWidth', 3); % Mean of data3, e.g., purple thick dashed line
            plot(xlim, [meanData4(j) meanData4(j)], '--', 'Color', [0, 0.5, 0.5], 'LineWidth', 3); % Mean of data4, e.g., teal thick dashed line


            % Add legend
            legend('base fair', 'LL fair', 'base lya', 'LL lya', 'required latency', 'Mean base fair', 'Mean LL fair', 'Mean base', 'Mean LL');

            % Add subplot title
            title(['Category ' num2str(j)]);


        elseif strcmp(fields{i}, 'ScaledEC')
            % Plot the data from mean_new_system
            yyaxis left; % Switch to the left Y-axis
            plot(data1, 'b', 'LineStyle', '-', 'LineWidth', 2);
            hold on; % Keep the current figure to plot more data on it

            % Plot the data from mean_new_system_LL
            plot(data2, 'r', 'LineStyle', '-', 'LineWidth', 2);
            hold on;

            % Plot the third dataset
            plot(data3, 'g', 'LineStyle', '-', 'LineWidth', 2);
            hold on;

            % Plot the fourth dataset
            plot(data4, 'y', 'LineStyle', '-', 'LineWidth', 2);
            hold on;

            % Plot the data from the newly added mean_new_system_random dataset
            % plot(data3, 'Color', [0.9, 0.7, 0.0], 'LineStyle', '-', 'LineWidth', 2); % Use deep yellow solid line
                
            % Plot the mean of data1 and data2
            plot(xlim, [meanData1(j) meanData1(j)], '--', 'Color', [1, 0.5, 0], 'LineWidth', 3); % Mean of data1, orange thick dashed line
            plot(xlim, [meanData2(j) meanData2(j)], '--', 'Color', 'k', 'LineWidth', 3); % Mean of data2, cyan thick dashed line

            % If necessary, also add lines for the mean of data3 and data4
            plot(xlim, [meanData3(j) meanData3(j)], '--', 'Color', [0.5, 0, 0.5], 'LineWidth', 3); % Mean of data3, e.g., purple thick dashed line
            plot(xlim, [meanData4(j) meanData4(j)], '--', 'Color', [0, 0.5, 0.5], 'LineWidth', 3); % Mean of data4, e.g., teal thick dashed line


            % Set the left Y-axis label
            ylabel('ScaledEC');
            set(gca, 'YColor', 'k'); % 'k' represents black

            % Apply a transformation formula to each data point on the left Y-axis to compute the corresponding point on the right Y-axis
            % Assuming data1, data2, data3 need transformation on the Y-axis
            % Transform the values of data1
            transformedData1 = nthroot(data1 ./ (1e-27 * 3e-6), 3) ./ denominators(j);
            % Transform the values of data2
            transformedData2 = nthroot(data2 ./ (1e-27 * 3e-6), 3) ./ denominators(j);
            % Convert values of data3
            transformedData3 = nthroot(data3 ./ (1e-27 * 3e-6), 3) ./ denominators(j);
            % Convert values of data4
            transformedData4 = nthroot(data4 ./ (1e-27 * 3e-6), 3) ./ denominators(j);

            % Activate the right Y-axis
            yyaxis right;

            % Plot the transformed data points, set as transparent, not shown in the legend
            scatter(1:length(transformedData1), transformedData1, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'none');
            scatter(1:length(transformedData2), transformedData2, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'none');
            scatter(1:length(transformedData3), transformedData3, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'none');
            scatter(1:length(transformedData4), transformedData4, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'none');
            % scatter(1:length(transformedData3), transformedData3, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'none');

            % Set the label for the right Y-axis
            ylabel('Number of tasks');
            set(gca, 'YColor', 'k'); % 'k' represents black

            % Set the legend, displaying only the data on the left Y-axis
            legend({'base fair', 'LL fair', 'base lya','LL lya', 'Mean base fair', 'Mean LL fair', 'Mean base', 'Mean LL'});

            % Add a subplot title
            title(['Environment ' num2str(j)]);

            % End the hold state
            hold off;

        else

            % Plot the data from mean_new_system
            plot(data1, 'b', 'LineWidth', 2);
            hold on; % Keep the current figure to plot more data on it

            % Plot the data from mean_new_system_LL
            plot(data2, 'r', 'LineWidth', 2);

            % Plot the third dataset
            plot(data3, 'g', 'LineWidth', 2);
            hold on;

            % Plot the fourth dataset
            plot(data4, 'y', 'LineWidth', 2);
            hold on;

            % Plot the mean of data1 and data2
            plot(xlim, [meanData1(j) meanData1(j)], '--', 'Color', [1, 0.5, 0], 'LineWidth', 3); % Mean of data1, orange thick dashed line
            plot(xlim, [meanData2(j) meanData2(j)], '--', 'Color', 'k', 'LineWidth', 3); % Mean of data2, cyan thick dashed line

            % If necessary, also add lines for the mean of data3 and data4
            plot(xlim, [meanData3(j) meanData3(j)], '--', 'Color', [0.5, 0, 0.5], 'LineWidth', 3); % Mean of data3, e.g., purple thick dashed line
            plot(xlim, [meanData4(j) meanData4(j)], '--', 'Color', [0, 0.5, 0.5], 'LineWidth', 3); % Mean of data4, e.g., teal thick dashed line


            % Add legend
            legend('base fair', 'LL fair', 'base lya', 'LL lya', 'Mean base fair', 'Mean LL fair', 'Mean base', 'Mean LL');

            % Add subplot title
            title(['Category ' num2str(j)]);

            % Add axis labels
            xlabel('Trajectory id');
            if strcmp(fields{i}, 'queue_length')

                ylabel('queue length');

            else

                ylabel(fields{i});

            end
            % End the hold state
            hold off;

        end

        % % Save the figure as a PNG file with the field name in the filename
        % filename = sprintf('comparison_%s.png', fields{i});
        % saveas(h, filename);
    end
end


% Assume there are two matrices loss_for_allocation_base and loss_for_allocation_compare

% Calculate the mean of each row in the first matrix
row_averages_base_fair = - mean(loss_for_allocation_base_fair, 2);

% Calculate the mean of each row in the second matrix
row_averages_LL_fair = - mean(loss_for_allocation_LL_fair, 2);

row_averages_base = - mean(loss_for_allocation_base, 2);

row_averages_LL = - mean(loss_for_allocation_LL, 2);
% Calculate the mean of each row in the third matrix
% row_averages_initial = - mean(loss_for_allocation_initial, 2);
% row_averages_random = - mean(loss_for_allocation_random, 2);

% Create a new figure window
figure;

% Plot the mean of each row in the third matrix
plot(row_averages_base, 'g'); % 'g' specifies green color
hold on;

% Plot the mean of each row in the fourth matrix
plot(row_averages_LL, 'm'); % 'm' specifies magenta color
hold on;

% Plot the mean of each row in the first matrix
plot(row_averages_base_fair, 'b'); % 'b' specifies blue color
hold on; % Keep the current figure to plot more data on it

% Plot the mean of each row in the second matrix
plot(row_averages_LL_fair, 'r'); % 'r' specifies red color
hold on;

% Add legend
legend('Lya+base+Pso', 'Lya+LL+Pso', 'Fair+base+Pso', 'Fair+LL+Pso');

% legend('Fair+base+Pso', 'Fair+LL+Pso');

% Set title and axis labels
title('Average reward of task allocation');
xlabel('Trajectory');
ylabel('Average value');



% Assume the figure window number is 1
% saveas(1, 'comparison reward.png');



% Assume num_of_trajectory_total and loss_for_UAV_moving have been defined and initialized
% num_of_trajectory_total = ...;
% loss_for_UAV_moving = zeros(num_of_trajectory_total, 1);
% Here, the assignment of loss_for_UAV_moving is performed
% 
% Create a figure
% figure;
% 
% Plot loss_for_UAV_moving
% plot(loss_for_UAV_moving, 'LineWidth', 2);
% 
% Add title and axis labels
% title('Average Reward for UAV Moving');
% xlabel('Trajectory Index');
% ylabel('Reward Value');
% 
% Optionally: add grid lines
% grid on;
