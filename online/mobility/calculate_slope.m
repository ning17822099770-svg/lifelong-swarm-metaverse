function slope = calculate_slope(target_rate, B, P, G, carrier_f, noise_power, yita0)
%CALCULATE_SLOPE  Slope dR/dd of the A2A rate at the distance where the rate equals TARGET_RATE.
%
%   Numerical counterpart of Eqs. (9)-(11), used by the mobility utility of Eq. (8).
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

    % Search for the distance closest to the target rate
    distance_search = 0:1:200;
    min_diff = inf;
    optimal_distance = 0;

    for dist = distance_search
        current_rate = calculate_rate(dist);
        rate_diff = abs(current_rate - target_rate);

        if rate_diff < min_diff
            min_diff = rate_diff;
            optimal_distance = dist;
        end
    end

    % Calculate the slope at the found distance
    delta_distance = 1; % Small distance increment
    rate_plus_delta = calculate_rate(optimal_distance + delta_distance);
    slope = (rate_plus_delta - calculate_rate(optimal_distance)) / delta_distance;
end
