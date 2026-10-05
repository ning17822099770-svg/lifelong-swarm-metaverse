function root = repo_root()
%REPO_ROOT  Absolute path of the repository root folder.
%
%   Used to locate data/ and outputs/ independently of the current folder.
%
%   See also OUTPUT_DIR, SETUP_PATHS.

root = fileparts(fileparts(mfilename('fullpath')));
end
