function [model]=initial_PGELLA(N, M, k ,mu_one,mu_two,learningRate, task_ID)
%INITIAL_PGELLA  Initialise a PG-ELLA model (random basis L of size (N*M)-by-k, empty S).

model.T = 0;
model.S = zeros(k,task_ID);
model.mu_one = mu_one;
model.mu_two = mu_two; 
model.learningRate = learningRate; 
%  
% 
% 
% % Initialize the L matrix for group l with dimensions N*M by k

random_matrix = generateRandomMatrix(N * M, k);

model.L = random_matrix;