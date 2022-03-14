import PBT_analysis.*
%% Fill in path of lfads_output
% specify LFADS output directory with posterior sample and average files
% read the lfads output files (specify the lfads_input_file name to merge
% training and validation sets from lfads output)
lfads_output_dir = 'C:\Users\Diya\Desktop\autoLFADS_analysis\data\runs\lfads_output';

%% Post processing
lfads_input_file = 'lfads_data.h5';
data = load('true_rates_synthetic.mat');
true_rates = data.true_rates; 
output_data = read_lfads_output(lfads_output_dir, lfads_input_file);


% compare the inferred rates (from LFADS) to true rates 
% define R^2 metric (zero-mean)
r2_func = @(a,b) corrcoef(squeeze(a),squeeze(b)).^2;

% actual rates that the data is generated from 

% inferred rates estimated by LFADS
lfads_rates = output_data.rates;

% get R^2 for rates over all the data
% concatenate all trials for R^2
true_rates_all  = true_rates(:);
lfads_rates_all  = lfads_rates(:);

r2_rates = r2_func(true_rates_all, lfads_rates_all); 
r2_rates = r2_rates(2);
fprintf('\nRates R^2: %0.3f\n', r2_rates);

%% plotting
neuron_vec = [1]; %example neurons to plot
trial_vec = [1];   % example trials to plot
figure

i = 0;
for c = neuron_vec
    for t = trial_vec
        i = i + 1;
        subplot(length(neuron_vec), length(trial_vec), i)
        hold on
        plot(true_rates(c, :, t))
        plot(lfads_rates(c, :, t))
        %set(gca,'XTickLabel',[]);
        set(gca,'TickDir', 'out');
        title(sprintf('Trial %d Neuron %d', t, c))
        %end
    end
end
legend('True Rates', 'LFADS Rates')


%%
