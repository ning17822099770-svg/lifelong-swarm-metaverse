function [required_distance, D_max] = required_distance_and_D_max(collection_UAV_location, server_info, current_total_number, matching_indices, data_unit, D_max, zeta)
%REQUIRED_DISTANCE_AND_D_MAX  Rate requirement, maximum offloading and maximum distance.
%
%   For every server of the current type, sets D_max = ceil(#tasks / #servers) + zeta, i.e.
%   the per-slot offloading limit with the reserved buffer margin zeta (Eq. (3)). It returns the
%   maximum distance d_req at which this rate can still be delivered (Eq. (4)).

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

    D_max(1,target_server) = ceil(current_total_number/ size(matching_indices,2)) + zeta;

    source_position = collection_UAV_location;

    % Calculate the distance from the source position to the target position
    current_distance = norm(target_position - source_position);

    currnt_rate = transmission_rate(current_distance, B, P);

    final_rate = data_unit *  D_max(1,target_server);

    % Calculate the result of the formula
    % Eq. (4); the path-loss factor 10^(yita0/20) matches transmission_rate.m
    required_distance = sqrt((P * G) / ((2^(final_rate/B) - 1) * noise_power * B * 10^(yita0 / 20))) * (c / (4 * pi * carrier_f));

    % % Display the result
    % fprintf('Computed distance = %.4f\n', distance);



    %     if currnt_rate < final_rate% If the maximum transmission requirement cannot be met, adjust the position
    %
    %         % Calculate the move vector needed for the target position
    %         move_vector = (target_position - source_position) / current_distance * (current_distance - distance);
    %
    %         % D_max(1,target_server) = ceil(current_total_number/ size(matching_indices,2));
    %
    %         currnt_rate = final_rate;
    %
    %     else
    %
    %         move_vector = 0;
    %         %
    %         % D_max(1,target_server) = ceil(currnt_rate/data_unit);
    %
    %     end
    %
    %     % Calculate the new target position
    %     new_target_position = target_position - move_vector;
    %
    %     rate(j) = currnt_rate;
    %
    %     server_info(target_server, 2:3) = new_target_position;
end

