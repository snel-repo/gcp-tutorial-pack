function [yhat, test_idx, R2_train, R2_test, optimal_alpha, yhat_test, y_test, condition_id_test, w] = mapping_wrapper(X, y, k, test_start_idx, alpha, condition_id)
% Split data into train/test. Use the train set to perform cross-validated ridge alpha sweep. Use the optimal alpha value to train ridge regression on train set and evaluate on test set.
%
% INPUTS
% X               -- Predictors. Size: [n_neurons, n_timesteps, n_trials]
% y               -- Target variable. Size: [n_targets, n_timesteps, n_trials]
% k               -- select a test trial in every k trials
% test_start_idx  -- From which trial that we start to select test trials
% alpha_range     -- A scalar, alpha value for ridge regularization strength.
% condition_id    -- A vector of condition_id with length = n_trials
% 
% OUTPUT
% yhat        -- Predicted y across all trials (including train and test sets). Same Size with y
% test_idx    -- Indicates which trials are test trials. A vector with length = n_trials
% R2_train    -- Coefficient of determination (R2) between true and predicted y, for train set
% R2_test     -- Coefficient of determination (R2) between true and predicted y, for test set
% optimal_alpha -- The optimal alpha value that gives highest mean R2 across the validation sets
% yhat_test   -- Predicted y for only test trials. Size: [n_targets, n_timesteps, n_test_trials]
% y_test      -- True y for only test trials. Size: [n_targets, n_timesteps, n_test_trials]
% condition_id_test -- Condition ids for test trials.
% w           -- Trained weights of ridge regression. Size: [n_neurons, n_targets]

n_tr = size(X, 3); % n_trials
n_times = size(X, 2); % n_times

% split trials into train and test sets
test_idx = false(1,n_tr);
test_idx( test_start_idx : k : n_tr ) = true;
train_idx = ~test_idx;

% Train ridge regression and give R2 for both train and test set
[R2_train, R2_test, yhat, yhat_test, w] = train_mapping(X, y, train_idx, test_idx, alpha);
condition_id_test = condition_id(test_idx);
y_test = y(:,:,test_idx);