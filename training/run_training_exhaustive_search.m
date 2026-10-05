%RUN_TRAINING_EXHAUSTIVE_SEARCH  Grid search for the optimal linear policy of each environment.
%
%   Evaluates every policy parameter pair theta = [i; j] on a grid and keeps the one with the
%   lowest penalty for each of the five environments. The resulting optimum penalties are
%   the "Exhaustive search" reference curve in Fig. 8(a); they are hard-coded in
%   PLOT_TRAINING_RESULTS (changeValues).
%
%   See also PLOT_TRAINING_RESULTS.

% Initialize the ranges and precision for i and j
startValue_i = 0;
endValue_i = 0.15;
startValue_j = 0.4;
endValue_j = 0.5;
stepSize = 0.01;

T = 50;
pall_lines = 1; % 50

server_info = server_generation(pall_lines);

n = 5;

mean_rewards_baselearner = zeros(1,5);
mean_Average_lifespan = zeros(1,5);
mean_Average_ScaledEC = zeros(1,5);

global_rewards_baselearner = Inf(1,5);
global_lifespan_baselearner= zeros(1,5);
global_Average_ScaledEC = zeros(1,5);

% Initialize a cell array containing 5 2x1 zero matrices
bestpolicy = cell(1, 5); % Create a 1x5 cell array
for i = 1:5
    bestpolicy{i} = zeros(2, 1);
end




num_of_trajectory_total = n * 5;
num_of_trajectory_1 = n * 1;
num_of_trajectory_2 = n * 2;
num_of_trajectory_3 = n * 3;
num_of_trajectory_4 = n * 4;
num_of_trajectory_5 = n * 5;
num_of_trajectory_6 = n * 6;
num_of_trajectory_7 = n * 7;
num_of_trajectory_8 = n * 8;
num_of_trajectory_9 = n * 9;
num_of_trajectory_10 = n * 10;
num_of_trajectory_11 = n * 11;
num_of_trajectory_12 = n * 12;
num_of_trajectory_13 = n * 13;
num_of_trajectory_14 = n * 14;
num_of_trajectory_15 = n * 15;
num_of_trajectory_16 = n * 16;
num_of_trajectory_17 = n * 17;
num_of_trajectory_18 = n * 18;
num_of_trajectory_19 = n * 19;

policy_base = struct('theta', []);


if isempty(gcp('nocreate'))
    parpool; % If necessary, you can specify the number of worker processes after parpool
end

policy_base = init_gauss_policy(2, 1); % Initialize the policy

for E = 1:5
    % Outer loop for i
    for i = startValue_i:stepSize:endValue_i
        % Inner loop for j
        for j = startValue_j:stepSize:endValue_j
            % Perform some operations here
            % For example, simply print the current values of i and j
            disp(E)
            disp([i,j])
            policy_base.theta.k = [i;j];
            policy_base.theta.sigma = 0.25;

            Average_reward = zeros(n, pall_lines);
            Average_Averagelifespan = zeros(n, pall_lines);
            Average_ScaledEC = zeros(n, pall_lines);
            Dealta_max = zeros(n, pall_lines);

            Task_queue = struct('queue', []);
            Trajectory = struct('trajectory', []);


            for Trajectory_id = ((E-1)*n+1):(E)*n


                for t=1:T
                    for pall = 1:pall_lines
                        [new_tasks, model_type, task_ID] = task_generation(t, pall, server_info, Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3, num_of_trajectory_4, num_of_trajectory_5, num_of_trajectory_6, num_of_trajectory_7, num_of_trajectory_8, num_of_trajectory_9, num_of_trajectory_10, num_of_trajectory_11, num_of_trajectory_12, num_of_trajectory_13, num_of_trajectory_14,num_of_trajectory_15, num_of_trajectory_16, num_of_trajectory_17, num_of_trajectory_18, num_of_trajectory_19);

                        Task_queue(pall,t).queue = new_tasks;

                    end
                end

                N = model_type * 2;
                M = model_type;
                
                if E > 1
                    % Check if Trajectory_id is a multiple of n
                    if mod(Trajectory_id, n) == 0
                        % If E > 1 and Trajectory_id is a multiple of n
                        X = n;
                    else
                        % If E > 1 and Trajectory_id is not a multiple of n
                        X = rem(Trajectory_id, (E-1)*n);
                    end
                elseif E == 1
                    % If E equals 1
                    X = Trajectory_id;
                else
                    % If E is less than 1, appropriate logic can be added here
                    % For example, setting X to some default value or returning an error
                    % X = default value or error handling;
                    error('The value of E is invalid, it must be greater than or equal to 1');
                end

                parfor pall = 1:pall_lines

                    Trajectory_single = Trajectory_process(Task_queue(pall,:), T, model_type, server_info, pall, policy_base, Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3 ,num_of_trajectory_4, num_of_trajectory_5, num_of_trajectory_6, num_of_trajectory_7, num_of_trajectory_8, num_of_trajectory_9, num_of_trajectory_10, num_of_trajectory_11, num_of_trajectory_12, num_of_trajectory_13, num_of_trajectory_14, num_of_trajectory_15, num_of_trajectory_16, num_of_trajectory_17, num_of_trajectory_18, num_of_trajectory_19);

                    Trajectory(pall).trajectory = Trajectory_single;

                    Average_reward(X,pall) = mean(Trajectory_single.rewards);

                    Average_Averagelifespan(X,pall) = mean(Trajectory_single.Average_lifespan);

                    Average_ScaledEC(X,pall) = mean(Trajectory_single.ScaledEC);

                    Dealta_max(X,pall) = mean(Trajectory_single.Dealta_max);

                end
            end

            mean_rewards_baselearner(E) = -mean(Average_reward); % Calculate the mean along the columns.
            mean_Average_lifespan(E) = mean(Average_Averagelifespan);
            mean_Average_ScaledEC(E) = mean(Average_ScaledEC);

            if mean_rewards_baselearner(E) < global_rewards_baselearner(E)
                global_rewards_baselearner(E) = mean_rewards_baselearner(E);
                global_lifespan_baselearner(E) = mean_Average_lifespan(E);
                global_Average_ScaledEC(E) = mean_Average_ScaledEC(E);
                bestpolicy{E} = [i;j];
            end
        end

    end
end