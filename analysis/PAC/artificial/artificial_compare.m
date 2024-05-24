% create artificial dataset and plot dPAC results
% Figure 2.10

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../../lib'));

%% figs path
figs_path = "/home/jur0/project_iEEG/code/figs/OUT/compare";


%% DEFINE parameters of signal (default)
% select method
PAC_methods = {'MI', 'Heights Ratio', 'dPAC', 'MVL'};
% PAC_methods = {'MI', 'ratio', 'PAC SNR', 'dMVL', 'MVL'};

Ntrials = 12;
fs = 512; % sampling rate
trial_duration = 2;
t_stop = trial_duration; % signal duration
t_stop = t_stop - 1/fs;
trialSamples = trial_duration*fs;
timeAxis = 0:1/fs:t_stop;

%% define filters for Filter-Hilbert

% define filter properties
LF_range = [4,8]; % (Hz) range of low freq. signal
HF_range = [30, 50]; % (Hz) range of high freq. signal
LF_bandSize = 4; HF_bandSize = 20; % band size for band pass filters
LF_step = 4; HF_step = 20; % steps for overlapping filters 

% get filters
LF_filters = FH.getFilters(LF_range(1):LF_step:LF_range(2), fs, LF_bandSize);
HF_filters = FH.getFilters(HF_range(1):HF_step:HF_range(2), fs, HF_bandSize);
LF_filtersBands = FH.getFiltersFreq(LF_range(1):LF_step:LF_range(2), LF_bandSize);
HF_filtersBands = FH.getFiltersFreq(HF_range(1):HF_step:HF_range(2), HF_bandSize);

N_LF = size(LF_filters,1); N_HF = size(HF_filters,1); % number of frequency bands

%% define trials data
% get time points / indices if trials
trials_start = 1:trialSamples:(Ntrials + 2)*length(timeAxis);
trials_stop = [(trialSamples + 1):trialSamples:(Ntrials + 2)*length(timeAxis)+1] - ones(1, Ntrials + 2);

%% signal params
lBand = 6; % low frequency band (modulating signal)
hBand = 40; % high frequency band (modulated signal)
epsilon_ = 0; % 0.1; % max phase diviation across trials
phiBand = 0; % range of phase offset between low freq. and high freq. signals

%% sensitivity
% prepare data

% coupling data
Nconditions1 = 11;
SNR_pink_noise1 = 0*ones(1,Nconditions1); % dB
SNR_white_noise1 = 12*ones(1,Nconditions1); % dB
chi1 = linspace(0, 1, Nconditions1);

% SNR data
Nconditions2 = 13;
SNR_pink_noise2 = linspace(-12, 12, Nconditions2); % dB

iterations = 100;

%% CREATE AND EVAULATE DATASET (SKIP), ALREADY COMPUTED (NEXT CELL)
PAC_matrices_ALL = zeros(iterations, Nconditions2, Nconditions1, length(PAC_methods));

utils.progress('_start');
for iter=1:iterations
    utils.progress(iter, iterations);
    for cond=1:Nconditions2
        SNR_pink_noise = SNR_pink_noise2(cond) * ones(size(chi1));
        dataset1 = generate_dataset(Ntrials, timeAxis, fs, lBand, hBand, phiBand, chi1, SNR_pink_noise, SNR_white_noise1);
   
        PAC_matrices = analysis(dataset1, PAC_methods, Ntrials, trialSamples, trials_start, trials_stop, LF_filters, HF_filters, fs);
    
        PAC_matrices_ALL(iter, cond, :, :) = PAC_matrices;

    end
end
utils.progress('_erase');
PAC_matrices = squeeze(mean(PAC_matrices_ALL, 1));
save('data/surrogate_PAC.mat', 'PAC_matrices')

%% LOAD DATASET AND PLOT
load('data/surrogate_PAC.mat')

h=visualization.getFigure(0.32);
tl = tiledlayout(1, 4, 'TileSpacing','tight', 'Padding','compact');

for idx=1:length(PAC_methods)
    nexttile
    matrix = squeeze(PAC_matrices(:, :, idx));

    imagesc(matrix);
    clim([min(matrix, [], 'all'), max(matrix, [], 'all')])
    yticks(1:2:Nconditions2)
    yticklabels(SNR_pink_noise2(1:2:end))
    xticks([1, 6, 11])
    xticklabels(sprintfc("%.1f", [0, 0.5, 1]))

    colormap turbo
    cb = colorbar('NorthOutside');
    cb.Label.String = PAC_methods{idx};

end
ylabel(tl, "SNR_{dB} [dB]", 'Interpreter', 'tex')
xlabel(tl, "coupling coefficient \chi [-]", 'Interpreter', 'tex')
title(tl, "sensitivity of PAC methods to coupling strength and noise")

h = visualization.formatFigure(h);

