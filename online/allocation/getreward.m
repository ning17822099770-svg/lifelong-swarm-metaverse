function reward = getreward(target_server, rate, D, H, Q, server_info, data_unit)
%GETREWARD  Drift-plus-penalty loss of allocating D tasks to one server (Eqs. (19), (31)).
%
%   loss = omega * (H + Q) * D - (1 - omega) * V * (p * D - P * D * d_u / R), where H and Q
%   are the processing and virtual queues (Eqs. (14)-(15)) and V = 5000. Lower is better.
%   The reward of Eq. (31) is the negative of this loss.
price = server_info(target_server, 1)* 0.01; %0.1
Ptr = server_info(target_server, 4);
% beta = 0.01; %0.05 0.01
V = 5000; %3e4 2000 10000 20000 15000buxing  5000
omega = 0.5; %0.5
if rate ~=0
    % reward = omega * (H(1,target_server) * D + Q(1,target_server) * D) - (1 - omega) * (V * price * D * beta - V * Ptr * D * data_unit/ rate * (1 - beta));
    reward = omega * (H(1,target_server) * D + Q(1,target_server) * D) - (1 - omega) * (V * price * D - V * Ptr * D * data_unit/ rate);
else 
    reward = H(1,target_server) * D + Q(1,target_server) * D - V * price * D;
end
 
   