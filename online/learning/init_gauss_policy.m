function  initial_policy = init_gauss_policy(N, M)
%INIT_GAUSS_POLICY  Linear Gaussian policy with zero mean parameters and sigma = 0.25.

    initial_policy.theta.initMu = 0;
    % policy.theta.initSigma = 0.0333;
    initial_policy.theta.initSigma = 0;
    initial_policy.theta.k = normrnd(initial_policy.theta.initMu, initial_policy.theta.initSigma, N * M, 1);
    % initial_policy.theta.sigma = exp(-1) * ones(1, M);
    initial_policy.theta.sigma = 0.25; %0.25