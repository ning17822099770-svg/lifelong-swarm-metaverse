function [queue, Action_for_this_time, H, Q] = next_state_random(D_max, action, queue, server_info, server_id, H, Q)
%NEXT_STATE_RANDOM  Variant of NEXT_STATE used by the random-policy baseline.

fprintf('action = %.2f\n', action);
fprintf('server_info(server_id, 5) = %.2f\n', server_info(server_id, 5));


Action_for_this_time = floor(action * min(size(queue, 1),server_info(server_id,5)));


if Action_for_this_time > server_info(server_id,5)
    Action_for_this_time = server_info(server_id,5);
elseif Action_for_this_time < 0
    Action_for_this_time = 0;
end

if size(queue, 1) >= Action_for_this_time

    H(1, server_id) = max((H(1, server_id) - Action_for_this_time), 0);

    Q(1, server_id) = max((Q(1, server_id) - D_max(1, server_id)), 0);

    queue(1:Action_for_this_time, :) = []; 
    
elseif size(queue,1) < Action_for_this_time

    Action_for_this_time = size(queue,1);

    H(1,server_id) = max((H(1,server_id) - Action_for_this_time), 0);

    Q(1, server_id) = max((Q(1, server_id) - D_max(1, server_id)), 0);

    queue = [];
end