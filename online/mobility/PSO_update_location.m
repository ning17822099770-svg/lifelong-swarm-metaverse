function [server_info, bestreward, rate, slope] = PSO_update_location(server_info, matching_indices, MAPSIZE, collection_UAV_location, required_distance, bestreward, rate, slope)
%PSO_UPDATE_LOCATION  PSO-based collection-edge mobility algorithm (PSO-CEMA, Algorithm 1).
%
%   For every UAV server in MATCHING_INDICES, runs a particle swarm (nPop = 50 particles,
%   MaxIt = 100 iterations, Eqs. (27)-(30)) to find the next hovering position that maximises
%   the mobility reward of Eq. (23) (CALCULATE_REWARD_PSO), and writes it to SERVER_INFO.
%
%   See also CALCULATE_REWARD_PSO, REQUIRED_DISTANCE_AND_D_MAX.
% Parameters for PSO algorithm
MaxIt = 100; % Maximum number of iterations
nPop = 50; % Number of particles
w_initial = 1; % Initial inertia weight
wdamp = 0.98; % Inertia weight damping ratio
c1 = 1.5; % Individual learning factor
c2 = 1.5; % Social learning factor
VelMax_x = 0.1 * MAPSIZE; % Maximum velocity along x-axis
VelMax_y = 0.1 * MAPSIZE; % Maximum velocity along y-axis
VelMin_x = -VelMax_x; % Minimum velocity along x-axis
VelMin_y = -VelMax_y; % Minimum velocity along y-axis
VarMax = MAPSIZE; % Maximum position value
VarMin = 1; % Minimum position value

% Initialize global best solution array
GlobalBests = repmat(struct('Position', [], 'reward', -inf, 'rate', 0, 'slope', 0), size(matching_indices, 2), 1);

% Run PSO algorithm for each server
parfor j = 1:size(matching_indices, 2)
    server_id = matching_indices(j);
    V_max = server_info(server_id, 8);
    current_location = [server_info(server_id, 2), server_info(server_id, 3)];

    % Initialize particles and global best
    particles = repmat(struct('Position', struct('x', 0, 'y', 0), ...
        'Velocity', struct('x', 0, 'y', 0), ...
        'reward', -inf, ...
        'rate', 0, ...
        'slope', 0, ...
        'Best', struct('Position', struct('x', 0, 'y', 0), 'reward', -inf, 'rate', 0, 'slope', 0)), nPop, 1);
    GlobalBest = struct('Position', struct('x', 0, 'y', 0), 'reward', -inf, 'rate', 0, 'slope', 0);

    % Main loop of PSO algorithm
    for it = 1:MaxIt
        w = w_initial * wdamp^(it-1);

        for i = 1:nPop
            isValid = false;
            attempts = 0;
            maxAttempts = 10; % Maximum attempts to prevent infinite loop

            while ~isValid && attempts < maxAttempts
                % Initialize newVelocity and newPosition inside the loop
                newVelocity = struct('x', 0, 'y', 0);
                newPosition = struct('x', 0, 'y', 0);
                % Calculate new velocity
                newVelocity.x = w * particles(i).Velocity.x ...
                    + c1 * rand() * (particles(i).Best.Position.x - particles(i).Position.x) ...
                    + c2 * rand() * (GlobalBest.Position.x - particles(i).Position.x);
                newVelocity.y = w * particles(i).Velocity.y ...
                    + c1 * rand() * (particles(i).Best.Position.y - particles(i).Position.y) ...
                    + c2 * rand() * (GlobalBest.Position.y - particles(i).Position.y);

                % Predict new position
                newPosition.x = particles(i).Position.x + newVelocity.x;
                newPosition.y = particles(i).Position.y + newVelocity.y;

                % Check if the new position satisfies the conditions
                isPointValid = (newPosition.x >= VarMin && newPosition.x <= VarMax) && ...
                    (newPosition.y >= VarMin && newPosition.y <= VarMax);

                if isPointValid || attempts == maxAttempts - 1
                    isValid = true;
                    % Apply velocity and position limits
                    particles(i).Velocity.x = max(min(newVelocity.x, VelMax_x), VelMin_x);
                    particles(i).Velocity.y = max(min(newVelocity.y, VelMax_y), VelMin_y);
                    particles(i).Position.x = max(min(newPosition.x, VarMax), VarMin);
                    particles(i).Position.y = max(min(newPosition.y, VarMax), VarMin);
                else
                    attempts = attempts + 1;
                end
            end

            % Calculate reward and update the best position
            [particles(i).reward, particles(i).rate, particles(i).slope] = calculate_reward_PSO(particles(i).Position, collection_UAV_location, server_info, server_id, current_location, required_distance, V_max);

            if particles(i).reward > particles(i).Best.reward
                particles(i).Best.Position = particles(i).Position;
                particles(i).Best.reward = particles(i).reward;
                particles(i).Best.rate = particles(i).rate;
                particles(i).Best.slope = particles(i).slope;

                if particles(i).Best.reward > GlobalBest.reward
                    GlobalBest = particles(i).Best;
                end
            end
        end

        % Display iteration information
        disp(['Iteration ', num2str(it), ': Best reward = ', num2str(GlobalBest.reward)]);
    end

    % Update the global best solution
    GlobalBests(j) = GlobalBest;
end

% After the PSO algorithm completes, update the server information and rewards
for j = 1:size(matching_indices, 2)
    server_id = matching_indices(j);
    newPoint_x = GlobalBests(j).Position.x;
    newPoint_y = GlobalBests(j).Position.y;
    bestreward(server_id) = GlobalBests(j).reward;
    rate(server_id) = GlobalBests(j).rate;
    slope(server_id) = GlobalBests(j).slope;
    server_info(server_id, 2) = newPoint_x;
    server_info(server_id, 3) = newPoint_y;
end
end