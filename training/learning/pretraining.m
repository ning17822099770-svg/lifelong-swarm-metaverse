function [modelsPGELLA, HessianArray, ParameterArray] = pretraining()
%PRETRAINING  Build the initial lifelong-learning knowledge base (Algorithm 3, line 2).
%
%   [modelsPGELLA, HessianArray, ParameterArray] = PRETRAINING() runs a short pre-training
%   with tasks from the first three semantic environments (300 episodes each). It returns the
%   PG-ELLA model (latent basis L and task codes S) and the per-task Hessians and policy
%   parameters required by UPDATEPGELLA.
%
%   See also RUN_TRAINING_LIFELONG, INITIAL_PGELLA, UPDATEPGELLA.

T = 50;

pall_lines = 20; %50

server_info = server_generation(pall_lines);

seed_value = 3;

kinds_of_environment = 3;

num_of_trajectory_total = 300 * 3;
num_of_trajectory_1 = 300 * 1;
num_of_trajectory_2 = 300 * 2;
num_of_trajectory_3 = 300 * 3;
num_of_trajectory_4 = 300 * 4;
num_of_trajectory_5 = 300 * 5;
num_of_trajectory_6 = 300 * 6;
num_of_trajectory_7 = 300 * 7;
num_of_trajectory_8 = 300 * 8;
num_of_trajectory_9 = 300 * 9;
num_of_trajectory_10 = 300 * 10;
num_of_trajectory_11 = 300 * 11;
num_of_trajectory_12 = 300 * 12;
num_of_trajectory_13 = 300 * 13;
num_of_trajectory_14 = 300 * 14;
num_of_trajectory_15 = 300 * 15;
num_of_trajectory_16 = 300 * 16;
num_of_trajectory_17 = 300 * 17;
num_of_trajectory_18 = 300 * 18;
num_of_trajectory_19 = 300 * 19;
% num_of_trajectory_3 = 450;

rng(seed_value); 

gamma = 0.99;
hessScal = 1;
SecondDimofL = 5;
learningRate = 0.002;%v0.0005
learningRate_LL = 0.003;

Task_queue = struct('queue', []);
Trajectory = struct('trajectory', []);
% Trajectory(server_id, Trajectory_id) = struct(); 
policy = struct('theta', []);
policyPGELLA = struct('theta', []);

modelsPGELLA = struct('model', []);
dJdTheta = struct('djdtheta', []);
Average_reward = zeros(num_of_trajectory_total,pall_lines);
Average_Averagelifespan = zeros(num_of_trajectory_total,pall_lines);
Average_ScaledEC = zeros(num_of_trajectory_total,pall_lines);
% Average_reward_random = zeros(num_of_trajectory_total,number_of_servers);


HessianArray = struct('D', []);
ParameterArray = struct('alpha', []);
%
% HessianArray(model_number,Task_number).D = [];
%
% ParameterArray(model_number,Task_number).alpha = [];



if isempty(gcp('nocreate'))
    parpool;
end



for Trajectory_id = 1:num_of_trajectory_total


    for t=1:T
        for pall = 1:pall_lines
            [new_tasks, model_type, task_ID] = task_generation(t, pall, server_info, Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3, num_of_trajectory_4, num_of_trajectory_5, num_of_trajectory_6, num_of_trajectory_7, num_of_trajectory_8, num_of_trajectory_9, num_of_trajectory_10, num_of_trajectory_11, num_of_trajectory_12, num_of_trajectory_13, num_of_trajectory_14, num_of_trajectory_15, num_of_trajectory_16, num_of_trajectory_17, num_of_trajectory_18, num_of_trajectory_19);

            Task_queue(pall,t).queue = new_tasks;

        end
    end

    N = model_type * 2;
    M = model_type;


    if Trajectory_id == 1

        policy = init_gauss_policy(N, M); %Initinal the policy
        modelsPGELLA(M).model = initial_PGELLA(N, M, SecondDimofL, exp(-5), exp(-5), learningRate_LL, task_ID);

    end



    num_columns = size(modelsPGELLA(M).model.S, 2);

    if task_ID > num_columns

        modelsPGELLA(M).model.S = [modelsPGELLA(M).model.S, zeros(size(modelsPGELLA(M).model.S, 1), 1)];

    end



    parfor pall = 1:pall_lines

        Trajectory_single = Trajectory_process(Task_queue(pall,:), T, model_type, server_info, pall, policy, Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3 ,num_of_trajectory_4, num_of_trajectory_5, num_of_trajectory_6, num_of_trajectory_7, num_of_trajectory_8, num_of_trajectory_9, num_of_trajectory_10, num_of_trajectory_11, num_of_trajectory_12, num_of_trajectory_13, num_of_trajectory_14, num_of_trajectory_15, num_of_trajectory_16, num_of_trajectory_17, num_of_trajectory_18, num_of_trajectory_19);
        
        Trajectory(pall).trajectory = Trajectory_single;

        Average_reward(Trajectory_id,pall) = mean(Trajectory_single.rewards);

        Average_Averagelifespan(Trajectory_id,pall) = mean(Trajectory_single.Average_lifespan);

        Average_ScaledEC(Trajectory_id,pall) = mean(Trajectory_single.ScaledEC);

    end




    dJdTheta = ENAC(policy, Trajectory, M, N, gamma, pall_lines);

    policy.theta.k = policy.theta.k + 1 * learningRate * dJdTheta;

    HessianArray(task_ID).D = computeHessianArray(Trajectory, gamma, hessScal, policy.theta.sigma);

    ParameterArray(task_ID).alpha = policy.theta.k;

    modelsPGELLA(M).model = updatePGELLA(modelsPGELLA(M).model, task_ID, HessianArray, ParameterArray);

    policyPGELLA(task_ID).theta.k = modelsPGELLA(M).model.L * modelsPGELLA(M).model.S(:, task_ID);

    policyPGELLA(task_ID).theta.sigma = policy.theta.sigma;

    % if  (Trajectory_id >= 1501 && Trajectory_id < 1510) || (Trajectory_id >= 2001 && Trajectory_id < 2010)
    % 
    %     % if Trajectory_id >= 2001
    % 
    %     policy.theta.k = policyPGELLA(task_ID).theta.k;
    % 
    % end



end

% % close
% delete(gcp);
