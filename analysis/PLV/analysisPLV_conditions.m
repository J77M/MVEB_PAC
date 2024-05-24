% Compute PLV between all channels

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));

%% DEFINE paths
data_path = "/home/jur0/project_iEEG/code/data/MVEB_BIP";
[subjects, subjects_paths]= dataUtils.get_subjects(data_path);

output_path = "/home/jur0/project_iEEG/code/data/analysis/PLV_conditions/%s.mat";


% analyzed epoch
epoch = {'t_stim', 't_hold'}; % stimulus
epoch_N = 2; % [s] duration of epoch

%% run analysis for each subject
for s=1:length(subjects)
    fprintf('analysis started for subject %s\n', subjects{s});
    % paths
    subject_path = subjects_paths{s};
    subject_out_path = sprintf(output_path, subjects{s});
    % load data
    [CHANNELS, DATA] = preprocessing.loadData(subject_path);
    DATA = dataUtils.joinSessions(DATA);
    % analysis
    PLV_matrices = analysis(DATA, CHANNELS, epoch, epoch_N);
    save(subject_out_path, "PLV_matrices")
end

%% main function
function PLVmatrices = analysis(DATA, CHANNELS, epoch, epoch_N)
% define filter properties
filters_range = [4,8]; % (Hz) filters for band pass
bandSize = 4;% band size for band pass filters
filter_step = 4;% steps for filters 

% load data
timeAxis = DATA{1}.timeAxis;
ampData = DATA{1}.ampData;
trials = DATA{1}.trials;

fs = DATA{1}.srate;
channelsNum = size(ampData, 2);
Ntrials = length(trials);
epoch_N = round(epoch_N*fs);

% get filters
filters = FH.getFilters(filters_range(1):filter_step:filters_range(2), fs, bandSize);

% get trials difficulties
trials_difficulties = trialsUtils.getTrialsDifficulty(trials);
conditions = [1,2,4,6];
allConditionsNum = 4;
Ntrials = Ntrials /allConditionsNum;

% EXTRACT THETA PHASE 
theta = zeros(channelsNum,length(conditions), Ntrials, epoch_N);
for ch=1:channelsNum
    % F-H
    signal = ampData(:, ch).';
    [~, Phase] = FH.computeHilbert(signal, filters);
    for cond=1:length(conditions)
        trials_indices = find(trials_difficulties == conditions(cond));
        for t=1:length(trials_indices)
            trial = trials(trials_indices(t));
            % extract maintenance
            t_start = trial.(epoch{1});
            t_stop = trial.(epoch{2});
            Phase_epoch = trialsUtils.extractTrialsTimeSegments(Phase, timeAxis, t_start, t_stop);
            % normalize to same size over trials
            Phase_epoch = Phase_epoch(1:epoch_N, :);
            theta(ch, cond, t, :) = Phase_epoch;
        end
    end
end

% compute PLV
PLVchannelsNum = channelsNum;
PLVmatrices = zeros(allConditionsNum, PLVchannelsNum, PLVchannelsNum);
utils.progress('_start');
combinations = PLV.generateCombinations(1:PLVchannelsNum);
idx = 0;
for c=1:length(combinations)
    ch1 = combinations(c, 1);
    ch2 = combinations(c,2);
    trials_PLV = zeros(Ntrials, epoch_N);
    for cond=1:length(conditions)
        utils.progress(idx, length(combinations)*allConditionsNum);
        for t=1:Ntrials
            theta1 = squeeze(theta(ch1,cond, t, :));
            theta2 = squeeze(theta(ch2,cond, t, :));
%             PLV = abs(mean(exp(1i*(theta1 - theta2))));

            trials_PLV(t,:) = exp(1i*(theta1 - theta2));
        end
    idx = idx + 1;
    % concatinate all trials (same as average over mean complex vector across trials)
    PLV_all = reshape(trials_PLV, 1, []);
    PLVmatrices(cond, ch1, ch2) = abs(mean(PLV_all));
    end

end
% transform to symetrical
PLVmatrices(1, :, :) = squeeze(PLVmatrices(1, :, :)) + squeeze(PLVmatrices(1, :, :)).';
PLVmatrices(2, :, :) = squeeze(PLVmatrices(2, :, :)) + squeeze(PLVmatrices(2, :, :)).';
PLVmatrices(3, :, :) = squeeze(PLVmatrices(3, :, :)) + squeeze(PLVmatrices(3, :, :)).';
PLVmatrices(4, :, :) = squeeze(PLVmatrices(4, :, :)) + squeeze(PLVmatrices(4, :, :)).';


end
