function [Hessian] = computeHessianArray(Trajectory, gamma, hessScal, sigma, pall_lines)
%COMPUTEHESSIANARRAY  Hessian H_t of the policy objective for task t (used in Eq. (36)).

nRollouts = length(pall_lines); 
Hes = zeros(2, 2);
sigma = max(sigma, 0.00001);

% Iterate through each trajectory
for j = 1:nRollouts
    
    i = pall_lines(j);

    % lengthTraj = length(data(i).r);
    scaledLifespan = Trajectory(i).trajectory.states(1, :); 
    scaledLefttasks = Trajectory(i).trajectory.states(2, :); 
    
    lifespanSquare = sum(scaledLifespan.^2);
    Lefttasks_Square = sum(scaledLefttasks.^2);
    Span_tasks = sum(scaledLifespan .* scaledLefttasks); 
    % disp([AoISquare AoICycs; AoICycs LeftCycsSquare])

    Rewards = Trajectory(i).trajectory.rewards(1, :); 

    T = length(Rewards);  % Number of time steps
    G = 0;                % Initialize cumulative discounted reward to 0

    % Traverse time steps, calculate cumulative discounted reward
    for t = 1:T
        G = G + gamma^(t - 1) * Rewards(t);
    end
    RewardDum = G / T;

    

    Matrix = 1 ./ 1 * ([lifespanSquare Span_tasks; Span_tasks Lefttasks_Square] * RewardDum * hessScal);
    %Matrix = ([PosSquare PosVel; PosVel VelSquare]*RewardDum);
    % disp(Matrix)
    Hes = Hes + Matrix; 
end

Hessian = -Hes * 1 ./ nRollouts;
% Hessian = min(Hessian, 1e4);
