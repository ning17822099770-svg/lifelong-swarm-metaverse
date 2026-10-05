%RUN_TRAINING_LIFELONG  Train the lifelong-learning (PG-ELLA) policy in the central UAV (Fig. 8).
%
%   Training part of Algorithm 3 (LL-CJTPA). It first calls PRETRAINING to build an
%   initial knowledge base L from three environments. It then runs the same 6000-episode,
%   5-environment schedule as RUN_TRAINING_BASE_LEARNER. After every episode the task-specific
%   policy is refined by ENAC, and L and s_t are updated with PG-ELLA (Eqs. (37)-(44)). When a
%   new environment appears, the policy is re-generated from the knowledge base as
%   theta = L * s_t.
%
%   Saves outputs/pretrained/modelsPGELLA.mat (the knowledge base used online) and calls
%   PLOT_TRAINING_RESULTS. It must run after RUN_TRAINING_BASE_LEARNER in the same
%   workspace, because the plot uses the base-learner curves.
%
%   See also PRETRAINING, UPDATEPGELLA, PLOT_TRAINING_RESULTS.

[modelsPGELLA, HessianArray, ParameterArray] = pretraining();

T = 50;

pall_lines = 20; %50

server_info = server_generation(pall_lines);

seed_value = 3;

kinds_of_environment = 3;

z = 300;

num_of_trajectory_total = z * 20;
num_of_trajectory_1 = z * 1;
num_of_trajectory_2 = z * 2;
num_of_trajectory_3 = z * 3;
num_of_trajectory_4 = z * 4;
num_of_trajectory_5 = z * 5;
num_of_trajectory_6 = z * 6;
num_of_trajectory_7 = z * 7;
num_of_trajectory_8 = z * 8;
num_of_trajectory_9 = z * 9;
num_of_trajectory_10 = z * 10;
num_of_trajectory_11 = z * 11;
num_of_trajectory_12 = z * 12;
num_of_trajectory_13 = z * 13;
num_of_trajectory_14 = z * 14;
num_of_trajectory_15 = z * 15;
num_of_trajectory_16 = z * 16;
num_of_trajectory_17 = z * 17;
num_of_trajectory_18 = z * 18;
num_of_trajectory_19 = z * 19;
% num_of_trajectory_3 = 450;


% Set the random seed value
rng(seed_value); % Replace seed_value with the desired seed value

gamma = 0.99;
hessScal = 1;
SecondDimofL = 5;
learningRate = 0.002;%0.002

Task_queue = struct('queue', []);
Trajectory = struct('trajectory', []);
% Trajectory(server_id, Trajectory_id) = struct(); % Initialize Trajectory(server_id, Trajectory_id)
policy_LL = struct('theta', []);
policyPGELLA = struct('theta', []);

% modelsPGELLA = struct('model', []);
dJdTheta = struct('djdtheta', []); 
Average_reward = zeros(num_of_trajectory_total,pall_lines);
Average_Averagelifespan = zeros(num_of_trajectory_total,pall_lines);
Average_ScaledEC = zeros(num_of_trajectory_total,pall_lines);
% Average_reward_random = zeros(num_of_trajectory_total,number_of_servers);


% HessianArray = struct('D', []);
% ParameterArray = struct('alpha', []);
% 
% HessianArray(model_number,Task_number).D = [];
% 
% ParameterArray(model_number,Task_number).alpha = [];



if isempty(gcp('nocreate'))
    parpool; % If necessary, you can specify the number of worker processes after parpool
end



