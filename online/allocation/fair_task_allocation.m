function [D_opt, loss_min] = fair_task_allocation(num_of_servers, current_total_number, matching_indices, rate, D_max, H, Q, server_info, data_unit)
%FAIR_TASK_ALLOCATION  Baseline allocation that splits the tasks equally among the servers.

n = num_of_servers / 5; % number of servers of each type

loss_min = 0;

D_opt = zeros(1,5);

% fill DP table
for i = 1:n

    tasks = ceil(current_total_number / 5);

    loss_min = loss_min + getreward(matching_indices(i), rate(i), tasks, H, Q, server_info, data_unit);

    D_opt(i) = tasks;

end
