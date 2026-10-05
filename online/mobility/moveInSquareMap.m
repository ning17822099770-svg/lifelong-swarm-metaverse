function [new_position, direction] = moveInSquareMap(initial_position, map_size, v, direction)
%MOVEINSQUAREMAP  Move the central collection UAV one step along its fixed back-and-forth path.
%
%   The UAV flies along x between 1/4 and 3/4 of the map and reverses at the boundaries
%   (where the UAV servers are re-initialised).
    % initial_position: Initial position, [x, y]
    % map_size: Map size, [width, height]
    % v: Speed of movement
    % direction: Current direction of movement, [dx, dy]

    % Ensure map size is greater than 0
    if any(map_size <= 0)
        error('Map size must be positive.');
    end

    % Ensure speed is greater than 0
    if v <= 0
        error('Speed must be positive.');
    end

    % Ensure initial position is within the map boundaries
    if any(initial_position < [1, 1]) || any(initial_position > map_size)
        error('Initial position must be within the map boundaries.');
    end

    % Directions for movement in a square trajectory, clockwise
    square_directions = [1, 0; 0, -1; -1, 0; 0, 1];

    % If direction parameter is not provided, default to moving right
    if nargin < 4
        direction = square_directions(1, :);                                                                                                          
    end

    % Calculate the next position
    next_position = initial_position + v * direction;

    % Adjust direction based on position
    if next_position(1) > (3/4) * map_size(1)
        direction = [-1, 0];  % Move left
    elseif next_position(1) < (1/4)* map_size(1)
        direction = [1, 0]; % Move right
    end

    % Recalculate the next position
    next_position = initial_position + v * direction;

    % Calculate the new position
    new_position = next_position;
end

