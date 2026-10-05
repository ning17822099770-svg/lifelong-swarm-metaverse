function server_info = server_generation(number_of_servers)
%SERVER_GENERATION  Create the simulated UAV-server queues used for training.
%
%   Row layout of SERVER_INFO: [type, x, y, power P (W), max tasks per slot epsilon_max,
%   min tasks]. Positions are irrelevant during training, which only simulates the queues.
    % Initialize the array for server information
    server_info = zeros(number_of_servers, 6); % Each row includes server type, X-coordinate, Y-coordinate, power value

    % Map size
    map_size = 500;

    % Determine the number of servers per type
    num_servers_per_type = number_of_servers / 4;

    for server_id = 1:number_of_servers
        % Calculate the server type (1, 2, 3, 4)
        server_type = mod(server_id - 1, 4) + 1;

        % Generate random coordinates
        x_coordinate = randi([1, map_size]);
        y_coordinate = randi([1, map_size]);

        % Set power value based on server type
        switch server_type
            case 1
                power_value = 0.1;
                max_limit = 70; % 30
                min_limit = 0;
            case 2
                power_value = 0.2;
                max_limit = 70;
                min_limit = 0;
            case 3
                power_value = 0.3;
                max_limit = 70; % max_limit = 80;
                min_limit = 0;
            case 4
                power_value = 0.4;
                max_limit = 70;
                min_limit = 0;
        end

        % Store the information in the array
        server_info(server_id, 1) = server_type;
        server_info(server_id, 2) = x_coordinate;
        server_info(server_id, 3) = y_coordinate;
        server_info(server_id, 4) = power_value;
        server_info(server_id, 5) = max_limit;
        server_info(server_id, 6) = min_limit;
    end
end
