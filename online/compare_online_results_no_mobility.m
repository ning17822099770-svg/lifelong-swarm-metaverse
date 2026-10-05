%COMPARE_ONLINE_RESULTS_NO_MOBILITY  Save and plot the results of the no-mobility ablation.
%
%   Saves the *_nopso.mat results to outputs/results and plots them like
%   COMPARE_ONLINE_RESULTS.

% Define field names
fields = {'reward', 'Averagelifespan', 'ScaledEC', 'queue_length'};


% fields = {'reward'};
% fields = {'Averagelifespan'};
% fields = {'ScaledEC'};
% fields = {'queue_length'};




% Define different denominators for square roots
denominators = [2.5*1e9, 1.75*1e9, 2*1e9, 2.25*1e9, 1.5*1e9];

save(fullfile(output_dir('results'), 'mean_new_system_base_nopso.mat'), 'mean_new_system_base_nopso');
save(fullfile(output_dir('results'), 'mean_new_system_LL_nopso.mat'), 'mean_new_system_LL_nopso');

save(fullfile(output_dir('results'), 'loss_for_allocation_base_nopso.mat'), 'loss_for_allocation_base_nopso');
save(fullfile(output_dir('results'), 'loss_for_allocation_LL_nopso.mat'), 'loss_for_allocation_LL_nopso');



% save('mean_new_system_random.mat', 'mean_new_system_random');


% For each field
for i = 1:length(fields)
    % Create a new figure window
    h = figure;

    if strcmp(fields{i}, 'queue_length')

        % Set the figure title
        sgtitle(['Comparison of ', 'queue length']);

    else

        % Set the figure title
        sgtitle(['Comparison of ' fields{i}]);

    end

    % For each category
    for j = 1:5
        % Choose the jth position in a 2x3 subplot
        subplot(2, 3, j);

        % Extract data for the jth category from the struct array
        data1 = mean_new_system_base_nopso(j).(fields{i});
        data2 = mean_new_system_LL_nopso(j).(fields{i});
        % data3 = mean_new_system_random(j).(fields{i}); % Newly added data

        % Calculate the mean of data1 and data2
        meanData1_nopso(j) = mean(data1);
        meanData2_nopso(j) = mean(data2);

        if strcmp(fields{i}, 'Averagelifespan')
            data4 = Dealta_max(:, j);

            % Plot data from mean_new_system
            plot(data1, 'b', 'LineWidth', 2);
            hold on; % Maintain the current figure to plot the next data on the same subplot

            % Plot data from mean_new_system_LL
            plot(data2, 'r', 'LineWidth', 2);

            % Plot data from mean_new_system_random using a deep yellow color
            % plot(data3, 'Color', [0.9, 0.7, 0.0], 'LineWidth', 2);


            plot(data4, 'LineWidth', 2);


            % Plot the mean of data1 and data2
            plot(xlim, [meanData1_nopso(j) meanData1_nopso(j)], '--', 'Color', [1, 0.5, 0], 'LineWidth', 3); % Mean of data1, orange thick dashed line
            plot(xlim, [meanData2_nopso(j) meanData2_nopso(j)], '--', 'Color', 'k', 'LineWidth', 3); % Mean of data2, cyan thick dashed line

            % Add legend
            legend('base', 'LL', 'required latency', 'Mean base', 'Mean LL');

            % Add subplot title
            title(['Category ' num2str(j)]);


        elseif strcmp(fields{i}, 'ScaledEC')
            % Plot data from mean_new_system
            yyaxis left; % Switch to the left Y-axis
            plot(data1, 'b', 'LineStyle', '-', 'LineWidth', 2);
            hold on; % Maintain the current figure to plot the next data on the same subplot

            % Plot data from mean_new_system_LL
            plot(data2, 'r', 'LineStyle', '-', 'LineWidth', 2);

            % Plot data from newly added mean_new_system_random
            % plot(data3, 'Color', [0.9, 0.7, 0.0], 'LineStyle', '-', 'LineWidth', 2); % Use deep yellow solid line

            % Plot the mean of data1 and data2
            plot(xlim, [meanData1_nopso(j) meanData1_nopso(j)], '--', 'Color', [1, 0.5, 0], 'LineWidth', 3); % Mean of data1, orange thick dashed line
            plot(xlim, [meanData2_nopso(j) meanData2_nopso(j)], '--', 'Color', 'k', 'LineWidth', 3); % Mean of data2, cyan thick dashed line


            % Set left Y-axis label
            ylabel('ScaledEC');
            set(gca, 'YColor', 'k'); % 'k' represents black

            % Apply transformation formula to each data point on the left Y-axis to compute corresponding points on the right Y-axis
            legend({'base', 'LL', 'Mean base', 'Mean LL'});

            % Add subplot title
            title(['Environment ' num2str(j)]);

            % Turn off hold state
            hold off;

        else

            % Plot data from mean_new_system
            plot(data1, 'b', 'LineWidth', 2);
            hold on; % Maintain the current figure to plot the next data on the same subplot

            % Plot data from mean_new_system_LL
            plot(data2, 'r', 'LineWidth', 2);

            % Plot data from mean_new_system_random using a deep yellow color
            % plot(data3, 'Color', [0.9, 0.7, 0.0], 'LineWidth', 2);


            % Plot the mean of data1 and data2
            plot(xlim, [meanData1_nopso(j) meanData1_nopso(j)], '--', 'Color', [1, 0.5, 0], 'LineWidth', 3); % Mean of data1, orange thick dashed line
            plot(xlim, [meanData2_nopso(j) meanData2_nopso(j)], '--', 'Color', 'k', 'LineWidth', 3); % Mean of data2, cyan thick dashed line
            % Add legend
            legend('base', 'LL', 'Mean base', 'Mean LL');


            % Add subplot title
            title(['Category ' num2str(j)]);

            % Add axis labels
            xlabel('Trajectory id');
            if strcmp(fields{i}, 'queue_length')

                ylabel('queue length');

            else

                ylabel(fields{i});

            end
            % Turn off hold state
            hold off;

        end

        % % Save the figure as a PNG file with the field name in the filename
        % filename = sprintf('comparison_%s.png', fields{i});
        % saveas(h, filename);
    end