%% save
visualization.saveFigure(h, figs_path + "_full", 'png');

%% generate dataset
function dataset = generate_dataset(Ntrials, timeAxis, fs, lBand, hBand, phiBand, chi, SNR_pink_noise, SNR_white_noise)

trialSamples = length(timeAxis);
t_stop = timeAxis(end);
Nconditions = length(chi);
dataset = zeros(Nconditions, (Ntrials + 2)*length(timeAxis));
% generate data for each condition
for cond=1:Nconditions
    trialsData = zeros(Ntrials + 2, length(timeAxis));
    % each trial is unique (two trials more)
    for tr=1:Ntrials + 2
        signal = synthesis.surrogate(fs, t_stop, lBand, hBand, phiBand, chi(cond));
        % add noise to signal
        signal = synthesis.add_noise(signal, SNR_pink_noise(cond), SNR_white_noise(cond));
        trialsData(tr, :) = signal;
    end
    trialsData = trialsData.';
    dataset(cond, :) = trialsData(:);
end
end

%% analysis function
function PAC_matrices=analysis(dataset, PAC_methods, Ntrials, trialSamples, trials_start, trials_stop, LF_filters, HF_filters, fs)

Nconditions = size(dataset,1);
Nbins = 18; % phase bins for methods: MI, height ratio, SNR

PAC_matrices = zeros(Nconditions, length(PAC_methods));
% iterate over PAC methods
for method_idx=1:length(PAC_methods)
    PAC_method = PAC_methods{method_idx};
    % iterate oevr conditions
    for cond=1:Nconditions
        % FILTER - HILBERT
        signal = dataset(cond, :);
        [~, Phase] = FH.computeHilbert(signal, LF_filters);    
        [Amp, ~] = FH.computeHilbert(signal, HF_filters);
        
        % baseline normalization
        baseline = mean(Amp, 1);
%         Amp = Amp./baseline;
        
        Amp_trials = zeros(Ntrials, trialSamples);
        Phase_trials = zeros(Ntrials, trialSamples);

        % extract trials (ignore first and last due to filtering artefacts)
        for idx=1:Ntrials
            tr = idx + 1;
            T_start = trials_start(tr);
            T_stop = trials_stop(tr);
            % split signal to trials
            Amp_trials(idx, :, :) = Amp(T_start:T_stop, :);
            Phase_trials(idx, :, :) = Phase(T_start:T_stop, :);
        end
        % compute PAC on concat trials
        PAC_matrix = compute_PAC_matrix(Amp_trials, Phase_trials, PAC_method, Nbins, fs);
        PAC_matrices(cond, method_idx, :, :) = PAC_matrix;
    
       
    end
end
end



%% compute PAC

function PAC_matrix = compute_PAC_matrix(Amp_epoch, Phase_epoch, PAC_method, Nbins, fs)
% Amp_epoch, Phase_epoch with size NxTxF where N is number of trials, T is
% time samples, F is number of frequencies

    PAC_matrix = zeros(size(Amp_epoch, 3), size(Phase_epoch, 3));
    % Compute PAC matrix
    for f1=1:size(Amp_epoch, 3)
        for f2 = 1:size(Phase_epoch, 3)
            % get phase and amplitude
            amp = Amp_epoch(:,:, f1).';
            phase = Phase_epoch(:, :, f2).';
            % join trials
            amp = amp(:);
            phase = phase(:);
            switch PAC_method
                case 'MVL'
                    PAC_matrix(f1, f2) = PAC.MVL(amp, phase);
                case 'dPAC'
                    PAC_matrix(f1, f2) = PAC.dMVL(amp, phase);
                case 'MI'
                    PAC_matrix(f1, f2) = PAC.MI(amp, phase, Nbins);
                case 'Heights Ratio'
                    PAC_matrix(f1, f2) = PAC.height_ratio(amp, phase, Nbins);
                case 'PAC SNR'
                    mean_amp4phase = zeros(size(Amp_epoch, 1), Nbins);
                    for tr=1:size(Amp_epoch, 1)
                        amp = squeeze(Amp_epoch(tr, :, f1));
                        phase = squeeze(Phase_epoch(tr, :, f2));
                        mean_amp4phase_ = PAC.average_amp4phase(amp, phase, Nbins);
                        mean_amp4phase(tr, :) = mean_amp4phase_;%./sum(mean_amp4phase_);
                    end
                    % compute SNR
                    PAC_matrix(f1, f2) = var(mean(mean_amp4phase))/mean(var(mean_amp4phase));
                case 'MI_norm'
                    MI_raw = PAC.MI(amp, phase, Nbins);
                    [~, MI_norm] = PAC.surrogate_test(amp, phase, @(Amp, Phase) PAC.MI(Amp, Phase, Nbins), MI_raw, fs);
                    PAC_matrix(f1, f2) = MI_norm;
            end
        end
    end
end

