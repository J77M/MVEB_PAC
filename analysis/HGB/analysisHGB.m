% main script for section Memory-related high-gamma (2.7.1, 2.7.2)
% localization of channels involved in working memory by HGB power

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));

%% DEFINE DATA PATHS and PARAMETERS
data_path = "/home/jur0/project_iEEG/code/data/MVEB_BIP";
out_data_path = "/home/jur0/project_iEEG/code/data/analysis/HGB_channels/%s.mat";

% load subjects
[subjects, subjects_paths]= dataUtils.get_subjects(data_path);

% set params for significance evaulation
significance_thresh_pval = 0.01; % pvalue for correlation
significance_thresh_segment_length = 26; % ~ 50 ms for segment length

%% RUN ANALYSIS
for s=1:length(subjects)
    fprintf('analysis started for subject %s\n', subjects{s});
    % paths
    subject_path = subjects_paths{s};
    subject_out_path = sprintf(out_data_path, subjects{s});
    % load data and join sessions
    [CHANNELS, DATA] = preprocessing.loadData(subject_path);
    DATA = dataUtils.joinSessions(DATA);
    
    % run analysis (obtain relative HGB power for each channel and contition)
    CHANNELS = runAnalysis(DATA, CHANNELS);
    
    % evaulate significance
    pvals = cell2mat(utils.getChannelsValues(CHANNELS, 'p_val'));
    [max_segments, ~] = utils.get_max_segments(pvals, significance_thresh_pval);
    significance = max_segments >= significance_thresh_segment_length;
    fprintf("%d significant channels\n", sum(significance));
    % add to channels
    CHANNELS = arrayfun(@(CHAN, signif) setfield(CHAN, 'significance', signif), CHANNELS, significance);
    
    % save data
    save(subject_out_path, "CHANNELS")
end

%% MAIN ANALYSIS FUNCTION
function CHANNELS = runAnalysis(DATA, CHANNELS)
% -------define analysis parameters

conditions = [1,2,4,6]; % memory loads
% define epochs (general script, could be applied to other epochs)
epochs = {["t_fix", "t_stim"], ["t_stim", "t_hold"], ["t_hold", "t_go"], ["t_go", "t_feedback"]};
epochs_N = [1,2,2,0.5]; % duration of epochs in secons
baseline_time = [1.2, 0.2]; % s before stimulus
SELECTED_EPOCH = 3; % select maintenance epoch (index)

% define filter properties
filters_range = [50,120]; % (Hz) filters for band pass
bandSize = 5;% band size for band pass filters
filter_step = 5;% steps for filters 

%-------LOAD DATA

timeAxis = DATA{1}.timeAxis;
ampData = DATA{1}.ampData;
trials = DATA{1}.trials;
fs = DATA{1}.srate;
Ntrials = length(trials);
channelsNum = size(ampData, 2);

% convert durations of epochs to frames
epochs_N = epochs_N.*fs;

% get filters
filters = FH.getFilters(filters_range(1):filter_step:filters_range(2), fs, bandSize);

Nfilters = size(filters,1); % number of frequency bands

% get trials difficulties
trials_difficulties = trialsUtils.getTrialsDifficulty(trials);


%-------hilber transform analysis (iterate over channels)
utils.progress('_start');
for ch=1:channelsNum
    utils.progress(ch, channelsNum);

    % FILTER - HILBERT
    signal = ampData(:, ch).';
    [Amp, ~] = FH.computeHilbert(signal, filters);
    
    % allocate mem
    epochs_values = cell(1, length(epochs));
    for e=1:length(epochs)
        epochs_values{e} = zeros(length(conditions), Ntrials/length(conditions), Nfilters, epochs_N(e));
    end
    % iterate over trials
    for c=1:length(conditions)
        % get indices of trials with same condition
        trial_indices = find(trials_difficulties == conditions(c));
        % iterate over trials
        for tr=1:length(trial_indices)
            trial = trials(trial_indices(tr));
            % iterate over epochs
            for e=1:length(epochs)
                epoch_times = epochs{e};
                t_start = trial.(epoch_times(1));
                t_stop = trial.(epoch_times(2));
                if e==1 % extract  [-1.2, -0.2] pre stimulus
                    t_start_prev = t_start;
                    t_start = t_stop - baseline_time(1);
                    t_stop = t_stop - baseline_time(2);
                    assert(t_start > t_start_prev || t_stop > t_start_prev) 
                end
                Amp_epoch = trialsUtils.extractTrialsTimeSegments(Amp, timeAxis, t_start, t_stop);
                % normalize to same size over trials
                Amp_epoch = Amp_epoch(1:epochs_N(e), :);
                Power_epoch = Amp_epoch.^2;
                epochs_values{e}(c, tr, :, :) = Power_epoch.';
            end
        end
    end
   
    % average over trials
     for e=1:length(epochs)
         epoch_average = squeeze(mean(epochs_values{e}, 2));
        epochs_values{e} = epoch_average;
     end
    
     % baseline normalization
     baseline = squeeze(mean(epochs_values{1}, [1,3])); % baseline [-1.5, -0.5] s pre stimulus
     for e=1:length(epochs)
        epochs_values{e} = epochs_values{e}./baseline;
     end

     % extract maintainance and average over HG band
     maintainance = squeeze(mean(epochs_values{SELECTED_EPOCH}, 2));
 
     % correlation with memory load
     [rho ,pval] = corr(maintainance, [1,2,4,6].', "Type", "Pearson", "Tail","right");
    
     % save to CHANNELS array struct
     CHANNELS(ch).p_val = pval;
     CHANNELS(ch).rho = rho;

end
utils.progress('_erase');
end