for Trajectory_id = 1:num_of_trajectory_total


    for t=1:T
        for pall = 1:pall_lines
            [new_tasks, model_type, task_ID] = task_generation(t, pall, server_info, Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3, num_of_trajectory_4, num_of_trajectory_5, num_of_trajectory_6, num_of_trajectory_7, num_of_trajectory_8, num_of_trajectory_9, num_of_trajectory_10, num_of_trajectory_11, num_of_trajectory_12, num_of_trajectory_13, num_of_trajectory_14,num_of_trajectory_15, num_of_trajectory_16, num_of_trajectory_17, num_of_trajectory_18, num_of_trajectory_19);
            Task_queue(pall,t).queue = new_tasks;

        end
    end

    N = model_type * 2;
    M = model_type;


    if Trajectory_id == 1

        policy_LL = init_gauss_policy(N, M); % Initialize the policy

        policy_LL.theta.k = modelsPGELLA(M).model.L * modelsPGELLA(M).model.S(:, task_ID);


        % modelsPGELLA(M).model = initial_PGELLA(N, M, SecondDimofL, exp(-5), exp(-5), learningRate, task_ID);

    end



    num_columns = size(modelsPGELLA(M).model.S, 2);

    if task_ID > num_columns

        modelsPGELLA(M).model.S = [modelsPGELLA(M).model.S, zeros(size(modelsPGELLA(M).model.S, 1), 1)];

    end



    parfor pall = 1:pall_lines
        % Inside the parfor loop, you can execute parallel computations

        Trajectory_single = Trajectory_process(Task_queue(pall,:), T, model_type, server_info, pall, policy_LL, Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3 ,num_of_trajectory_4, num_of_trajectory_5, num_of_trajectory_6, num_of_trajectory_7, num_of_trajectory_8, num_of_trajectory_9, num_of_trajectory_10, num_of_trajectory_11, num_of_trajectory_12, num_of_trajectory_13, num_of_trajectory_14, num_of_trajectory_15, num_of_trajectory_16, num_of_trajectory_17, num_of_trajectory_18, num_of_trajectory_19);

        Trajectory(pall).trajectory = Trajectory_single;

        Average_reward(Trajectory_id,pall) = mean(Trajectory_single.rewards);

        Average_Averagelifespan(Trajectory_id,pall) = mean(Trajectory_single.Average_lifespan);

        Average_ScaledEC(Trajectory_id,pall) = mean(Trajectory_single.ScaledEC);

    end

    dJdTheta = ENAC(policy_LL, Trajectory, M, N, gamma, pall_lines);

    policy_LL.theta.k = policy_LL.theta.k + 1 * learningRate * dJdTheta;

    HessianArray(task_ID).D = computeHessianArray(Trajectory, gamma, hessScal, policy_LL.theta.sigma);

    ParameterArray(task_ID).alpha = policy_LL.theta.k;

    modelsPGELLA(M).model = updatePGELLA(modelsPGELLA(M).model, task_ID, HessianArray, ParameterArray);

    policyPGELLA(task_ID).theta.k = modelsPGELLA(M).model.L * modelsPGELLA(M).model.S(:, task_ID);

    policyPGELLA(task_ID).theta.sigma = policy_LL.theta.sigma;
    % 
    if  (Trajectory_id > num_of_trajectory_1 && Trajectory_id < num_of_trajectory_1 + 10) || (Trajectory_id > num_of_trajectory_2 && Trajectory_id < num_of_trajectory_2 + 10) || (Trajectory_id > num_of_trajectory_3 && Trajectory_id < num_of_trajectory_3 + 10) || (Trajectory_id > num_of_trajectory_4 && Trajectory_id < num_of_trajectory_4 + 10) || (Trajectory_id > num_of_trajectory_5 && Trajectory_id < num_of_trajectory_5 + 10) || (Trajectory_id > num_of_trajectory_6 && Trajectory_id < num_of_trajectory_6 + 10) || (Trajectory_id > num_of_trajectory_7 && Trajectory_id < num_of_trajectory_7 + 10) || (Trajectory_id > num_of_trajectory_8 && Trajectory_id < num_of_trajectory_8 + 10) || (Trajectory_id > num_of_trajectory_9 && Trajectory_id < num_of_trajectory_9 + 10) || (Trajectory_id > num_of_trajectory_10 && Trajectory_id < num_of_trajectory_10 + 10)  || (Trajectory_id > num_of_trajectory_11 && Trajectory_id < num_of_trajectory_11 + 10) || (Trajectory_id > num_of_trajectory_12 && Trajectory_id < num_of_trajectory_12 + 10) || (Trajectory_id > num_of_trajectory_13 && Trajectory_id < num_of_trajectory_13 + 10)  || (Trajectory_id > num_of_trajectory_14 && Trajectory_id < num_of_trajectory_14 + 10) || (Trajectory_id > num_of_trajectory_15 && Trajectory_id < num_of_trajectory_15 + 10) || (Trajectory_id > num_of_trajectory_16 && Trajectory_id < num_of_trajectory_16 + 10) || (Trajectory_id > num_of_trajectory_17 && Trajectory_id < num_of_trajectory_17 + 10) || (Trajectory_id > num_of_trajectory_18 && Trajectory_id < num_of_trajectory_18 + 10) || (Trajectory_id > num_of_trajectory_19 && Trajectory_id < num_of_trajectory_19 + 10)

    % if Trajectory_id >= 2001

        policy_LL.theta.k = policyPGELLA(task_ID).theta.k;

    end

    

    if Trajectory_id == 6000
        % checkpoint the lifelong-learning knowledge base after the last episode
        save(fullfile(output_dir('pretrained'), 'modelsPGELLA.mat'), 'modelsPGELLA');
    end



