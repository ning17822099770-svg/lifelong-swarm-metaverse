function [collection_queue, Processing_queue] = processQueues(collection_queue, Processing_queue, current_type, D)
%PROCESSQUEUES  Move D tasks of CURRENT_TYPE from the collection queue to a processing queue.
    % Iterate through each row in collection_queue(server_id).queue
    i = 1;
    while i <= size(collection_queue, 1)
        if collection_queue(i, 1) == current_type
            % Append the matched row to the end of Processing_queue(target_server).queue
            Processing_queue = [Processing_queue; collection_queue(i, :)];
            
            % Remove the matched row from collection_queue(server_id).queue
            collection_queue(i, :) = [];
            
            % Update the count of matched rows
            D = D - 1;
            
            % Check if enough matched rows have been added
            if D <= 0
                break;  % Enough matched rows have been added, exit the loop
            end
        else
            i = i + 1;
        end
    end
end
