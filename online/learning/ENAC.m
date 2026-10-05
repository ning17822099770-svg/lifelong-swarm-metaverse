function w = ENAC(policy, Trajectory, M, N, gamma, pall_lines)
%ENAC  Episodic Natural Actor-Critic gradient (base learner, Peters & Schaal 2008).
%
%   W = ENAC(POLICY, TRAJECTORY, M, N, GAMMA, PALL_LINES) returns the natural policy gradient
%   estimated from the trajectories of the servers listed in PALL_LINES.

% The code first initializes some variables 
% such as gamma (the discount factor), N (the number of states), 
% M (the number of actions), and J (the expected return). 

% OBTAIN EXPECTED RETURN
J = 0;

% Then it loops over the data, which is a structure array 
% that contains the state, action, and reward sequences for each episode.
% OBTAIN GRADIENTS
% It stores these values in two matrices: Mat and Vec.
i=1;  
for j = 1 : size(pall_lines)
    
    pall = pall_lines(j);

    Mat(i,:) = [zeros( ...
        size( ...
            DlogPiDThetaNAC( ...
                policy, Trajectory(pall).trajectory.states(:,1),Trajectory(pall).trajectory.actions(:,1),N,M)' ...
            ) ...
         ) 1 ];
    Vec(i,1) = 0; 
    
    for Steps = 1 : max(size(Trajectory(pall).trajectory.actions))

        % For each episode, it computes the gradient of the log-likelihood 
        % of the policy with respect to the policy parameters 
        % using a helper function called DlogPiDThetaNAC. 
        Mat(i,:) = Mat(i,:) + gamma^(Steps-1)*[
            DlogPiDThetaNAC(policy, Trajectory(pall).trajectory.states(:,Steps),Trajectory(pall).trajectory.actions(:,Steps),N,M)' 0];
        % It also computes the temporal difference error 
        % between the actual and expected rewards.
        Vec(i,1) = Vec(i,1) + gamma^(Steps-1)*(Trajectory(pall).trajectory.rewards(Steps)-J);
    end
    i = i+1;  
end

cond(Mat);
std_Mat = std(Mat(:, 1: N*M), 0, 1);
% Set the standard deviation of all columns with a standard deviation of 0 to 1
std_Mat(std_Mat == 0) = 1;


% After looping over all episodes, it normalizes the columns
% of Mat using their standard deviations to avoid numerical issues.
% Nrm is the regularization matrix.
Nrm = diag([1 ./ std_Mat, 1]);
Nrm(Nrm == 0) = 0.0001;
% Nrm = diag([1 ./ std(Mat(:, 1: (N+1)), 0, 1), 1]);

% Then it solves a linear system of equations
% to find w using matrix inversion.
grad = (Mat'*Vec);
% w = (Nrm/(Nrm*Mat'*Mat*Nrm)*Nrm) * grad;

% It discards the last element of w,
% which corresponds to an extra bias term added in Mat.
% w = w(1:(max(size(w)-1)));

F = Nrm*Mat'*Mat*Nrm;
% cond(F);
% F = round(F, 8);
% inv_F = inv(F);
% w = Nrm*inv_F*Nrm*grad;
% w = w(1:(max(size(w)-1)));
% 
% Assume your original matrix is F
% Regularization parameter (adjust as needed)
lambda = 2e-5; %5e-6

% Calculate regularization matrix
reg_matrix = lambda * eye(size(F));

% Add regularization term
F_reg = F + reg_matrix;
% F_reg = F;
% Invert matrix
inv_F_reg = inv(F_reg);

% Calculate weights
w = Nrm * inv_F_reg * Nrm * grad;
w = w(1:(max(size(w) - 1)));

