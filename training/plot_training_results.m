function plot_training_results(mean_rewards_baselearner, Average_reward, Average_Averagelifespan, Average_ScaledEC, ...
                      mean_Average_lifespan, mean_Average_ScaledEC, Dealta_max, z)
%PLOT_TRAINING_RESULTS  Reproduce Fig. 8 of the paper (training in the central collection UAV).
%
%   Draws three figures comparing the NAC base learner with lifelong learning (LL):
%     (a) average penalty, together with the exhaustive-search optimum,
%     (b) average task lifespan, together with the required latency of each environment,
%     (c) scaled energy cost.
%   All curves are averaged over windows of 100 episodes. The environment switches every
%   300 episodes (dashed grey lines every 3 windows, darker lines every full 5-environment cycle).
%
%   Inputs come from RUN_TRAINING_BASE_LEARNER (base-learner curves) and
%   RUN_TRAINING_LIFELONG (LL curves), which calls this function at the end.
%
%   See also RUN_TRAINING_BASE_LEARNER, RUN_TRAINING_LIFELONG, RUN_TRAINING_EXHAUSTIVE_SEARCH.

    FONT_SIZE = 18;   % common font size for all axes

    % Helper function to compute moving average and bounds for 100-point windows
    function [mean_vals, min_vals, max_vals] = compute_moving_avg(data, window_size)
        num_points = length(data);
        num_windows = floor(num_points / window_size);
        mean_vals = zeros(1, num_windows);
        min_vals = zeros(1, num_windows);
        max_vals = zeros(1, num_windows);

        for i = 1:num_windows
            window_data = data((i-1)*window_size+1:i*window_size);
            mean_vals(i) = mean(window_data);
            min_vals(i) = min(window_data);
            max_vals(i) = max(window_data);
        end
    end

    % Exhaustive-search optimum of the penalty for each of the 5 environments
    % (obtained with RUN_TRAINING_EXHAUSTIVE_SEARCH), repeated every 300 episodes
    array_search = zeros(1, 6000);
    changeValues = [0.175, 0.74, 0.96, 0.78, 0.38];
    changeIndex = 1;

    for i = 1:6000
        if mod(i-1, 300) == 0
            array_search(i) = changeValues(changeIndex);
            changeIndex = mod(changeIndex, length(changeValues)) + 1;
        else
            array_search(i) = array_search(i-1);
        end
    end

    % Average the array_search data every 100 points
    [array_search_avg, ~, ~] = compute_moving_avg(array_search, 100);
    [Dealta_max_avg, ~, ~] = compute_moving_avg(Dealta_max, 100);

    % Moving averages for base-learner and LL data
    [mean_rewards_baselearner_avg, ~, ~] = compute_moving_avg(mean_rewards_baselearner, 100);
    mean_rewards_LLhelp = -mean(Average_reward, 2);
    [mean_rewards_LLhelp_avg, ~, ~] = compute_moving_avg(mean_rewards_LLhelp, 100);

    x_vals = 1:length(mean_rewards_baselearner_avg);
    x_max = length(x_vals);

    %% Function to add vertical dashed lines
    function add_vertical_lines(x_max)
        for i = 1:x_max
            if mod(i, 15) == 0
                xline(i, '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.5);
            elseif mod(i, 3) == 0
                xline(i, '--', 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5);
            end
        end
    end

    %% Function to unify font settings for current axes
    function set_axes_font()
        ax = gca;
        ax.FontSize = FONT_SIZE;        % font size of the tick labels
        ax.LineWidth = 1;               % slightly thicker axis lines
        ax.Box = 'on';                  % keep the axes box
    end

    %% Fig. 8(a): average penalty for training, with the exhaustive-search optimum
    figure;
    y_max = max([mean_rewards_baselearner_avg, mean_rewards_LLhelp_avg, array_search_avg]) + 0.2;
    y_min = min([mean_rewards_baselearner_avg, mean_rewards_LLhelp_avg, array_search_avg]) - 0.2;

    hold on;
    add_vertical_lines(x_max);

    h1 = plot(x_vals, mean_rewards_LLhelp_avg, 'r', 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 5);
    h2 = plot(x_vals, mean_rewards_baselearner_avg, 'b', 'LineWidth', 2, 'Marker', 's', 'MarkerSize', 5);
    h3 = plot(x_vals, array_search_avg, 'k', 'LineWidth', 2);

    xlim([0 x_max]);
    ylim([y_min y_max]);

    legend([h1, h2, h3], 'LL average', 'Base-learner average', 'Exhaustive search', ...
           'Location', 'Best', 'FontSize', FONT_SIZE);

    xlabel('Episodes (averaged every 100)', 'FontSize', FONT_SIZE);
    ylabel('Mean penalty for training', 'FontSize', FONT_SIZE);

    % no title (the caption is given in the paper)
    set_axes_font();
    drawnow;

    %% Fig. 8(b): average task lifespan for training, with the required latency
    figure;
    mean_Average_lifespan_LLhelp = mean(Average_Averagelifespan, 2);
    [mean_Average_lifespan_avg, ~, ~] = compute_moving_avg(mean_Average_lifespan, 100);
    [mean_Average_lifespan_LLhelp_avg, ~, ~] = compute_moving_avg(mean_Average_lifespan_LLhelp, 100);

    y_max = max([mean_Average_lifespan_avg, mean_Average_lifespan_LLhelp_avg, Dealta_max_avg]) + 0.2;
    y_min = min([mean_Average_lifespan_avg, mean_Average_lifespan_LLhelp_avg, Dealta_max_avg]) - 0.2;

    hold on;
    add_vertical_lines(x_max);

    h4 = plot(x_vals, mean_Average_lifespan_LLhelp_avg, 'r', 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 5);
    h5 = plot(x_vals, mean_Average_lifespan_avg, 'b', 'LineWidth', 2, 'Marker', 's', 'MarkerSize', 5);
    h6 = plot(x_vals, Dealta_max_avg, 'k', 'LineWidth', 2);

    xlim([0 x_max]);
    ylim([y_min y_max]);

    legend([h4, h5, h6], 'LL average', 'Base-learner average', 'Required latency', ...
           'Location', 'Best', 'FontSize', FONT_SIZE);

    xlabel('Episodes (averaged every 100)', 'FontSize', FONT_SIZE);
    ylabel('Mean Average lifespan for training', 'FontSize', FONT_SIZE);

    % no title
    set_axes_font();
    drawnow;

    %% Fig. 8(c): scaled energy cost for training
    figure;
    mean_Average_ScaledEC_LLhelp = mean(Average_ScaledEC, 2);
    [mean_Average_ScaledEC_avg, ~, ~] = compute_moving_avg(mean_Average_ScaledEC, 100);
    [mean_Average_ScaledEC_LLhelp_avg, ~, ~] = compute_moving_avg(mean_Average_ScaledEC_LLhelp, 100);

    y_max = max([mean_Average_ScaledEC_avg, mean_Average_ScaledEC_LLhelp_avg]) + 0.2;
    y_min = min([mean_Average_ScaledEC_avg, mean_Average_ScaledEC_LLhelp_avg]) - 0.2;

    hold on;
    add_vertical_lines(x_max);

    h7 = plot(x_vals, mean_Average_ScaledEC_LLhelp_avg, 'r', 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 5);
    h8 = plot(x_vals, mean_Average_ScaledEC_avg, 'b', 'LineWidth', 2, 'Marker', 's', 'MarkerSize', 5);

    xlim([0 x_max]);
    ylim([y_min y_max]);

    legend([h7, h8], 'LL average', 'Base-learner average', ...
           'Location', 'Best', 'FontSize', FONT_SIZE);

    xlabel('Episodes (averaged every 100)', 'FontSize', FONT_SIZE);
    ylabel('Mean Average ScaledEC for training', 'FontSize', FONT_SIZE);

    % no title
    set_axes_font();
    drawnow;
end
