function [action] = draw_action(policy,task_description)
%DRAW_ACTION  Sample an action from the linear Gaussian policy a ~ N(theta.' * x, sigma).
% Based on Jan Peters' code.

x = task_description.my0;
action = mvnrnd((reshape(policy.theta.k, task_description.N, task_description.M)'*x)', policy.theta.sigma);

assert(~any(isnan(action)), 'Action is NaN');