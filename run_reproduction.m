root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'code'));
validate_package();
reproduce_all();
fprintf('All requested outputs are under %s\n', fullfile(root, 'outputs'));
