function [R2_train, R2_valid, yhat, yhat_valid, w] = train_mapping(X, y, train_idx, valid_idx, alpha)
% Train a ridge regression model, and report performance on both train trials and validation trials
%
% INPUTS
% X            -- Predictors. Size: [n_neurons, n_timesteps, n_trials]
% y            -- Target variable. Size: [n_targets, n_timesteps, n_trials]
% train_idx    -- A vector with true/false with the length of n_trials.
% valid_idx    -- A vector with true/false with the length of n_trials.
% alpha        -- Ridge regularization strength. A positive scalar
% 
% OUTPUT
% R2_train   -- Coefficient of determination (R2) between true and predicted y, for train trials.
% R2_valid   -- Coefficient of determination (R2) between true and predicted y, for valid trials.
% yhat       -- Predicted y for all trials. Size: same as y.
% yhat_valid -- Predicted y for only valid trials. Size: [n_targets, n_timesteps, n_valid_trials]
% w          -- Trained weights of ridge regression. Size: [n_neurons, n_targets]

% Split data into train and valid trials
n_times = size(X, 2);
train_y = y(:,:,train_idx);
valid_y = y(:,:,valid_idx);
train_X = X(:,:,train_idx);
valid_X = X(:,:,valid_idx);

% flatten data
n_y = size(y,1);
n_X = size(X,1);
train_y = reshape(train_y, n_y, []);
valid_y = reshape(valid_y, n_y, []);
train_X = reshape(train_X, n_X, []);
valid_X = reshape(valid_X, n_X, []);

% Get rid of neurons/features that have purely 0 activity.
keep_feature_indices = max(train_X, [], 2) ~= 0;
X = X(keep_feature_indices, :,:);
train_X = train_X(keep_feature_indices, :);
valid_X = valid_X(keep_feature_indices, :);

% Add bias
train_X(end+1,:) = 1;
valid_X(end+1,:) = 1;

% Calculate weights and predictions
X = train_X';
Y = train_y';
R = alpha* eye(size(X,2));
R(end) = 0; % don't penalize the bias
w  = inv(X'*X + R) * X'*Y;
train_pred = (train_X' * w)';
valid_pred = (valid_X' * w)';
R2_train = zeros(1,n_y);
R2_valid = zeros(1,n_y);
for i_y = 1:n_y
    R2_train(i_y) = R2(train_y(i_y,:), train_pred(i_y,:));
    R2_valid(i_y) = R2(valid_y(i_y,:), valid_pred(i_y,:));
end

% shape data back to [n_dims, n_times, n_trials]
yhat_train = reshape(train_pred, n_y, n_times, []);
yhat_valid = reshape(valid_pred, n_y, n_times, []);

% merge predicted train and valid trials
yhat = NaN(size(y));
yhat(:,:,train_idx) = yhat_train;
yhat(:,:,valid_idx) = yhat_valid;