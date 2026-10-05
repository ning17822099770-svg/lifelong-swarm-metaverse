function [reward, new_rate, slope] = calculate_reward_PSO(position, collection_UAV_location, server_info, server_id, current_location, required_distance, V_max)
%CALCULATE_REWARD_PSO  Mobility reward of one PSO particle (Eqs. (23)-(26)).
%
%   reward = S * Gamma * |moving distance| - R / S - rho - mu - nu, where S is the slope of
%   the rate at the previous distance (CALCULATE_SLOPE), R the A2A rate (TRANSMISSION_RATE),
%   and rho / mu / nu the penalties for exceeding V_max, for leaving the required distance
%   d_req of Eq. (4), and for getting closer than 5 m to another UAV.

collecting_channel_param = containers.Map({'suburban', 'urban', 'dense-urban', 'high-rise-urban'}, ...
    {[4.88, 0.43, 0.1, 21], [9.61, 0.16, 1, 20], [12.08, 0.11, 1.6, 23], [27.23, 0.08, 2.3, 34]});

collecting_params = collecting_channel_param('urban');
a = collecting_params(1);
b = collecting_params(2);
yita0 = collecting_params(3);
yita1 = collecting_params(4);
carrier_f = 2.5e9;
noise_power = 1e-13;

new_position = [position.x, position.y];


% beta = 0.2;

G = 10; % channel gain, same value as in transmission_rate.m
c = 3e8;

type = server_info(server_id, 1);

B = server_info(server_id, 7);

P = server_info(server_id, 4);

% New: Calculate the minimum distance to other UAVs
min_distance_to_other_UAVs = inf;
for i = 1:size(server_info, 1)
    if i ~= server_id
        distance_to_UAV = norm(new_position - server_info(i, 2:3));
        min_distance_to_other_UAVs = min(min_distance_to_other_UAVs, distance_to_UAV);
    end
end

% New: Close distance penalty
close_distance_penalty = 0;
if min_distance_to_other_UAVs < 5 % If the distance to any UAV is less than 5 meters
    close_distance_penalty = -1000;
end

% Penalty factors
distance_penalty_factor = -1000;
overstep_penalty_factor = -1000;
close_far_distance_penalty_factor = 1000;
% close_distance_penalty = 0;% Penalty factor when the particle is too close to collection_UAV_location
% far_distacnce_penalty_factor = -1000;

% Calculate the penalty value to the collection UAV
distanceToCollectionUAV = norm(new_position - collection_UAV_location);
distanceToCurrentLocation = norm(new_position - current_location);

distance_previous_ToCollectionUAV = norm(current_location - collection_UAV_location);

% Calculate the base reward value
new_rate = transmission_rate(distanceToCollectionUAV, B, P);

previous_rate = transmission_rate(distance_previous_ToCollectionUAV, B, P);

% slope = (new_rate - previous_rate)/distanceToCurrentLocation

slope = calculate_slope(previous_rate, B, P, G, carrier_f, noise_power, yita0);


if distanceToCollectionUAV > required_distance
    far_distance_penalty = distance_penalty_factor * abs(distanceToCollectionUAV- required_distance);
else
    far_distance_penalty = 0;
end

% Calculate the penalty value for moving more than V_max
overstep_penalty = overstep_penalty_factor * max(0, distanceToCurrentLocation - V_max);
% k = 5;
% 
% alpha = k * log10(current_rate + 1);

alpha = 1e-4; %5e-4
scaled_factor = 1;

% 0.00001 * abs(slope)

% 
% if distanceToCollectionUAV > required_distance * 3/5
%     reward = (1 - beta) * alpha * new_rate - distance_penalty - overstep_penalty - close_distance_penalty;
% else
% reward = 1e-5 * (beta * slope * distanceToCurrentLocation + (1 - beta) * new_rate) - overstep_penalty - close_distance_penalty - distance_penalty;
% reward = - beta * abs(slope) * 5e-6 * distanceToCurrentLocation + (1 - beta) * alpha * new_rate - overstep_penalty - close_distance_penalty - distance_penalty;
% end


% if the particle is too close to collection_UAV_location
% if distanceToCollectionUAV < (required_distance * 1/6) 
%     close_distance_penalty = 100 * slope;
% end
%     reward = -abs(reward) - close_far_distance_penalty_factor;
% reward = scaled_factor * (beta * slope *  alpha * distanceToCurrentLocation - (1 - beta) * new_rate/slope) + overstep_penalty + far_distance_penalty + close_distance_penalty;

reward = scaled_factor * slope *  alpha * distanceToCurrentLocation - 1 * new_rate/slope + overstep_penalty + far_distance_penalty + close_distance_penalty;
%     reward = reward + distanceToCurrentLocation;
% else 
%     reward = scaled_factor * (beta * slope * distanceToCurrentLocation + (1 - beta) * new_rate) - overstep_penalty - close_distance_penalty - distance_penalty;
% end



