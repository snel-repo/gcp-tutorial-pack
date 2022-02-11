function write_for_lfads(filename, data, valid_set_ratio_or_idx)
% data: input matrix to be converted to training and validation sets for
% LFADS
% the data dimension is in the form of (num_neurons, sequence_length, num_trials)
% valid_set_ratio: the ratio of the trials used to create validation set
% (default = 0.2). If a vector is provided, it is used as validation index

if ~exist('valid_set_ratio_or_idx', 'var')
    valid_set_ratio_or_idx = 0.2;
end

% T: number of trials
data = int8(data);  % originally was int64 (reduced for efficiency)

T = size(data, 3);

% splits the data into training and validation  sets
valid_idx = false(1, T);

if numel(valid_set_ratio_or_idx) > 1 % if validation indixes are provided
    valid_idx(valid_set_ratio_or_idx) = true;
else
    if valid_set_ratio_or_idx <= 0
        warning('No validation set will be created!')
    elseif valid_set_ratio_or_idx < 1
        valid_idx(1:round(1/valid_set_ratio_or_idx):end) = true;
    else
        error('valid_set_ratio must be smaller than 1!')
    end
end

valid_set = data(:,:, valid_idx);
train_set = data(:,:, ~valid_idx);

if exist(filename, 'file')
   r = input(['Delete ' filename ' (y/n)?'], 's');
   if r =='y'
       delete(filename)
   end
end

% write the training and validation sets to a h5 file
saveh5(filename, '/train_data', train_set);
saveh5(filename, '/train_inds', find(~valid_idx)');

saveh5(filename, '/valid_data', valid_set);
saveh5(filename, '/valid_inds', find(valid_idx)');

fprintf(1, 'Sucessfully wrote the data to: %s \n', filename);
fprintf(1, 'Number of training trials: %d \nNumber of validation trials: %d\n', ...
    size(train_set,3), size(valid_set,3));



end


function saveh5(filename, dataname, data)
% saves data into an h5 file
   
h5create(filename, dataname, size(data), 'DataType', class(data))
h5write(filename, dataname, data)

end