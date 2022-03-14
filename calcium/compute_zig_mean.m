function [rates, shape, scale, q] = compute_zig_mean(zig_params, s_min, fs)
% Compute time-varying mean of inferred ZIG distribution for all neurons
%
% INPUTS
% zig_params     -- Previously collapsed data. Size: [3*n_neurons, n_timesteps, n_trials]
% s_min          -- minimum calcium event size. Scalar
% fs             -- Sampling rate in Hz. Scalar
%
% OUTPUT
% rates          -- Estimated event rates. Size: [n_neurons, n_timesteps, n_trials]
n_chs = size(zig_params, 1)/3;
shape = zig_params(1:n_chs,:,:);
scale = zig_params(n_chs+1:2*n_chs,:,:);
q = zig_params(2*n_chs+1:end,:,:);
rates = fs*(q.*((shape.*scale)+s_min)); % for inferring scale