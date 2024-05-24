% PAC analysis for subject data, where rather than analyzing each epoch
% separatelly, epochs are concatinated across trials
% sections 2.8.4 - 2.8.5

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));

%% DEFINE paths and parameters

% subjects paths
data_path = "/home/jur0/project_iEEG/code/data/MVEB_BIP";
[subjects, subjects_paths]= dataUtils.get_subjects(data_path);

out_data_path = "/home/jur0/project_iEEG/code/data/analysis/PAC_CHANNELS/%s.mat";

% select method
PAC_method = 'dPAC';


% FILTERS PARAMS FOR LGB 
Nbins = 18; % phase bins for methods: MI, height ratio, SNR
LF_range = [4,8]; % (Hz) range of low freq. signal
HF_range = [30, 50]; % (Hz) range of high freq. signal
LF_bandSize = 4; HF_bandSize = 20; % band size for band pass filters
LF_step = 4; HF_step = 20; % steps for overlapping filters 


%% run analysis for all subjects
for s=1:length(subjects)
    subject_path = subjects_paths{s};
    subject_out_path = sprintf(out_data_path, subjects{s});
    % load data
    [CHANNELS, DATA] = preprocessing.loadData(subject_path);
    DATA = dataUtils.joinSessions(DATA);
    
    fprintf("starting analysis for %s\n", subjects{s});
    % run analysis
    CHANNELS = analysis(DATA, CHANNELS, Nbins, PAC_method, LF_range(1):LF_step:LF_range(2), ... 
        HF_range(1):HF_step:HF_range(2), LF_bandSize, HF_bandSize);
    save(subject_out_path, "CHANNELS")
end

%% ---function analysis

function CHANNELS = analysis(DATA, CHANNELS, Nbins, PAC_method, LF_band, HF_band, LF_bandSize, HF_bandSize)
% define values for analysis
epoch = {'t_hold', 't_go'};
epoch_N = 2;

% --- LOAD DATA
timeAxis = DATA{1}.timeAxis;
ampData = DATA{1}.ampData;
trials = DATA{1}.trials;

fs = DATA{1}.srate;
channelsNum = size(ampData, 2);
Ntrials = length(trials);

% epoch to frames
epoch_N = round(epoch_N.*fs);

% --- compute filters
LF_filters = FH.getFilters(LF_band, fs, LF_bandSize);
HF_filters = FH.getFilters(HF_band, fs, HF_bandSize);

% ---  get trial difficulties
trials_difficulties = trialsUtils.getTrialsDifficulty(trials);
memory_loads = [1,2,4,6];


% --- PAC analysis (iterate over channels)
utils.progress('_start');
for ch=1:channelsNum
    utils.progress(ch, channelsNum);

    % allocate data
    PAC = zeros(1, length(memory_loads));
    
    % FILTER - HILBERT
    signal = ampData(:, ch).';
    [~, Phase] = FH.computeHilbert(signal, LF_filters);    
    [Amp, ~] = FH.computeHilbert(signal, HF_filters);

    % iterate over trials
    Amp_trials = zeros(Ntrials, epoch_N);
    Phase_trials = zeros(Ntrials, epoch_N);

    % extract epoch segments
    for tr=1:Ntrials            
        trial = trials(tr);
        % extract epoch times
        t_start = trial.(epoch{1});
        t_stop = trial.(epoch{2});

        Amp_epoch = trialsUtils.extractTrialsTimeSegments(Amp, timeAxis, t_start, t_stop);
        Phase_epoch = trialsUtils.extractTrialsTimeSegments(Phase, timeAxis, t_start, t_stop);
        % make them the same size
        Amp_epoch = Amp_epoch(1:epoch_N, :);
        Phase_epoch = Phase_epoch(1:epoch_N, :);
        % average over gamma band (for HGB)
        Amp_epoch = mean(Amp_epoch, 2);

        Amp_trials(tr, :) = Amp_epoch;
        Phase_trials(tr, :) = Phase_epoch;
    end

    % PAC for condition
    Amp_trials = Amp_trials.';
    Phase_trials = Phase_trials.';
    for c=1:length(memory_loads)
        % extract trials with the same memory load
        mem_load = memory_loads(c);
        Amp_trials_cond = Amp_trials(:, trials_difficulties == mem_load);
        Phase_trials_cond = Phase_trials(:, trials_difficulties == mem_load);
        % PAC on concat trials
        PAC_val = compute_PAC_matrix(Amp_trials_cond(:), Phase_trials_cond(:), PAC_method, Nbins);
        PAC(c) = PAC_val;
        % compute pval
%         [pval, ~] = PAC.surrogate_test(Amp_trials_cond(:), Phase_trials_cond(:), @(Amp, Phase) PAC.MI(Amp, Phase, Nbins), PAC_val, fs);
%         PAC_MI_pval(c) = pval;
    end     
    % compute correlation
    [rho, corr_p_val] = corr(PAC_MI_raw.', [1 2 4 6]', "Type", "Pearson", "Tail","right");
    % save data to CHANNELS
    CHANNELS(ch).PAC = PAC;
    CHANNELS(ch).PAC_rho = rho;
    CHANNELS(ch).PAC_pval = corr_p_val;

end
utils.progress('_erase');

end

%% functions: from trials to PAC
function PAC_matrix = compute_PAC_matrix(Amp_epoch, Phase_epoch, PAC_method, Nbins)
    if strcmp(PAC_method, 'SNR')
        PAC_matrix = zeros(size(Amp_epoch, 2), size(Phase_epoch, 2), Nbins);    
    else
        PAC_matrix = zeros(size(Amp_epoch, 2), size(Phase_epoch, 2));
    end
    % Compute PAC matrix
    for f1=1:size(Amp_epoch, 2)
        for f2 = 1:size(Phase_epoch, 2)
            % get phase and amplitude
            amp = Amp_epoch(:, f1);
            phase = Phase_epoch(:, f2);
            switch PAC_method
                case 'MVL'
                    PAC_matrix(f1, f2) = PAC.MVL(amp, phase);
                case 'dPAC'
                    PAC_matrix(f1, f2) = PAC.dMVL(amp, phase);
                case 'MI'
                    PAC_matrix(f1, f2) = PAC.MI(amp, phase, Nbins);
                case 'ratio'
                    PAC_matrix(f1, f2) = PAC.height_ratio(amp, phase, Nbins);
                case 'SNR'
                    mean_amp4phase = PAC.average_amp4phase(amp, phase, Nbins);
                    PAC_matrix(f1, f2, :) = mean_amp4phase./sum(mean_amp4phase); % normalize
            end
        end
    end
end

