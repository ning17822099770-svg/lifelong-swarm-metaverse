function Trajectory = Trajectory_process(Queue, Length, model_type, server_info, pall, policy, Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3, num_of_trajectory_4, num_of_trajectory_5,num_of_trajectory_6,num_of_trajectory_7,num_of_trajectory_8,num_of_trajectory_9, num_of_trajectory_10, num_of_trajectory_11, num_of_trajectory_12, num_of_trajectory_13, num_of_trajectory_14, num_of_trajectory_15, num_of_trajectory_16, num_of_trajectory_17, num_of_trajectory_18, num_of_trajectory_19)
%TRAJECTORY_PROCESS  Roll out one training episode of a server queue with POLICY.
%
%   For every time step with pending tasks: build the state (TASK_DESCRIPTION), sample the
%   number of tasks to compute (DRAW_ACTION), update the queue (NEXT_STATE) and record the
%   cost of Eq. (21) (REWARD_FUNCTION).

N = 2 * model_type;
M = model_type;


Steps = 1;

action = zeros(size(1,Length));


% Generate task description information for each time step with tasks
for i = 1:Length
    % if ~isempty(Queue(1,i).queue)
    if i >= 1 && i <= numel(Queue)
        if ~isempty(Queue(1,i).queue)

            task_description = Task_description(Queue(1,i).queue, N, M, model_type, i, Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3, num_of_trajectory_4, num_of_trajectory_5,num_of_trajectory_6,num_of_trajectory_7,num_of_trajectory_8,num_of_trajectory_9, num_of_trajectory_10, num_of_trajectory_11, num_of_trajectory_12, num_of_trajectory_13, num_of_trajectory_14, num_of_trajectory_15, num_of_trajectory_16, num_of_trajectory_17, num_of_trajectory_18, num_of_trajectory_19);

            action(1,i) = draw_action(policy,task_description);

            [Queue, Action_for_this_time] = next_state(action(1,i), Queue, server_info, pall, i);

            [reward, ScaledEC, Average_lifespan, Dealta_max] = reward_function(task_description, Action_for_this_time);



            Trajectory.rewards(Steps) = reward;
            Trajectory.ScaledEC(Steps) = ScaledEC;
            Trajectory.Average_lifespan(Steps) = Average_lifespan;

            Trajectory.actions(:,Steps) = action(1,i);
            Trajectory.states(:,Steps) = task_description.my0;
            Trajectory.policy = policy;
            Trajectory.Dealta_max(Steps) = Dealta_max;

           
            Steps = Steps + 1;
        else
            disp('empty_for_this_trajectory');
        end
    end
end


% Initialize policy
% Check if empty
% Generate task description if not empty
% Input for base_learner computation
% Update policy
% Take action
% Pass remaining to next


