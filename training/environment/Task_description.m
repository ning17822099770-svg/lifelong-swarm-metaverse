function Task_description = Task_description(queue, N, M, model_type, t, Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3, num_of_trajectory_4, num_of_trajectory_5, num_of_trajectory_6, num_of_trajectory_7,  num_of_trajectory_8, num_of_trajectory_9, num_of_trajectory_10, num_of_trajectory_11, num_of_trajectory_12, num_of_trajectory_13, num_of_trajectory_14, num_of_trajectory_15, num_of_trajectory_16, num_of_trajectory_17, num_of_trajectory_18, num_of_trajectory_19)
%TASK_DESCRIPTION  MDP description of a processing queue at time T during training.
%
%   Returns the parameters of the computing cost of Eq. (21) for the active environment
%   (CPU cycles per task eta, latency requirement Delta, beta, alpha, scaling factors). It
%   also returns the scaled state my0 = [average lifespan; queue length].

param.N = N; % Size of State Space
param.M = M; % Size of Action Space

    
% Parameters for policy
param.modeltype = model_type;
param.rewardType = 'Distance';
param.polType = 'Gauss';
param.baselearner = 'NAC';
param.gamma = 0.99;

if (Trajectory_id <= num_of_trajectory_1) || (Trajectory_id > num_of_trajectory_5 && Trajectory_id <= num_of_trajectory_6) || (Trajectory_id > num_of_trajectory_10 && Trajectory_id <= num_of_trajectory_11) || (Trajectory_id > num_of_trajectory_15 && Trajectory_id <= num_of_trajectory_16)

    param.ita = 2.5 * 1e9;  %2 

    param.Dealta_max = 0.8; %0.7

elseif (Trajectory_id > num_of_trajectory_1 && Trajectory_id <= num_of_trajectory_2) || (Trajectory_id > num_of_trajectory_6 && Trajectory_id <= num_of_trajectory_7) || (Trajectory_id > num_of_trajectory_11 && Trajectory_id <= num_of_trajectory_12) || (Trajectory_id > num_of_trajectory_16 && Trajectory_id <= num_of_trajectory_17)

    param.ita = 1.75 * 1e9; %3

    param.Dealta_max = 1.4; %1.3


elseif (Trajectory_id > num_of_trajectory_2 && Trajectory_id <= num_of_trajectory_3) || (Trajectory_id > num_of_trajectory_7 && Trajectory_id <= num_of_trajectory_8) || (Trajectory_id > num_of_trajectory_12 && Trajectory_id <= num_of_trajectory_13) || (Trajectory_id > num_of_trajectory_17 && Trajectory_id <= num_of_trajectory_18)
    
    param.ita = 2 * 1e9; %3

    param.Dealta_max = 1.2; %1.1

elseif (Trajectory_id > num_of_trajectory_3 && Trajectory_id <= num_of_trajectory_4) || (Trajectory_id > num_of_trajectory_8 && Trajectory_id <= num_of_trajectory_9) || (Trajectory_id > num_of_trajectory_13 && Trajectory_id <= num_of_trajectory_14) || (Trajectory_id > num_of_trajectory_18 && Trajectory_id <= num_of_trajectory_19)
    
    param.ita = 2.25 * 1e9;  %1.5

    param.Dealta_max = 1.0; %0.9

elseif (Trajectory_id > num_of_trajectory_4  && Trajectory_id <= num_of_trajectory_5) || (Trajectory_id > num_of_trajectory_9 && Trajectory_id <= num_of_trajectory_10) || (Trajectory_id > num_of_trajectory_14 && Trajectory_id <= num_of_trajectory_15) || (Trajectory_id > num_of_trajectory_19)

    param.ita = 1.5 * 1e9;  %1.75

    param.Dealta_max = 1.6; %1.5

end
% Identifiers for tasks and groups
param.ProblemID = 1;

param.alpha = 1e-27;

param.beta = 0.4; %0.5 0.3

param.ScalingState = 0.5; %0.5

param.hessScal = 1;

param.Scalinglength = 0.05; %0.1

param.enlargelife = 2;

param.ScalingEnergy = 3e-6; %3e-6

Average_lifespan = t - mean(queue(:, 3)); 

queue_lenth = size(queue, 1);

param.my0 = [Average_lifespan, queue_lenth * param.Scalinglength]'*param.ScalingState;

Task_description = param;