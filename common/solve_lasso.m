function alpha = solve_lasso(x, D, param)
%SOLVE_LASSO  Sparse coding step of PG-ELLA (Eq. (37) of the paper).
%
%   ALPHA = SOLVE_LASSO(X, D, PARAM) solves
%
%       min_alpha  0.5 * ||X - D*alpha||_2^2 + PARAM.lambda * ||alpha||_1
%
%   This is the problem solved by mexLasso of the SPAMS toolbox (mode 2), which was used
%   to produce the results in the paper. If SPAMS is not on the MATLAB path, the function
%   falls back to LASSO from the Statistics and Machine Learning Toolbox with the
%   equivalent regularisation weight (lambda / numel(X), no intercept, no standardisation).
%   Results may then differ slightly from the published ones.
%
%   See also UPDATEPGELLA, SETUP_PATHS.

persistent warned

if exist('mexLasso', 'file') == 3
    alpha = mexLasso(x, D, param);
    return;
end

if isempty(warned)
    warning('solve_lasso:noSpams', ...
        ['SPAMS (mexLasso) not found; falling back to MATLAB lasso(). ' ...
         'Install SPAMS to reproduce the published numbers exactly (see README).']);
    warned = true;
end

n = numel(x);
alpha = lasso(D, x, 'Lambda', param.lambda / n, 'Intercept', false, 'Standardize', false);
end