end


% Assuming there are two matrices loss_for_allocation_base and loss_for_allocation_compare

row_averages_base = mean(loss_for_allocation_base, 2);

row_averages_LL = mean(loss_for_allocation_LL, 2);

% Calculate the average of each row for the first matrix
row_averages_base_nopso = mean(loss_for_allocation_base_nopso, 2);

% Calculate the average of each row for the second matrix
row_averages_LL_nopso = mean(loss_for_allocation_LL_nopso, 2);

% Calculate the average of each row for the third matrix
% row_averages_initial = - mean(loss_for_allocation_initial, 2);
% row_averages_random = - mean(loss_for_allocation_random, 2);

% Create a new figure window
figure;

% Plot the average of each row for the third matrix
plot(row_averages_base, 'g'); % 'g' specifies green
hold on;

% Plot the average of each row for the fourth matrix
plot(row_averages_LL, 'm'); % 'm' specifies magenta
hold on;

% Plot the average of each row for the first matrix
plot(row_averages_base_nopso, 'b'); % 'b' specifies blue
hold on; % Maintain the current figure to plot more data on top

% Plot the average of each row for the second matrix
plot(row_averages_LL_nopso, 'r'); % 'r' specifies red
hold on;

% Add legend
legend('Lya+base+Pso', 'Lya+LL+Pso', 'Lya-base no Pso', 'Lya-LL no Pso');

% Set title and axis labels
title('Average penalty of task allocation');
xlabel('Trajectory');
ylabel('Average value');



% % Assuming the figure window number is 1
% saveas(1, 'comparison reward.png');



% Assuming num_of_trajectory_total and loss_for_UAV_moving are defined and initialized
% num_of_trajectory_total = ...;
% loss_for_UAV_moving = zeros(num_of_trajectory_total, 1);
% Here, the assignment of loss_for_UAV_moving is done
%
% % Create a figure
% figure;
%
% % Plot loss_for_UAV_moving
% plot(loss_for_UAV_moving_nopso, 'LineWidth', 2);
%
% % Add title and axis labels
% title('Average Reward for UAV Moving');
% xlabel('Trajectory Index');
% ylabel('Reward Value');
%
% % Optionally: Add grid lines
% grid on;
