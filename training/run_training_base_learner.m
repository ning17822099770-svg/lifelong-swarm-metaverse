%RUN_TRAINING_BASE_LEARNER  Train the NAC base learner in the central collection UAV (Fig. 8).
%
%   Simulates 20 UAV-server processing queues in parallel for 6000 episodes (T = 50 time
%   steps each). The task environment switches every z = 300 episodes and cycles through the
%   five semantic environments of Table II. The policy decides how many tasks to compute per
%   time slot and is updated with episodic Natural Actor-Critic (ENAC).
%
%   Saves outputs/pretrained/policy_base.mat (used by the online base-learner runs) and then
%   runs RUN_TRAINING_LIFELONG, which plots Fig. 8 (base learner vs. LL).
%
%   Usage:  setup_paths('training'); run_training_base_learner
%
%   See also RUN_TRAINING_LIFELONG, RUN_TRAINING_EXHAUSTIVE_SEARCH, ENAC.

T = 50;
pall_lines = 20; % 50

server_info = server_generation(pall_lines);

seed_value = 3;

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
rng(seed_value); % Replace seed_value with the seed value you desire

gamma = 0.99;
hessScal = 1;
SecondDimofL = 5;
learningRate = 0.002; % 0.002

Task_queue = struct('queue', []);
Trajectory = struct('trajectory', []);
% Trajectory(server_id, Trajectory_id) = struct(); % Initialize Trajectory(server_id, Trajectory_id)
policy_base = struct('theta', []);
policyPGELLA = struct('theta', []);

% modelsPGELLA = struct('model', []);
dJdTheta = struct('djdtheta', []);
Average_reward = zeros(num_of_trajectory_total,pall_lines);
Average_Averagelifespan = zeros(num_of_trajectory_total,pall_lines);
Average_ScaledEC = zeros(num_of_trajectory_total,pall_lines);
Dealta_max = zeros(num_of_trajectory_total,pall_lines);
% Average_reward_random = zeros(num_of_trajectory_total,number_of_servers);


% HessianArray = struct('D', []);
% ParameterArray = struct('alpha', []);
%
% HessianArray(model_number,Task_number).D = [];
%
% ParameterArray(model_number,Task_number).alpha = [];


if isempty(gcp('nocreate'))
    parpool; % If needed, you can specify the number of worker processes after parpool
end


for Trajectory_id = 1:num_of_trajectory_total

    if Trajectory_id == 2101
        % Save the variable policy_base to a file
        save(fullfile(output_dir('pretrained'), 'policy_base.mat'), 'policy_base');
    end


    for t=1:T
        for pall = 1:pall_lines
            [new_tasks, model_type, task_ID] = task_generation(t, pall, server_info, Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3, num_of_trajectory_4, num_of_trajectory_5, num_of_trajectory_6, num_of_trajectory_7, num_of_trajectory_8, num_of_trajectory_9, num_of_trajectory_10, num_of_trajectory_11, num_of_trajectory_12, num_of_trajectory_13, num_of_trajectory_14,num_of_trajectory_15, num_of_trajectory_16, num_of_trajectory_17, num_of_trajectory_18, num_of_trajectory_19);

            Task_queue(pall,t).queue = new_tasks;

        end
    end

    N = model_type * 2;
    M = model_type;


    if Trajectory_id == 1

        policy_base = init_gauss_policy(N, M); % Initialize policy
        % modelsPGELLA(M).model = initial_PGELLA(N, M, SecondDimofL, exp(-5), exp(-5), learningRate, task_ID);

    end

    % if Trajectory_id == (num_of_trajectory_1 + 1) || Trajectory_id == (num_of_trajectory_2 + 1)
    %
    %     % task_ID = task_ID + 1;
    %
    %     % num_columns = size(modelsPGELLA(M).model.S, 2);
    %
    %     % if task_ID > num_columns
    %     %
    %     %     modelsPGELLA(M).model.S = [modelsPGELLA(M).model.S, zeros(size(modelsPGELLA(M).model.S, 1), 1)];
    %     %
    %     % end
    %
    % end


    parfor pall = 1:pall_lines
        % Inside the parfor loop, you can perform parallel computations

        Trajectory_single = Trajectory_process(Task_queue(pall,:), T, model_type, server_info, pall, policy_base, Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3 ,num_of_trajectory_4, num_of_trajectory_5, num_of_trajectory_6, num_of_trajectory_7, num_of_trajectory_8, num_of_trajectory_9, num_of_trajectory_10, num_of_trajectory_11, num_of_trajectory_12, num_of_trajectory_13, num_of_trajectory_14, num_of_trajectory_15, num_of_trajectory_16, num_of_trajectory_17, num_of_trajectory_18, num_of_trajectory_19);

        Trajectory(pall).trajectory = Trajectory_single;

        Average_reward(Trajectory_id,pall) = mean(Trajectory_single.rewards);

        Average_Averagelifespan(Trajectory_id,pall) = mean(Trajectory_single.Average_lifespan);

        Average_ScaledEC(Trajectory_id,pall) = mean(Trajectory_single.ScaledEC);

        Dealta_max(Trajectory_id,pall) = mean(Trajectory_single.Dealta_max);

    end




    dJdTheta = ENAC(policy_base, Trajectory, M, N, gamma, pall_lines);

    policy_base.theta.k = policy_base.theta.k + 1 * learningRate * dJdTheta;

    % HessianArray(task_ID).D = computeHessianArray(Trajectory, gamma, hessScal, policy.theta.sigma);
    %
    % ParameterArray(task_ID).alpha = policy.theta.k;
    %
    % modelsPGELLA(M).model = updatePGELLA(modelsPGELLA(M).model, task_ID, HessianArray, ParameterArray);

    % policyPGELLA(task_ID).theta.k = modelsPGELLA(M).model.L * modelsPGELLA(M).model.S(:, task_ID);
    %
    % policyPGELLA(task_ID).theta.sigma = policy.theta.sigma;

    % if Trajectory_id == 1001 || Trajectory_id >= 1501
    %
    %     policy.theta.k = policyPGELLA(task_ID).theta.k;
    %
    % end



