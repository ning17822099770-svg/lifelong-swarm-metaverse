function [server_info, rate, bestreward, slope] = location_change(collection_UAV_location, server_info, matching_indices, rate, required_distance, bestreward, slope)
%LOCATION_CHANGE  Mobility baseline without optimisation ("w/o mobility" in Figs. 6-7).
%
%   Each UAV server moves straight towards the collection UAV, just far enough to meet its
%   required distance.

collecting_channel_param = containers.Map({'suburban', 'urban', 'dense-urban', 'high-rise-urban'}, ...
    {[4.88, 0.43, 0.1, 21], [9.61, 0.16, 1, 20], [12.08, 0.11, 1.6, 23], [27.23, 0.08, 2.3, 34]});

collecting_params = collecting_channel_param('urban');
a = collecting_params(1);
b = collecting_params(2);
yita0 = collecting_params(3);
yita1 = collecting_params(4);
carrier_f = 2.5e9;
noise_power = 1e-13;


G = 10;
c = 3e8;


for j = 1:size(matching_indices,2)

    target_server = matching_indices(j);

    B = server_info(target_server, 7);

    target_position = server_info(target_server, 2:3);

    P = server_info(target_server,4);

    V_max = server_info(target_server, 8);

    % D_max(1,target_server) = ceil(current_total_number/ size(matching_indices,2)) + 5;

    source_position = collection_UAV_location;

    % Compute the distance from source position to target position
    current_distance = norm(target_position - source_position);

    currnt_rate = transmission_rate(current_distance, B, P);

    final_rate = transmission_rate(required_distance, B, P);

    slope(1,target_server) = calculate_slope(currnt_rate, B, P, G, carrier_f, noise_power, yita0);

    if current_distance > required_distance % If the maximum transmission requirement is not met, adjust the position

        % Calculate the vector needed to move to the target position
        move_vector = (target_position - source_position) / current_distance * (current_distance - required_distance);

    else
        move_vector = 0;
    end

    % Calculate the new target position
    new_target_position = target_position - move_vector;

    distanceToCollectionUAV = norm(new_target_position - collection_UAV_location);
    distanceToCurrentLocation = norm(new_target_position - target_position);

    if distanceToCollectionUAV > 3/4 * required_distance
        far_distance_penalty =  -0.5 * (distanceToCollectionUAV - 3/4 * required_distance);
    else
        far_distance_penalty = 0;
    end

    alpha = 1e-4; % Tune this value as needed
    scaled_factor = 1;

    rate(target_server) = transmission_rate(distanceToCollectionUAV, B, P);

    server_info(target_server, 2:3) = new_target_position;

    reward = scaled_factor * slope(1,target_server) *  alpha * distanceToCurrentLocation - 1 * rate(target_server)/slope(1,target_server) + far_distance_penalty;

    bestreward(target_server) = reward;

end
