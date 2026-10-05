%RUN_ONLINE_LIFELONG  Online UAV-swarm Metaverse with lifelong learning (PSO-LDF-LL, Algorithm 4).
%
%   Same swarm, mobility (PSO-CEMA) and task allocation (LDF-DPTAA) as
%   RUN_ONLINE_BASE_LEARNER. The computing policies of the UAV servers are generated from
%   the pre-trained knowledge base (theta = L * s_k, one policy per server type) and refined
%   online. After each hovering position tau, the central UAV updates L and s_k from the MDP
%   information of all servers of the same type (Algorithm 3, LL-CJTPA, lines 24-34).
%
%   Normally invoked at the end of RUN_ONLINE_BASE_LEARNER. It saves both results:
%     outputs/results/mean_new_system_{LL,base}_<zeta>.mat      (penalty, lifespan, energy, queue)
%     outputs/results/loss_for_allocation_{LL,base}_<zeta>.mat  (task-allocation reward)
%
%   Requires modelsPGELLA in the workspace (loaded from data/pretrained if missing).
%
%   See also RUN_ONLINE_BASE_LEARNER, UPDATEPGELLA, COMPARE_ONLINE_RESULTS.

if isempty(gcp('nocreate'))
    parpool; 
end


% Lifelong-learning knowledge base L, S pre-trained in the central collection UAV (training/run_training_lifelong.m)
if ~exist('modelsPGELLA', 'var')
    load(fullfile(repo_root(), 'data', 'pretrained', 'modelsPGELLA.mat'), 'modelsPGELLA');
end

T = 50; %50
num_of_servers = 25;
data_unit = 2000;

types = 5;
model_type = 1;

gamma = 0.99;
hessScal = 1;
learningRate = 0.002; %0.001
map_size = 1000;
map = [map_size, map_size];
v_col = 10;
direction = [1, 0];
if ~exist('zeta', 'var'), zeta = 5; end  % reserved buffer margin zeta in Eq. (3); preset it to sweep (see sweep_zeta.m)


num_of_trajectory_total = 100; %100
num_of_trajectory_1 = 100;
num_of_trajectory_2 = 1500;
num_of_trajectory_3 = 1500;
num_of_trajectory_4 = 2000;
num_of_trajectory_5 = 1000;
num_of_trajectory_6 = 1200;
num_of_trajectory_7 = 1400;
num_of_trajectory_8 = 1600;
num_of_trajectory_9 = 1800;

num_steps = num_of_trajectory_total;

policy_new = struct('theta', cell(1, types));

dJdTheta = struct('djdtheta', cell(1, types)); 

matching_indices = struct('index', cell(1, types));

Average_reward = zeros(num_of_trajectory_total, num_of_servers);
Processing_queue_length = zeros(num_of_trajectory_total, num_of_servers);
Dealta_max = zeros(num_of_trajectory_total, types);

Average_Averagelifespan = zeros(num_of_trajectory_total, num_of_servers);
Average_ScaledEC = zeros(num_of_trajectory_total, num_of_servers);


for i = 1:types
    policy_new(i).theta = [];
    dJdTheta(i).djdtheta = [];
end


mean_new_system_LL = struct('reward', [], 'Averagelifespan', [], 'ScaledEC', [], 'queue_length', []);


for current_type = 1:types
    mean_new_system_LL(current_type).reward = [];
    mean_new_system_LL(current_type).Averagelifespan = [];
    mean_new_system_LL(current_type).ScaledEC = [];
    mean_new_system_LL(current_type).queue_length = [];
end

class_server_info = zeros(num_of_servers, 2);

D_max = zeros(1, num_of_servers);

collection_UAV_location = [map_size/4, map_size/2];

% class_labels = zeros(num_of_servers, 1);
loss_for_allocation_LL = zeros(num_of_trajectory_total, T);

loss_for_UAV_moving = zeros(num_of_trajectory_total, 1);


server_info_previous = [];

