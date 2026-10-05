function plot_rate_and_slope(carrier_f, yita0, B, P, G, noise_power)
    % Define the function to calculate rate
    function rate = calculate_rate(distance)
        if distance ~= 0 && distance ~= -1
            fspl = ((4 * pi * carrier_f * distance / 3e8) ^ 2);
            L = (fspl * 10 ^ (yita0 / 20));
            rate = (B * log2(1 + P * G / (L * noise_power * B)));
        else
            rate = 0;
        end
    end

    % Define the function to calculate slope
    function slope = calculate_slope(distance)
        delta_distance = 1; % Tiny distance increment
        rate_plus_delta = calculate_rate(distance + delta_distance);
        slope = (rate_plus_delta - calculate_rate(distance)) / delta_distance;
    end

    % Initialize data arrays
    distances = 0:1:200;
    rates = zeros(size(distances));
    slopes = zeros(size(distances));

    % Calculate transmission rates and slopes for each distance point
    for i = 1:length(distances)
        rates(i) = calculate_rate(distances(i));
        slopes(i) = calculate_slope(distances(i));
    end

    % Plot transmission rates and slopes
    figure;
    yyaxis left;
    plot(distances, rates, 'b-', 'LineWidth', 2);
    ylabel('Transmission Rate');
    xlabel('Distance');
    yyaxis right;
    plot(distances, slopes, 'r--', 'LineWidth', 2);
    ylabel('Slope');
    title('Change of Transmission Rate and Slope with Distance');
    grid on;
end

