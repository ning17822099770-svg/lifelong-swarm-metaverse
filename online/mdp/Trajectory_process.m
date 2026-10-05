function [Trajectory, queue, Steps, H, Q] = Trajectory_process(D_max, t, H, Q, Trajectory, queue, model_type, server_info, server_id, policy, Steps, Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3 ,num_of_trajectory_4, num_of_trajectory_5, num_of_trajectory_6, num_of_trajectory_7, num_of_trajectory_8, num_of_trajectory_9)
%TRAJECTORY_PROCESS  One time step of a UAV server: observe state, act, update queues, log reward.
%
%   Draws the number of tasks to compute from the server's Gaussian policy (DRAW_ACTION),
%   updates the processing/virtual queues (NEXT_STATE, Eqs. (14)-(15)), computes the cost of
%   Eq. (21) (REWARD_FUNCTION) and appends everything to the episode TRAJECTORY.

N = 2 * model_type;
M = model_type;


if ~isempty(queue)

    task_description = Task_description(server_info, server_id, queue, N, M, model_type, t, Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3,num_of_trajectory_4, num_of_trajectory_5, num_of_trajectory_6, num_of_trajectory_7, num_of_trajectory_8, num_of_trajectory_9);

    action = draw_action(policy,task_description);

    Trajectory.queue(Steps) = size(queue,1); 

    [queue, Action_for_this_time, H, Q] = next_state(D_max, action, queue, server_info, server_id, H, Q);

    [reward, ScaledEC, Average_lifespan, Dealta_max] = reward_function(task_description, Action_for_this_time);



    Trajectory.rewards(Steps) = reward;
    Trajectory.ScaledEC(Steps) = ScaledEC;
    Trajectory.Average_lifespan(Steps) = Average_lifespan;



    Trajectory.actions(:,Steps) = action;
    Trajectory.states(:,Steps) = task_description.my0;
    Trajectory.policy = policy;
    Trajectory.Dealta_max(Steps) = Dealta_max;

    Steps = Steps + 1;

end








