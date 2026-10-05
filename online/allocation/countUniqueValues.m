function [unique_values, row_counts] = countUniqueValues(queue_matrix)
%COUNTUNIQUEVALUES  Task types present in a queue and the number of tasks of each type.
    % Get the first column of the matrix
    first_column = queue_matrix(:, 1);

    % Use the unique function to get unique values from the first column
    % and the number of occurrences of each value
    [unique_values, ~, unique_indices] = unique(first_column);

    % Initialize an array to store row counts
    row_counts = zeros(size(unique_values));

    % Iterate over the unique_values array
    for i = 1:length(unique_values)
        % Find indices that match the current unique value
        indices = find(unique_indices == i);
        
        % Count the number of rows with the same value and store
        row_counts(i) = length(indices);
    end
end