end

% Close the parallel pool if it is no longer needed
delete(gcp('nocreate'));

% Plot Fig. 8: penalty, task lifespan and scaled energy cost (base learner vs. LL)
plot_training_results(mean_rewards_baselearner, Average_reward, Average_Averagelifespan, Average_ScaledEC, mean_Average_lifespan, mean_Average_ScaledEC, Dealta_max, z);

% % % Initialize the array
% % array_search = zeros(1, 6000);
% % % Array of changing values
% % changeValues = [0.175, 0.74, 0.96, 0.78, 0.38];
% % % Index of changing values
% % changeIndex = 1;
% % 
% % % Traverse the array, changing its value every 300 elements
% % for i = 1:6000
% %     % Update the index of changing values every 300 elements
% %     if mod(i-1, 300) == 0
% %         array_search(i) = changeValues(changeIndex);
% %         % Update the index of changing values, cycling through the array of changing values
% %         changeIndex = mod(changeIndex, length(changeValues)) + 1;
% %     else
% %         % When not at a position that is a multiple of 300, the value remains the same as the previous one
% %         array_search(i) = array_search(i-1);
% %     end
% % end
% %  
% % % Existing data calculation code
% % mean_rewards_LLhelp = -mean(Average_reward, 2); % Calculate mean along the columns
% % mean_Average_lifespan_LLhelp = mean(Average_Averagelifespan, 2);
% % mean_Average_ScaledEC_LLhelp = mean(Average_ScaledEC, 2);
% % 
% % % Add environment labels for each interval
% % environment_labels = {'E1', 'E2', 'E3', 'E4', 'E5'};
% % 
% % % Plot the average reward graph
% % h = figure;
% % plot(1:length(mean_rewards_baselearner), mean_rewards_baselearner, 'b');
% % hold on;
% % plot(1:length(mean_rewards_LLhelp), mean_rewards_LLhelp, 'r');
% % hold on;
% % plot(1:length(array_search),array_search, 'k', 'LineWidth', 2)
% % for x = z:z:length(mean_rewards_LLhelp)
% %     env_index = mod((x/z)-1, 5) + 1;
% %     xline(x, '--', 'Color', 'black');
% %     text(x-25, max(mean_rewards_LLhelp) * 0.9, environment_labels{env_index}, 'HorizontalAlignment', 'right');
% % end
% % xlabel('Episodes');
% % ylabel('Mean penalty for training');
% % legend('Base-learner','LL', 'Exhaustive search');
% % title('Average penalty for training');
% % 
% % % Plot the average lifespan graph
% % h = figure;
% % plot(1:length(mean_Average_lifespan), mean_Average_lifespan, 'b');  % Use blue color for the first line
% % hold on;
% % plot(1:length(mean_Average_lifespan_LLhelp), mean_Average_lifespan_LLhelp, 'r');  % Use red color for the second line
% % hold on;
% % plot(1:length(Dealta_max), Dealta_max, 'k', 'LineWidth', 2);  % Use thick black line for Dealta_max
% % for x = z:z:length(mean_Average_lifespan_LLhelp)
% %     env_index = mod((x/z)-1, 5) + 1;
% %     xline(x, '--', 'Color', 'black');
% %     text(x-25, max(mean_Average_lifespan_LLhelp) * 0.9, environment_labels{env_index}, 'HorizontalAlignment', 'right');
% % end
% % xlabel('Episodes');
% % ylabel('Mean Average lifespan for training');
% % legend('Base-learner', 'LL', 'Required latency');
% % title('Average lifespan for training');
% % 
% % 
% % % Plot the average scaled energy cost graph
% % h = figure;
% % plot(1:length(mean_Average_ScaledEC), mean_Average_ScaledEC, 'b');
% % hold on;
% % plot(1:length(mean_Average_ScaledEC_LLhelp), mean_Average_ScaledEC_LLhelp, 'r');
% % for x = z:z:length(mean_Average_ScaledEC_LLhelp)
% %     env_index = mod((x/z)-1, 5) + 1;
% %     xline(x, '--', 'Color', 'black');
% %     text(x-25, max(mean_Average_ScaledEC_LLhelp) * 0.9, environment_labels{env_index}, 'HorizontalAlignment', 'right');
% % end
% % xlabel('Episodes');
% % ylabel('Mean Average ScaledEC for training');
% % legend('Base-learner','LL');
% % title('Average Scaled Energy Cost for training');



