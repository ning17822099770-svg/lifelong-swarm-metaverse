function server_info = server_generation(number_of_servers, collection_UAV_location, types)
%SERVER_GENERATION  Create the UAV servers around the collection UAV.
%
%   Row layout of SERVER_INFO: [type, x, y, power P (W), max tasks per slot epsilon_max,
%   min tasks, bandwidth B (Hz), max speed V_max (m/s)]. The parameters per type follow
%   Table II.
    % Initialize the server information array
    server_info = zeros(number_of_servers, 8); % Each row includes server type, X coordinate, Y coordinate, power value

    % Determine the number of servers for each type
    % num_servers_per_type = number_of_servers / types;

    V_max = 20;
    for server_id = 1:number_of_servers
        % Calculate the server type (1, 2, 3, 4)
        server_type = mod(server_id - 1, types) + 1;

        % Set the power value based on the server type
        switch server_type
            case 1
                power_value = 0.1;
                max_limit = 70; % 30
                min_limit = 0;
                B = 1e6;
                d = 150;
            case 2
                power_value = 0.4;
                max_limit = 70;
                min_limit = 0;
                B = 4e6;
                d = 150;
            case 3
                power_value = 0.3;
                max_limit = 70;   % learned well        
                min_limit = 0;
                B = 3e6;
                d = 150;
            case 4
                power_value = 0.2;
                max_limit = 70;
                min_limit = 0;
                B = 2e6;
                d = 150;
            case 5
                power_value = 0.5;
                max_limit = 70;
                min_limit = 0;
                B = 5e6;
                d = 150;
        end

        x0 = collection_UAV_location(1);
        y0 = collection_UAV_location(2);

        % Generate a random angle
        theta = 2 * pi * rand();

        % Generate a random radius, not exceeding d
        r = d/5 + d * 4/5 * sqrt(rand());

        % Calculate the new point's x and y coordinates
        x_coordinate = x0 + r * cos(theta);
        y_coordinate = y0 + r * sin(theta);


        % Store the information in the array
        server_info(server_id, 1) = server_type;
        server_info(server_id, 2) = x_coordinate;
        server_info(server_id, 3) = y_coordinate;
        server_info(server_id, 4) = power_value;
        server_info(server_id, 5) = max_limit;
        server_info(server_id, 6) = min_limit;
        server_info(server_id, 7) = B;
        server_info(server_id, 8) = V_max;

    end
end
