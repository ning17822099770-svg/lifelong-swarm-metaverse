function [tasks, model_type, task_ID] = task_generation(t, Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3, num_of_trajectory_4, num_of_trajectory_5, num_of_trajectory_6, num_of_trajectory_7, num_of_trajectory_8, num_of_trajectory_9)
%TASK_GENERATION  Tasks collected from the five semantic environments in one time step.
%
%   Environment k produces round(N(m_k, s_k)) tasks with probability lambda_k (Table II).
%   Each task row is [environment/type k, price, arrival time t].

    % Generate the specified number of tasks
    tasks = [];
    model_type = 1;
    n = 5;

    % Normal distribution parameters
    mean_task_count = [20*n, 80*n, 60*n, 40*n, 100*n]; % Mean task count for each trajectory range
    std_task_count = [3*n, 6*n, 8*n, 10*n, 12*n]; % Standard deviation of task count for each trajectory range

    % Source probabilities
    source_prob = [0.8, 0.5, 0.6, 0.7, 0.4;  % Probability distribution for Source 1
                   0.8, 0.3, 0.3, 0.2, 0.1;  % Probability distribution for Source 2
                   0.4, 0.2, 0.2, 0.15, 0.2]; % Probability distribution for Source 3
    source_values = [1, 2, 3, 4, 5]; % Values for sources

    % Get the task ID
    if Trajectory_id <= num_of_trajectory_1
    % if (Trajectory_id <= num_of_trajectory_1) || (Trajectory_id > num_of_trajectory_5 && Trajectory_id <= num_of_trajectory_6)
        task_ID = 1;
    % elseif (Trajectory_id > num_of_trajectory_1 && Trajectory_id <= num_of_trajectory_2) || (Trajectory_id > num_of_trajectory_3 && Trajectory_id <= num_of_trajectory_4) || (Trajectory_id > num_of_trajectory_6 && Trajectory_id <= num_of_trajectory_7) || (Trajectory_id > num_of_trajectory_8 && Trajectory_id <= num_of_trajectory_9)
    %     task_ID = 2;
    % elseif (Trajectory_id > num_of_trajectory_2 && Trajectory_id <= num_of_trajectory_3) || (Trajectory_id > num_of_trajectory_4  && Trajectory_id <= num_of_trajectory_5) || (Trajectory_id > num_of_trajectory_7 && Trajectory_id <= num_of_trajectory_8) || (Trajectory_id > num_of_trajectory_9)
    %     task_ID = 3;
    end

    % Randomly select a source and generate tasks
    for source_idx = 1:5
        task_count = round(normrnd(mean_task_count(source_idx), std_task_count(source_idx)));
        
        % Use source probabilities to influence task generation
        source_probability = source_prob(task_ID, source_idx);
        if rand() <= source_probability
            price = source_values(source_idx) * 1000;

            for i = 1:task_count
                % Build task information
                task_info = [source_values(source_idx), price, t];

                % Add the task to the task array
                tasks = [tasks; task_info];
            end
        end
    end
end