end

% % Close the parallel pool
% delete(gcp);

%
% mean_rewards_LLhelp = mean(Average_reward, 2); % Calculate the mean along the columns
% Existing data calculation code
% Existing data calculation code
mean_rewards_baselearner = -mean(Average_reward, 2); % Calculate the mean along the columns
mean_Average_lifespan = mean(Average_Averagelifespan, 2);
mean_Average_ScaledEC = mean(Average_ScaledEC, 2);

% Add environment labels for each interval (using "E" as a representation)
environment_labels = {'E1', 'E2', 'E3', 'E4', 'E5'};

% Plot the average reward graph
figure;
plot(1:length(mean_rewards_baselearner), mean_rewards_baselearner);
for x = z:z:length(mean_rewards_baselearner)
    env_index = mod((x/z)-1, 5) + 1;
    xline(x, '--', 'Color', 'black');
    text(x-25, max(mean_rewards_baselearner) * 0.9, environment_labels{env_index}, 'HorizontalAlignment', 'right');
end
xlabel('Episodes');
ylabel('Mean penalty for 20 servers');
legend('base-learner');
title('Mean rewards for servers in type 1 baselearner');

% Plot the average lifespan graph
figure;
plot(1:length(mean_Average_lifespan), mean_Average_lifespan);
hold on;
plot(1:length(Dealta_max), Dealta_max, 'k', 'LineWidth', 2);  % Draw Dealta_max with a thick black line
for x = z:z:length(mean_Average_lifespan)
    env_index = mod((x/z)-1, 5) + 1;
    xline(x, '--', 'Color', 'black');
    text(x-25, max(mean_Average_lifespan) * 0.9, environment_labels{env_index}, 'HorizontalAlignment', 'right');
end
xlabel('Episodes');
ylabel('Mean Average_lifespan for 20 servers');
legend('base-learner');
title('Mean Average_lifespan for servers in type 1 baselearner');

% Plot the average energy cost graph
figure;
plot(1:length(mean_Average_ScaledEC), mean_Average_ScaledEC);
for x = z:z:length(mean_Average_ScaledEC)
    env_index = mod((x/z)-1, 5) + 1;
    xline(x, '--', 'Color', 'black');
    text(x-25, max(mean_Average_ScaledEC) * 0.9, environment_labels{env_index}, 'HorizontalAlignment', 'right');
end
xlabel('Episodes');
ylabel('Mean ScaledEC for 20 servers');
legend('base-learner');
title('Mean ScaledEC for servers in type 1 baselearner');

%
run('run_training_lifelong.m');

