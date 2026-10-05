function [der1] = DlogPiDThetaNAC(policy, state, action, N, M)
%DLOGPIDTHETANAC  Gradient of log pi(a | x) of the Gaussian policy with respect to theta.

% Programmed by Jan Peters (jrpeters@usc.edu).

sigma = max(policy.theta.sigma,0.00001);
k = policy.theta.k;
xx = state;
der1 = [];

for i=1: M
    der1 = [der1; (action-k(1+N*(i-1):N*(i-1)+N)'*xx)*xx/(sigma(i)^2)];
end
