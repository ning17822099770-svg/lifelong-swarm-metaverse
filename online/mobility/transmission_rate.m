function rate = transmission_rate(distance, B, P)
%TRANSMISSION_RATE  A2A transmission rate between the collection UAV and a UAV server.
%
%   Free-space path loss (Eq. (1)) and Shannon rate (Eq. (2)) at carrier 2.5 GHz.

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
B = 1e6;
P = 0.1;

if distance ~= 0 && distance ~= -1

    fspl = ((4 * pi * carrier_f * distance / 3e8) ^ 2);

    L = (fspl * 10 ^ (yita0 / 20));

    rate = (B * log2(1 + P * G / (L * noise_power * B)));
else
    rate = 0;
end




