function matching_indices = findMatchingIndices(current_type, server_info)
%FINDMATCHINGINDICES  Indices of the UAV servers whose type equals CURRENT_TYPE.
    % Get the first column of the server_info matrix
    server_info_first_column = server_info(:, 1);

    % Initialize an array to store matching row indices
    matching_indices = [];

    % Iterate over the elements in server_info_first_column
    for i = 1:length(server_info_first_column)
        % If the current element matches current_type
        if server_info_first_column(i) == current_type
            % Record the index of the current row
            matching_indices(end+1) = i;
        end
    end
end
