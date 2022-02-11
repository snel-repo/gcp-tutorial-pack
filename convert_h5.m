%% Fill in variables here
data = load('mat_file.mat');
lfads_input_file = 'lfads_output_name.h5';
%%
input = data.data;

[num_neurons, num_samps, num_trials] = size(input);

fprintf('Number of Neurons: %d \n', num_neurons);
fprintf('Number of Time Samples in each Trial: %d\n', num_samps); 
fprintf('Number of Trials: %d\n', num_trials);

valid_set_ratio = 0.2; % 20% of the data used for validation

PBT_analysis.write_for_lfads(lfads_input_file, input, valid_set_ratio);
