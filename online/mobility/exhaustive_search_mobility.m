function [server_info, bestreward, rate, slope] = exhaustive_search_mobility(server_info, matching_indices, MAPSIZE, collection_UAV_location, required_distance, bestreward, rate, slope)
%EXHAUSTIVE_SEARCH_MOBILITY  Grid-search reference for PSO-CEMA (same reward, same outputs).
%
%   Optional benchmark for PSO_UPDATE_LOCATION; it is commented out in the run scripts by
%   default because it is slow.

% Preallocate variables for parallel computation
num_indices = size(matching_indices, 2);
max_reward = -Inf(1, num_indices);
max_reward_point = cell(1, num_indices);
local_rate_array = zeros(1, num_indices);
local_slope_array = zeros(1, num_indices);
position = struct('x', cell(1, num_indices), 'y', cell(1, num_indices));

% Run PSO-exhaustive search algorithm for each server
parfor j = 1:num_indices
    server_id = matching_indices(j);
    V_max = server_info(server_id, 8);
    current_location = [server_info(server_id, 2), server_info(server_id, 3)];
    local_max_reward = -Inf;
    local_max_reward_point = [NaN, NaN];
    local_rate = 0;
    local_slope = 0;

    % Iterate over each point within the circle
    for x = (current_location(1) - V_max):0.1:(current_location(1) + V_max)
        for y = (current_location(2) - V_max):0.1:(current_location(2) + V_max)
            % Check if the point is within the circle
            if sqrt((x - current_location(1))^2 + (y - current_location(2))^2) <= V_max
                % Create a position struct
                position = struct('x', x, 'y', y);

                % Calculate reward and update the best position
                [reward, temp_rate, temp_slope] = calculate_reward_PSO(position, collection_UAV_location, server_info, server_id, current_location, required_distance, V_max);

                % If the reward of the current point is greater than the previous maximum, update the maximum reward and coordinates
                if reward > local_max_reward
                    local_max_reward = reward;
                    local_max_reward_point = [x, y];
                    local_rate = temp_rate;
                    local_slope = temp_slope;
                end
            end
        end
    end

    max_reward(j) = local_max_reward;
    max_reward_point{j} = local_max_reward_point;
    local_rate_array(j) = local_rate;
    local_slope_array(j) = local_slope;
end

% After the PSO algorithm is completed, update the server information and rewards
for j = 1:num_indices
    server_id = matching_indices(j);
    newPoint = max_reward_point{j};
    bestreward(server_id) = max_reward(j);
    rate(server_id) = local_rate_array(j);
    slope(server_id) = local_slope_array(j);

    server_info(server_id, 2) = newPoint(1);
    server_info(server_id, 3) = newPoint(2);
end
end
