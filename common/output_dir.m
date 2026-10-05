function d = output_dir(varargin)
%OUTPUT_DIR  Folder under <repo>/outputs where new results are written.
%
%   D = OUTPUT_DIR('results') returns <repo>/outputs/results and creates it if needed.
%   The outputs/ folder is git-ignored, so re-running experiments never overwrites the
%   reference data shipped in data/.
%
%   See also REPO_ROOT.

d = fullfile(repo_root(), 'outputs', varargin{:});
if ~exist(d, 'dir')
    mkdir(d);
end
end
