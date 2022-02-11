import PBT_analysis.*
%% Fill in path of lfads_output
% specify LFADS output directory with posterior sample and average files
% read the lfads output files (specify the lfads_input_file name to merge
% training and validation sets from lfads output)
lfads_output_dir = 'C:\Users\Diya\Desktop\autoLFADS_analysis\data\runs\lfads_output';

%% Post processing
lfads_input_file = 'lfads_cal_data.h5';
data = load('true_latents_synthetic_calcium.mat');
true_latents = data.truth_lorenz; 
output_data = read_lfads_output(lfads_output_dir, lfads_input_file);

%% compute predicted rates from inferred ZIG parameters
% calculate event rates from estimated ZIG parameters
zig_params = output_data{1}.rates;
s_min = 0.1;
timeBase = 30;
framerate = 1000/timeBase;
[lfads_rates, ~,~,~] = compute_zig_mean(zig_params, s_min, framerate);

%% perform ridge regression to map inferred rates to ground truth latent states
% specify ratio of test trials/all trials
test_ratio = 0.2;
k = round(1 / test_ratio);
i_k = 1;
% test trial indices will be i_k : k : end.
% e.g., if k = 5 and i_k = 1, test trials will be the 1st, 6th, 11th, 16th, 21th ... trials

alpha = 0.01; % A sweep of alpha values is recommended to find the optimal regularization
[~, test_idx, R2_train, R2_test, ~, yhat_test, y_test, condition_id_test, ~] = mapping_wrapper(lfads_rates, truth_lorenz, k, i_k, alpha_range, condition_id);
sprintf('Test R2 of true and predicted Lorenz X, Y and Z states are: %0.3f, %0.3f, %0.3f', R2_test)

%% Visualize true and predicted Lorenz states for some conditions
lowD_names = {'X', 'Y', 'Z'};
% pick a few conditions to visualize the true vs predicted Lorenz latent states
conds_to_plot = [1,5,6,7];
figure()
set(gcf, 'Position', [36, 36, 1850, 1050])
% loop through each Lorenz dimension (i.e., X, Y and Z)
for i_l = 1:size(y_test, 1)
    % loop through each condition for plotting
    for i_c = 1:numel(conds_to_plot)
        i_cond = conds_to_plot(i_c);
        subplot(3,4,i_c+(i_l-1)*4)
        % find trial indices that belong to the current condition
        trial_idx_this_condition = find(condition_id_test == i_cond);
        % plot predicted latent states
        h = plot(squeeze(yhat_test(i_l,:,trial_idx_this_condition)), 'Color', [ 0.5843 0.8157 0.9882], 'LineWidth',0.5); 
        hold on
        % plot true latent states
        h(end+1) = plot(squeeze(y_test(i_l,:,trial_idx_this_condition(1))), 'Color', 'k', 'LineWidth', 2);
        % put legend on if this is the first column of panels
        if i_c == 1
            legend(h([end-1, end]), {['Predicted ', lowD_names{i_l}], ['True ', lowD_names{i_l}]})
            ylabel(['Lorenz ' lowD_names{i_l}])
        end        
        hold off
        % Put on title and x label
        if i_l == 1
            title(['Condition ' int2str(i_cond)])
        elseif i_l == 3
            xlabel('Bin (10 ms/bin)')
        end        
    end
end
suptitle('RADICaL, true vs. predicted latent states')
