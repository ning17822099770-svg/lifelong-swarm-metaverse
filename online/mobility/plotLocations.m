function plotLocations(collection_UAV_location, server_info, iteration)
%PLOTLOCATIONS  Plot the collection UAV and all UAV servers at hovering position ITERATION.
%
%   Used to produce the approach/following phase figures (Figs. 3-4).
    % Clear the current figure
    clf;

    % Get UAV types
    uav_types = unique(server_info(:, 1));
    colors = lines(numel(uav_types)); % Generate colors for different UAV types
    markers = {'+', '*', 's', 'd', '^', 'v', '<', '>', 'p', 'h'}; % Define different marker symbols

    % Ensure enough marker symbols are available
    if numel(uav_types) > numel(markers)
        error('More marker symbols needed');
    end

    % Initialize legend
    legendInfo = cell(1, numel(uav_types) + 1);

    % Plot servers of different types
    for t = 1:numel(uav_types)
        type = uav_types(t);
        idx = server_info(:, 1) == type; % Find UAVs of this type
        plot(server_info(idx, 2), server_info(idx, 3), markers{t}, 'MarkerSize', 10, 'Color', colors(t, :));
        hold on;
        % Update legend information
        legendInfo{t} = ['UAV Type ' num2str(type)];
    end

    % Plot collection UAV location
    plot(collection_UAV_location(1), collection_UAV_location(2), 'ro', 'MarkerSize', 10);
    legendInfo{end} = 'Collection UAV'; % Add collection UAV to legend

    % Update legend and title
    legend(legendInfo);
    title(['Time Step ' num2str(iteration)]);
    hold off;
    pause(0.5); % Pause for 0.5 seconds for observation
end