for Trajectory_id = 1:num_of_trajectory_total

    if (collection_UAV_location(1) == map_size/4) || (collection_UAV_location(1) == map_size*3/4) 

        rate = zeros(1, num_of_servers);

        bestreward = zeros(1, num_of_servers);

        slope = zeros(1, num_of_servers);

        % collection_UAV_location = [map_size/4, map_size/2];

        server_info = server_generation(num_of_servers, collection_UAV_location, types);


        [collection_UAV_location, direction] = moveInSquareMap(collection_UAV_location, map, v_col, direction);

    else
        server_info = server_info_previous;


        [collection_UAV_location, direction] = moveInSquareMap(collection_UAV_location, map, v_col, direction);

        for current_type = 1:types


            matching_indices(current_type).index = findMatchingIndices(current_type, server_info);

            [server_info, bestreward, rate, slope] = PSO_update_location(server_info, matching_indices(current_type).index, map_size, collection_UAV_location, average_required_distance(current_type), bestreward, rate, slope);

            loss_for_UAV_moving(Trajectory_id, 1) = sum(bestreward);
        end
    % 
    end
    % 

    plotLocations(collection_UAV_location, server_info, Trajectory_id);


    total_required_distance = zeros(1, types);
    total_D_max = zeros(1, types);
    count_required_distance = zeros(1, types);

    H = zeros(1, num_of_servers);
    Q = zeros(1, num_of_servers);

    Trajectory = struct('trajectory', cell(1, num_of_servers));

    collection_queue = struct('queue', []);

    Processing_queue = struct('queue', cell(1, num_of_servers));

    for i = 1:num_of_servers
        Processing_queue(i).queue = [];
    end

    N = model_type * 2;
    M = model_type;

    if (Trajectory_id == 1)
        for i = 1:types
            policy_new(i) = init_gauss_policy(N, M);
            % policy_new(i) = policy;
            policy_new(i).theta.k = modelsPGELLA(M).model.L * modelsPGELLA(M).model.S(:, i);
        end

        % for server_id = 1:num_of_servers
        %     class_labels(server_id,1) = server_info(server_id, 1);
        % end
    end

    for t = 1:T      

        if t == 1
            Steps = ones(1,num_of_servers);
        end

        [new_tasks, model_type, task_ID] = task_generation(t, Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3, num_of_trajectory_4, num_of_trajectory_5,num_of_trajectory_6,num_of_trajectory_7,num_of_trajectory_8,num_of_trajectory_9);

        collection_queue.queue = [collection_queue.queue; new_tasks];

         if ~isempty(collection_queue.queue) 
                
             collection_queue.queue = sortrows(collection_queue.queue, [1, 3]);

             [unique_values, row_counts] = countUniqueValues(collection_queue.queue); % count the task types in the queue and the number of tasks of each type

             for i = 1:size(unique_values,1)
                 current_type = unique_values(i,1); 
                 current_total_number = row_counts(i,1); 

                 matching_indices(current_type).index = findMatchingIndices(current_type, server_info);

                 [required_distance(current_type), D_max] = required_distance_and_D_max(collection_UAV_location, server_info, current_total_number, matching_indices(current_type).index, data_unit, D_max, zeta);
                 
                 total_required_distance(current_type) = total_required_distance(current_type) + required_distance(current_type);
                 total_D_max(current_type) = total_D_max(current_type) + D_max(current_type);
                 count_required_distance(current_type) = count_required_distance(current_type) + 1;

                 [D, loss_min] = lyapunov_task_allocation(num_of_servers, current_total_number, matching_indices(current_type).index, rate, D_max, H, Q, server_info, data_unit)

                 loss_for_allocation_LL(Trajectory_id, t) = loss_for_allocation_LL(Trajectory_id, t) + loss_min;

                 for j = 1:size(matching_indices(current_type).index,2)
                     target_server = matching_indices(current_type).index(j);
                     [collection_queue.queue, Processing_queue(target_server).queue] =  processQueues(collection_queue.queue, Processing_queue(target_server).queue, current_type, D(j));
                     H(1, target_server) = H(1,target_server) + D(j);
                     Q(1, target_server) = Q(1, target_server) + D(j);
                 end
             end
         end


    
        for server_id = 1: num_of_servers
            if ~isempty(Processing_queue(server_id).queue)
                Processing_queue(server_id).queue = sortrows(Processing_queue(server_id).queue, [1, 3]);
                % policy_type = class_labels(server_id, 1);
            end
            policy_type = server_info(server_id,1);
            % policy_type = server_id;
            % policy_type = 1;
            [Trajectory(server_id).trajectory, Processing_queue(server_id).queue, Steps(server_id), H, Q] = Trajectory_process(D_max, t, H, Q, Trajectory(server_id).trajectory, Processing_queue(server_id).queue, model_type, server_info, server_id, policy_new(policy_type), Steps(server_id), Trajectory_id, num_of_trajectory_1, num_of_trajectory_2, num_of_trajectory_3 ,num_of_trajectory_4, num_of_trajectory_5, num_of_trajectory_6, num_of_trajectory_7, num_of_trajectory_8, num_of_trajectory_9);
            % end
        end
    end


    average_required_distance = total_required_distance ./ count_required_distance;
    average_D_max = total_D_max ./ count_required_distance;


    server_info_previous = server_info;

    for j = 1:types
        pall_lines = [];
        for server_id = 1:num_of_servers
            % if class_labels(server_id, 1) == j
            if server_info(server_id,1) == j
            % if server_id == j
                pall_lines = [pall_lines, server_id];
                Dealta_max(Trajectory_id, j) = mean(Trajectory(server_id).trajectory.Dealta_max);
            end
            Average_reward(Trajectory_id, server_id) = mean(Trajectory(server_id).trajectory.rewards);  
            Average_Averagelifespan(Trajectory_id,server_id) = mean(Trajectory(server_id).trajectory.Average_lifespan);
            Average_ScaledEC(Trajectory_id,server_id) = mean(Trajectory(server_id).trajectory.ScaledEC);
            Processing_queue_length(Trajectory_id, server_id) = mean(Trajectory(server_id).trajectory.queue);
            % Dealta_max(Trajectory_id, server_id) = mean(Trajectory(server_id).trajectory.Dealta_max);
        end
        % if  ~isempty(pall_lines)
        dJdTheta(j).djdtheta = ENAC(policy_new(j), Trajectory, M, N, gamma, pall_lines);
        policy_new(j).theta.k = policy_new(j).theta.k + 1 * learningRate * dJdTheta(j).djdtheta;

        HessianArray(j).D = computeHessianArray(Trajectory, gamma, hessScal, policy_new(j).theta.sigma, pall_lines);

        ParameterArray(j).alpha = policy_new(j).theta.k;
        % 
        % modelsPGELLA(M).model = updatePGELLA(modelsPGELLA(M).model, j, HessianArray, ParameterArray);    
    end

    for j = 1:types
        modelsPGELLA(M).model = updatePGELLA(modelsPGELLA(M).model, j, HessianArray, ParameterArray);    
    end
        

