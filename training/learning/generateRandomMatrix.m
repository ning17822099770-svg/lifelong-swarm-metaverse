function random_matrix = generateRandomMatrix(a, b)
%GENERATERANDOMMATRIX  Random initial latent basis L for PG-ELLA.

% Initialize parameters
seed = floor(sum(clock * 1e6)); % Initial seed value
m = 2^32; % Using 32-bit unsigned integers
c = 1013904223;
multiplier = 1664525;
a = 2;
b = 5;

% Initialize a x b matrix
random_matrix = zeros(a, b);

for i = 1:a
    for j = 1:b
        % Use linear congruential generator
        seed = mod(multiplier * seed + c, m);
       
        % Normalize to the range [0, 1]
        random_number = seed / m;
       
        % Store into the matrix
        random_matrix(i, j) = random_number;
    end
end
