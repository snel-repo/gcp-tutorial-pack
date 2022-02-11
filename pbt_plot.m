import PBT_analysis.*
%% Set paths for data
data_folder = 'FILL_IN_HERE\data\runs\pbt_run';
output_folder = 'output';
%% Make plots
addpath('utils');
make_pbt_run_plots(data_folder, output_folder);