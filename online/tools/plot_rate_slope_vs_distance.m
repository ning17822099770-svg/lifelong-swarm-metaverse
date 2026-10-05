%PLOT_RATE_SLOPE_VS_DISTANCE  A2A transmission rate (Eq. (2)) and its slope versus distance.
%
%   Visualises the rate and the slope S used by the mobility utility (Eqs. (8)-(11)) for the
%   bandwidth/power setting of each server type.

% Collecting channel parameters
collecting_channel_param = containers.Map({'suburban', 'urban', 'dense-urban', 'high-rise-urban'}, ...
    {[4.88, 0.43, 0.1, 21], [9.61, 0.16, 1, 20], [12.08, 0.11, 1.6, 23], [27.23, 0.08, 2.3, 34]});
collecting_params = collecting_channel_param('urban');
a = collecting_params(1);
b = collecting_params(2);
yita0 = collecting_params(3);
yita1 = collecting_params(4);
carrier_f = 2.5e9; % Carrier frequency
noise_power = 1e-13; % Noise power

G = 1; % Gain
distance_values = 50:1:100; % Distance values from 100 to 200 meters

% Define different B and P values
B_values = [1e6, 2e6, 3e6, 4e6, 5e6]; % Bandwidth values
P_values = [0.1, 0.2, 0.3, 0.4, 0.5]; % Transmit power values

% Plot transmission rate
figure;
hold on;
for j = 1:length(B_values)
    B = B_values(j);
    P = P_values(j);
    rate_values = zeros(size(distance_values)); % Initialize rate array

    for i = 1:length(distance_values)
        distance = distance_values(i);
        fspl = ((4 * pi * carrier_f * distance / 3e8) ^ 2); % Free space path loss
        L = (fspl * 10 ^ (yita0 / 20)); % Total path loss
        rate_values(i) = (B * log2(1 + P * G / (L * noise_power * B))); % Compute rate
    end
    
    plot(distance_values, rate_values, 'DisplayName', ['Rate, B=' num2str(B) ', P=' num2str(P)]);
end
legend('show');
xlabel('Distance (m)');
ylabel('Rate (bps)');
title('Rate vs. Distance for Different Bandwidth and Power Values');
grid on;
hold off;

% Plot slope
figure;
hold on;
for j = 1:length(B_values)
    B = B_values(j);
    P = P_values(j);
    slope_values = zeros(size(distance_values)); % Initialize slope array

    for i = 1:length(distance_values) - 1
        distance = distance_values(i);
        fspl = ((4 * pi * carrier_f * distance / 3e8) ^ 2); % Free space path loss
        L = (fspl * 10 ^ (yita0 / 20)); % Total path loss
        rate = (B * log2(1 + P * G / (L * noise_power * B))); % Compute rate for current distance
        
        next_distance = distance_values(i + 1);
        next_fspl = ((4 * pi * carrier_f * next_distance / 3e8) ^ 2);
        next_L = (next_fspl * 10 ^ (yita0 / 20));
        next_rate = (B * log2(1 + P * G / (next_L * noise_power * B))); % Compute rate for next distance
        
        slope_values(i) = (next_rate - rate) / (next_distance - distance);
    end
    
    plot(distance_values(1:end-1), slope_values(1:end-1), '--', 'DisplayName', ['Slope, B=' num2str(B) ', P=' num2str(P)]);
end
legend('show');
xlabel('Distance (m)');
ylabel('Slope');
title('Slope vs. Distance for Different Bandwidth and Power Values');
grid on;
hold off;




