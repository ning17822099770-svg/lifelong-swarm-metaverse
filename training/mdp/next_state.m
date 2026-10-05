function [Queue, Action_for_this_time] = next_state(action, Queue, server_info, pall, t)
%NEXT_STATE  Execute the computing action and remove the processed tasks from the queue.

fprintf('action = %.2f\n', action);
fprintf('server_info(server_id, 5) = %.2f\n', server_info(pall, 5));


Action_for_this_time = floor(action * server_info(pall, 5));


if Action_for_this_time > server_info(pall,5)
    Action_for_this_time = server_info(pall,5);
elseif Action_for_this_time < 0
    Action_for_this_time = 0;
end

if size(Queue(1,t).queue,1) >= Action_for_this_time

    % for j = 1: Action_for_this_time
    %     source = Queue{server_id}(j,5);
    %     H(source,server_id) = H(source,server_id) - 1;
    %     Q(source,server_id) = Q(source,server_id) - 1;
    % end

    Queue(1,t).queue(1:Action_for_this_time, :) = []; % Delete the first n lines.

    % Retrieve the data to be added (remaining data).
    data_to_add = Queue(1,t).queue;

    if t + 1 <= numel(Queue(1,:))
        Queue(1,t+1).queue = [data_to_add; Queue(1,t+1).queue];

    end


else
    Action_for_this_time = size(Queue(1,t).queue,1);

    % for j = 1: Action_for_this_time
    %     source = Queue{server_id}(j,5);
    %     H(source,server_id) = H(source,server_id) - 1;
    %     Q(source,server_id) = max((Q(source,server_id) - D_max(source,server_id)) , 0);
    % end

    Queue(1,t).queue = [];
end

Action_for_this_time