end



figure;


legend_info_reward = cell(1, types);
legend_info_Averagelifespan = cell(1, types);
legend_info_ScaledEC = cell(1, types);
legend_info_queue_length = cell(1, types);


subplot(2, 2, 1);
title('Mean Reward for lya system');
xlabel('Eposides');
ylabel('Mean Reward for 5 servers');
hold on;

subplot(2, 2, 2);
title('Mean Average lifespan for lya system');
xlabel('Eposides');
ylabel('Mean Average_lifespan for 5 servers');
hold on;

subplot(2, 2, 3);
title('Mean ScaledEC for lya system');
xlabel('Eposides');
ylabel('Mean ScaledEC for 5 servers');
hold on;

subplot(2, 2, 4);
title('Mean queue length for lya system');
xlabel('Eposides');
ylabel('Mean queue length for 5 servers');
hold on;

for current_type = 1:types
    selected_columns_reward = Average_reward(:, matching_indices(current_type).index);
    selected_columns_Averagelifespan = Average_Averagelifespan(:, matching_indices(current_type).index);
    selected_columns_ScaledEC = Average_ScaledEC(:, matching_indices(current_type).index);
    selected_columns_queue_length = Processing_queue_length(:, matching_indices(current_type).index);

    mean_new_system_LL(current_type).reward = mean(selected_columns_reward, 2); 
    mean_new_system_LL(current_type).Averagelifespan = mean(selected_columns_Averagelifespan, 2); 
    mean_new_system_LL(current_type).ScaledEC = mean(selected_columns_ScaledEC, 2); 
    mean_new_system_LL(current_type).queue_length = mean(selected_columns_queue_length, 2);

    subplot(2, 2, 1);
    plot(1:length(mean_new_system_LL(current_type).reward), mean_new_system_LL(current_type).reward);
    legend_info_reward{current_type} = ['Reward Type ' num2str(current_type)];

    subplot(2, 2, 2);
    plot(1:length(mean_new_system_LL(current_type).Averagelifespan), mean_new_system_LL(current_type).Averagelifespan);
    legend_info_Averagelifespan{current_type} = ['Average lifespan Type ' num2str(current_type)];

    subplot(2, 2, 3);
    plot(1:length(mean_new_system_LL(current_type).ScaledEC), mean_new_system_LL(current_type).ScaledEC);
    legend_info_ScaledEC{current_type} = ['ScaledEC Type ' num2str(current_type)];

    subplot(2, 2, 4);
    plot(1:length(mean_new_system_LL(current_type).queue_length), mean_new_system_LL(current_type).queue_length);
    legend_info_queue_length{current_type} = ['Queue Length Type ' num2str(current_type)];
