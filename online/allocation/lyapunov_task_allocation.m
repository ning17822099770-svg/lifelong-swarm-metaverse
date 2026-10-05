function [D_opt, loss_min] = lyapunov_task_allocation(num_of_servers, current_total_number, matching_indices, rate, D_max, H, Q, server_info, data_unit)
%LYAPUNOV_TASK_ALLOCATION  LDF-based dynamic-programming task allocation (LDF-DPTAA, Algorithm 2).
%
%   Splits CURRENT_TOTAL_NUMBER tasks of one type among the servers of that type, with at most
%   D_max tasks per server. It minimises the drift-plus-penalty loss of Eq. (19) (GETREWARD)
%   in O(n * q * Upsilon) time instead of O(Upsilon^n) for exhaustive search.
%
%   Returns the allocation D_opt (one entry per server) and its total loss.

n = num_of_servers / 5; % number of servers of each type

% Initialize dynamic programming table
DP = inf(n + 1, current_total_number + 1);
DP(1, 1) = 0; % Base case

% Fill DP table
for i = 1:n
    for j = 0:current_total_number
        for k = 0:min(D_max(matching_indices(i)), j)
            loss = calculate_individual_loss(i, matching_indices, k, rate, H, Q, server_info, data_unit);
            if j-k >= 0 % Ensure no negative indexing
                DP(i + 1, j + 1) = min(DP(i + 1, j + 1), DP(i, j - k + 1) + loss);
            end
        end
    end
end

% Calculate minimum loss
loss_min = DP(n + 1, current_total_number + 1);

% Backtrack to find optimal solution
D_opt = reconstruct_solution(DP, n, current_total_number, D_max, matching_indices, rate, H, Q, server_info, data_unit);
end

function loss = calculate_individual_loss(i, matching_indices, tasks, rate, H, Q, server_info, data_unit)
    % Calculate the loss when a specific number of tasks is allocated to a given server
    % Implementation here depends on the specific loss calculation method
    loss = 0; % Example implementation, actual implementation may differ
    loss = loss + getreward(matching_indices(i), rate(matching_indices(i)), tasks, H, Q, server_info, data_unit);
end

function D_opt = reconstruct_solution(DP, num_of_servers, current_total_number, D_max, matching_indices, rate, H, Q, server_info, data_unit)
    % Backtrack to find the optimal solution from the DP table
    D_opt = zeros(1, num_of_servers);
    j = current_total_number;
    for i = num_of_servers:-1:1
        for k = 0:min(D_max(matching_indices(i)), j)
            if j-k >= 0 && DP(i + 1, j + 1) == DP(i, j - k + 1) + calculate_individual_loss(i, matching_indices, k, rate, H, Q, server_info, data_unit)
                D_opt(i) = k;
                j = j - k;
                break;
            end
        end
    end
end


