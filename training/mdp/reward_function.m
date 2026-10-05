function [reward, ScaledEC, Average_lifespan, Dealta_max] = reward_function(task_description, Action_for_this_time)
%REWARD_FUNCTION  Computing cost of Eq. (21) as a (negative) reward.
%
%   reward = -beta * scaled energy - (1 - beta) * (average lifespan - required latency).

% income = task_description.price * Action_for_this_time - task_description.alpha * (task_description.ita * Action_for_this_time)^3

Energycost = task_description.alpha * (task_description.ita * Action_for_this_time)^3

ScaledEC = task_description.ScalingEnergy * Energycost

Average_lifespan = task_description.my0(1,1) * task_description.enlargelife 

Dealta_max = task_description.Dealta_max;


reward =  - task_description.beta * ScaledEC - (1 - task_description.beta) * (Average_lifespan - task_description.Dealta_max);




%(Average_lifespan - task_description.Dealta_max)


% if reward < -10
% 
%     reward = -10;
% 
% end