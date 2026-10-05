function [ELLAmodel]=updatePGELLA(ELLAmodel, taskId, HessianArray, ParameterArray)
%UPDATEPGELLA  Update the lifelong-learning knowledge base (PG-ELLA, Eqs. (37)-(39)).
%
%   Takes a gradient step on the shared latent basis L, then re-computes the sparse task code
%   s_t of TASKID with a Lasso (SOLVE_LASSO), given the Hessians and the policy parameters
%   learned by the base learner.

% Having determined the allowed tasks, compute the derivative 


sum = zeros(size(ELLAmodel.L));

% Tg=size(allowedTaskIndexG{find(GroupsPresent==Tasks(taskId).param.Group)},1);
Tg = size(ELLAmodel.S,2);

for i=1: Tg

    sum = sum - 2 * HessianArray(i).D * ParameterArray(i).alpha * ELLAmodel.S(:,i)' ...
            + 2 * HessianArray(i).D * ELLAmodel.L * ELLAmodel.S(:,i) * ELLAmodel.S(:,i)' ...
            + 2 * ELLAmodel.mu_two * ELLAmodel.L; 
end

ELLAmodel.L = (ELLAmodel.L-ELLAmodel.learningRate * 1./Tg * sum);

%--------------------------------------------------------------------------
% Update s_{taskId} using LASSO
%--------------------------------------------------------------------------
% Determine which group taskId belongs to 
% Dsqrt = HessianArray(taskId).D^.5;


Dsqrt = sqrtm(HessianArray(taskId).D);

Dsqrt = abs(Dsqrt);

target = Dsqrt*ParameterArray(taskId).alpha;

dictTransformed = Dsqrt * ELLAmodel.L;
% 


s = full( ...
        solve_lasso( ...
        target,dictTransformed,struct('lambda',ELLAmodel.mu_one/2) ...
        ) ...
    )


ELLAmodel.S(:,taskId)=s; 

