function data_struct = read_lfads_output(lfads_output_path, data_file)

if ~exist('data_file', 'var')
    data_file = [];
end

% find posterior sampling files (LFADS output files)
train_file = dir(fullfile(lfads_output_path, '*train_posterior_sample_and_average'));
valid_file = dir(fullfile(lfads_output_path, '*valid_posterior_sample_and_average'));
train_file = fullfile(lfads_output_path , train_file.name);
valid_file = fullfile(lfads_output_path , valid_file.name);

% load h5 files. They are structs containing output of multiple LFADS graph
% nodes. The rates are writen as "output_dist_params" and the factors as
% "factors"
% This function only outputs the rates and factors. For more advanced use
% you can use loadh5() to load the full output field.

% load training set
tmp_data = PBT_analysis.loadh5(train_file);
train_data.rates = tmp_data.output_dist_params;
train_data.factors = tmp_data.factors;
% load validation set
tmp_data = PBT_analysis.loadh5(valid_file);
valid_data.rates = tmp_data.output_dist_params;
valid_data.factors = tmp_data.factors;

disp('Loaded LFADS output for Training and Validation sets.')

[num_neurons, num_samps, num_train_trials] = size(train_data.rates);
num_valid_trials = size(valid_data, 3);
num_factors = size(train_data.factors, 1);

if ~isempty(data_file)
    data = PBT_analysis.loadh5(data_file);
    disp('Input data file exists. Merging LFADS output for Training and Validation sets.')
    % loading the indices of training and validation trials from the input
    % dataset
    train_inds = data.train_inds;
    valid_inds = data.valid_inds;
    % merge rates
    merged_data.rates = zeros(num_neurons, num_samps, num_train_trials + num_valid_trials);
    merged_data.rates(:,:,train_inds) = train_data.rates;
    merged_data.rates(:,:,valid_inds) = valid_data.rates;
    % merge factors
    merged_data.factors = zeros(num_factors, num_samps, num_train_trials + num_valid_trials);
    merged_data.factors(:,:,train_inds) = train_data.factors;
    merged_data.factors(:,:,valid_inds) = valid_data.factors;
    
    disp('Returning the merged data.')
    data_struct = merged_data;
else
    disp('Returning separate data for Training and Validation sets.')
    data_struct.train_data.rates = train_data.rates; 
    data_struct.train_data.factors = train_data.factors; 
    data_struct.valid_data.rates = valid_data.rates;
    data_struct.valid_data.factors = valid_data.factors;
end

end