end

subplot(2, 2, 1);
legend(legend_info_reward);
title('Mean Reward for lya system');
xlabel('Eposides');
ylabel('Mean Reward for 5 servers');
hold off;

subplot(2, 2, 2);
legend(legend_info_Averagelifespan);
title('Mean Average lifespan for lya system');
xlabel('Eposides');
ylabel('Mean Average lifespan for 5 servers');
hold off;

subplot(2, 2, 3);
legend(legend_info_ScaledEC);
title('Mean ScaledEC for lya system');
xlabel('Eposides');
ylabel('Mean ScaledEC for 5 servers');
hold off;

subplot(2, 2, 4);
legend(legend_info_queue_length);
title('Mean queue length for lya system');
xlabel('Eposides');
ylabel('Mean queue length for 5 servers');
hold off;


% save('mean_new_system_LL.mat', 'mean_new_system_LL_{zeta}');
% save('mean_new_system_base.mat', 'mean_new_system_base_{zeta}');
% 
% save('loss_for_allocation_LL.mat', 'loss_for_allocation_LL_{zeta}');
% save('loss_for_allocation_base.mat', 'loss_for_allocation_base_{zeta}');



filename_mean_new_system_LL = sprintf('mean_new_system_LL_%d.mat', zeta);
filename_mean_new_system_base = sprintf('mean_new_system_base_%d.mat', zeta);
filename_loss_for_allocation_LL = sprintf('loss_for_allocation_LL_%d.mat', zeta);
filename_loss_for_allocation_base = sprintf('loss_for_allocation_base_%d.mat', zeta);


save(fullfile(output_dir('results'), filename_mean_new_system_LL), 'mean_new_system_LL');
save(fullfile(output_dir('results'), filename_mean_new_system_base), 'mean_new_system_base');
save(fullfile(output_dir('results'), filename_loss_for_allocation_LL), 'loss_for_allocation_LL');
save(fullfile(output_dir('results'), filename_loss_for_allocation_base), 'loss_for_allocation_base');



