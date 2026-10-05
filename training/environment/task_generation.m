function [tasks, model_type, task_ID] = task_generation(t, server_id, server_info, Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3, num_of_trajectory_4, num_of_trajectory_5, num_of_trajectory_6, num_of_trajectory_7, num_of_trajectory_8, num_of_trajectory_9, num_of_trajectory_10, num_of_trajectory_11, num_of_trajectory_12, num_of_trajectory_13, num_of_trajectory_14, num_of_trajectory_15, num_of_trajectory_16, num_of_trajectory_17, num_of_trajectory_18, num_of_trajectory_19)
%TASK_GENERATION  Tasks arriving at one simulated server queue during training.
%
%   The active semantic environment (task_ID = 1..5) is selected from the episode index:
%   it changes every 300 episodes and cycles through the five environments of Table II.
%   Each task row is [source, server type, arrival time t, server id].

    if (Trajectory_id <= num_of_trajectory_1) || (Trajectory_id > num_of_trajectory_5 && Trajectory_id <= num_of_trajectory_6) || (Trajectory_id > num_of_trajectory_10 && Trajectory_id <= num_of_trajectory_11) || (Trajectory_id > num_of_trajectory_15 && Trajectory_id <= num_of_trajectory_16)
        % Generate a specified number of tasks
        tasks = [];

        model_type = 1;

        % Normal distribution parameters
        mean_task_count = 20;  
        std_task_count = 3;

        % Source probability
        source_prob = [0.8, 0.2];  
        source_values = [1, 5];

        task_ID = 1;

    elseif (Trajectory_id > num_of_trajectory_1 && Trajectory_id <= num_of_trajectory_2) || (Trajectory_id > num_of_trajectory_6 && Trajectory_id <= num_of_trajectory_7) || (Trajectory_id > num_of_trajectory_11 && Trajectory_id <= num_of_trajectory_12) || (Trajectory_id > num_of_trajectory_16 && Trajectory_id <= num_of_trajectory_17)
        % Generate a specified number of tasks
        tasks = [];

        model_type = 1;

        % Normal distribution parameters
        mean_task_count = 80; 
        std_task_count = 10;

        % Source probability
        source_prob = [0.5, 0.5];  
        source_values = [1, 5];

        task_ID = 2;

    elseif (Trajectory_id > num_of_trajectory_2 && Trajectory_id <= num_of_trajectory_3) || (Trajectory_id > num_of_trajectory_7 && Trajectory_id <= num_of_trajectory_8) || (Trajectory_id > num_of_trajectory_12 && Trajectory_id <= num_of_trajectory_13) || (Trajectory_id > num_of_trajectory_17 && Trajectory_id <= num_of_trajectory_18)
        % Generate a specified number of tasks
        tasks = [];

        model_type = 1;

        % Normal distribution parameters
        mean_task_count = 60; 
        std_task_count = 8;

        % Source probability
        source_prob = [0.6, 0.4];  
        source_values = [1, 5];
        
        task_ID = 3;


    elseif (Trajectory_id > num_of_trajectory_3 && Trajectory_id <= num_of_trajectory_4) || (Trajectory_id > num_of_trajectory_8 && Trajectory_id <= num_of_trajectory_9) || (Trajectory_id > num_of_trajectory_13 && Trajectory_id <= num_of_trajectory_14) || (Trajectory_id > num_of_trajectory_18 && Trajectory_id <= num_of_trajectory_19)

        % Generate a specified number of tasks
        tasks = [];

        model_type = 1;

        % Normal distribution parameters
        mean_task_count = 40;  
        std_task_count = 6;

        % Source probability
        source_prob = [0.7, 0.3];  
        source_values = [1, 5];

        task_ID = 4;

    elseif (Trajectory_id > num_of_trajectory_4  && Trajectory_id <= num_of_trajectory_5) || (Trajectory_id > num_of_trajectory_9 && Trajectory_id <= num_of_trajectory_10)  || (Trajectory_id > num_of_trajectory_14 && Trajectory_id <= num_of_trajectory_15)|| (Trajectory_id > num_of_trajectory_19)

        % Generate a specified number of tasks
        tasks = [];

        model_type = 1;

        % Normal distribution parameters
        mean_task_count = 100; 
        std_task_count = 12;

        % Source probability
        source_prob = [0.4, 0.6];  
        source_values = [1, 5];
        
        task_ID = 5;

    end

    k_value = server_info(server_id,1);


    % Randomly select the source
    source_idx = randsrc(1, 1, [source_values; source_prob]);

    if source_idx == 1


        task_count = round(normrnd(mean_task_count, std_task_count));


        for i = 1:task_count

            % Build task information
            task_info = [source_idx, k_value, t, server_id];

            % Add the task to the task array
            tasks = [tasks; task_info];
        end
    else
        tasks = [];
    end
end
