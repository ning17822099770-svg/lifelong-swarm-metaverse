function setup_paths(module, spams_dir)
%SETUP_PATHS  Put one simulation module (and its dependencies) on the MATLAB path.
%
%   SETUP_PATHS('training')  central collection UAV: pre-training of the NAC base learner
%                            and of the lifelong-learning knowledge base (Fig. 8).
%   SETUP_PATHS('online')    UAV swarm Metaverse: PSO-CEMA mobility, LDF-DPTAA task
%                            allocation and LL-CJTPA computing (Figs. 3-7, 9-13).
%   SETUP_PATHS(MODULE, SPAMS_DIR) additionally adds the SPAMS toolbox located in SPAMS_DIR.
%
%   The two modules share function names (e.g. Trajectory_process, task_generation) with
%   module-specific implementations, so only one of them may be on the path at a time.
%   Calling this function removes the other module from the path.
%
%   The plotting/ scripts are always added.
%
%   Example:
%       setup_paths('online', 'C:\toolboxes\spams-matlab-v2.6');
%       run_online_base_learner          % also runs run_online_lifelong at the end

if nargin < 1
    module = 'online';
end
module = validatestring(module, {'training', 'online'});

root = fileparts(mfilename('fullpath'));

% Remove both modules first to avoid name clashes between them
state = warning('off', 'MATLAB:rmpath:DirNotFound');
for m = {'training', 'online'}
    rmpath(genpath(fullfile(root, m{1})));
end
warning(state);

addpath(fullfile(root, 'common'));
addpath(fullfile(root, 'plotting'));
addpath(genpath(fullfile(root, module)));

% Optional: SPAMS toolbox (mexLasso), used for the sparse-coding step of PG-ELLA
if nargin >= 2 && ~isempty(spams_dir)
    addpath(genpath(spams_dir));
end
if exist('mexLasso', 'file') ~= 3
    warning('setup_paths:noSpams', ...
        ['SPAMS mexLasso was not found on the path. solve_lasso() will fall back to ' ...
         'MATLAB''s lasso() (Statistics and Machine Learning Toolbox). ' ...
         'See README.md to install SPAMS.']);
end

fprintf('Module "%s" is on the MATLAB path (repository: %s)\n', module, root);
end
