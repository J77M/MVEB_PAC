% Compute comodulogram figures for PAC memory-related channels
% selction 2.8.6

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));

%% DEFINE paths and params
% path
data_path = "/home/jur0/project_iEEG/code/data/MVEB_BIP";
[subjects, subjects_paths]= dataUtils.get_subjects(data_path);

data_path_PAC = "/home/jur0/project_iEEG/code/data/analysis/PAC_CHANNELS/%s.mat";
% figs path
figs_path = "/home/jur0/project_iEEG/code/figs/PAC_analysis/PAC_correlation_LGB_dPAC";

% select method
PAC_method = 'dPAC';
PAC_methods = {'MVL', 'dPAC', 'MI', 'ratio', 'MI_norm'};
Nbins = 18; % phase bins for methods: MI, height ratio, SNR

% set p-value
p_val_thresh = 0.05;

%% run analysis for all subjects
for s=1:length(subjects)
    subject_path = subjects_paths{s};
    subject_path_PAC = sprintf(data_path_PAC, subjects{s});
    % load PAC data
    load(subject_path_PAC)
    
    % find significant channels
    corr_pvals = cell2mat(utils.getChannelsValues(CHANNELS, 'PAC_pval'));
    select_PAC = find(corr_pvals < p_val_thresh);
    
    % load data
    [CHANNELS, DATA] = preprocessing.loadData(subject_path);
    DATA = dataUtils.joinSessions(DATA);

    fprintf("starting analysis for %s\n", subjects{s});
    fprintf("significant PAC for %d out of %d channels\n", length(select_PAC), length(CHANNELS));

    % select only significant PAC values
    CHANNELS = CHANNELS(select_PAC);
    DATA{1}.ampData = DATA{1}.ampData(:, select_PAC);
    % compute comodulogram and plot
    analysis(DATA, CHANNELS, PAC_method, Nbins, subjects{s}, figs_path);
end

%% ---function analysis
function analysis(DATA, CHANNELS, PAC_method, Nbins, subject, figs_path)


%--- LOAD DATA
timeAxis = DATA{1}.timeAxis;
ampData = DATA{1}.ampData;
trials = DATA{1}.trials;
fs = DATA{1}.srate;
channelsNum = size(ampData, 2);
Ntrials = length(trials);

%---  define epochs
% epochs = {["t_fix", "t_stim"], ["t_stim", "t_hold"], ["t_hold", "t_go"], ["t_go", "t_feedback"]};
% epochs_N = round([1,2,2,0.6]*fs);

epochs = {["t_fix", "t_stim"], ["t_stim", "t_hold"], ["t_hold", "t_go"]};
epochs_N = round([1,2,2]*fs);

baseline_time = [1.2, 0.2]; % s before stimulus


trials_difficulties = trialsUtils.getTrialsDifficulty(trials);
conditions = [1,2,4,6];

%--- define filters for Filter-Hilbert

% define filter properties
LF_range = [2,12]; % (Hz) range of low freq. signal
HF_range = [20, 150]; % (Hz) range of high freq. signal
LF_bandSize = 2; HF_bandSize = 20; % band size for band pass filters
LF_step = 1; HF_step = 5; % steps for overlapping filters 

% get filters
LF_filters = FH.getFilters(LF_range(1):LF_step:LF_range(2), fs, LF_bandSize);
HF_filters = FH.getFilters(HF_range(1):HF_step:HF_range(2), fs, HF_bandSize);
LF_filtersBands = FH.getFiltersFreq(LF_range(1):LF_step:LF_range(2), LF_bandSize);
HF_filtersBands = FH.getFiltersFreq(HF_range(1):HF_step:HF_range(2), HF_bandSize);

N_LF = size(LF_filters,1); N_HF = size(HF_filters,1); % number of frequency bands


%---  PAC analysis (iterate over channels)
utils.progress('_start');
for ch=1:channelsNum

    utils.progress(ch, channelsNum);    
    % FILTER - HILBERT
    signal = ampData(:, ch).';
    [~, Phase] = FH.computeHilbert(signal, LF_filters);    
    [Amp, ~] = FH.computeHilbert(signal, HF_filters);  
    
    PAC_matrices = zeros(length(epochs), length(conditions), N_HF, N_LF);

    % iterate over epochs
    for e=1:length(epochs)
        epoch_times = epochs{e};
        % iterate over trials
        Amp_trials = zeros(Ntrials, epochs_N(e), N_HF);
        Phase_trials = zeros(Ntrials, epochs_N(e), N_LF);

        % extract epoch segments
        for tr=1:Ntrials            
            trial = trials(tr);
            % extract epoch times
            t_start = trial.(epoch_times(1));
            t_stop = trial.(epoch_times(2));
            if e==1 % extract  [-1.2, -0.2] pre stimulus
                t_start_prev = t_start;
                t_start = t_stop - baseline_time(1);
                t_stop = t_stop - baseline_time(2);
                assert(t_start > t_start_prev || t_stop > t_start_prev) 
            end

            Amp_epoch = trialsUtils.extractTrialsTimeSegments(Amp, timeAxis, t_start, t_stop);
            Phase_epoch = trialsUtils.extractTrialsTimeSegments(Phase, timeAxis, t_start, t_stop);
            % make them the same size
            Amp_epoch = Amp_epoch(1:epochs_N(e), :);
            Phase_epoch = Phase_epoch(1:epochs_N(e), :);

            Amp_trials(tr, :, :) = Amp_epoch;
            Phase_trials(tr, :, :) = Phase_epoch;
        end

        % PAC for condition
        
        for c=1:length(conditions)
            % extract trials with the same memory load
            mem_load = conditions(c);
            Amp_trials_cond = Amp_trials(trials_difficulties == mem_load,:, :);
            Phase_trials_cond = Phase_trials(trials_difficulties == mem_load, :, :);
            % PAC on concat trials
            PAC_matrix = compute_PAC_matrix(Amp_trials_cond, Phase_trials_cond, PAC_method, Nbins, fs);
            PAC_matrices(e, c, :, :) = PAC_matrix;
        end

    end
        newPAC_matrices = PAC_matrices;
    
    % create figures (path and save)
    fig_folder = fullfile(figs_path, PAC_method);
    if ~exist(fullfile(fig_folder, CHANNELS(ch).ass_marsLat_name), 'dir')
       mkdir(fullfile(fig_folder , CHANNELS(ch).ass_marsLat_name))
    end

    path1 = fullfile(fig_folder, CHANNELS(ch).ass_marsLat_name, subject + "_" + CHANNELS(ch).name);
    
    name = sprintf("%s (%s)", CHANNELS(ch).ass_marsLat_name, subject);
    plot_trial(newPAC_matrices, PAC_method, LF_filtersBands, HF_filtersBands, name, path1)    

end
utils.progress('_erase');

end

%% functions
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
                case 'ratio'
                    PAC_matrix(f1, f2) = PAC.height_ratio(amp, phase, Nbins);
                case 'SNR'
                    mean_amp4phase = zeros(size(Amp_epoch, 1), Nbins);
                    for tr=1:size(Amp_epoch, 1)
                        amp = squeeze(Amp_epoch(tr, :, f1));
                        phase = squeeze(Phase_epoch(tr, :, f2));
                        mean_amp4phase_ = PAC.average_amp4phase(amp, phase, Nbins);
                        mean_amp4phase(tr, :) = mean_amp4phase_./sum(mean_amp4phase_);
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

%% plotting functions

function plot_trial(PAC_matrix, PAC_method, LF_filtersBands, HF_filtersBands,name, path)
    cmap = turbo;
    cbar_legend = PAC_method;

    h =visualization.getFigure(0.75);
    h.Visible = 'off';


    tl = tiledlayout(4,3, 'Padding', 'loose', 'TileSpacing', 'tight'); 
     % get colormap limit
    lim = [min(PAC_matrix, [],"all"), max(PAC_matrix, [],"all")];

    % plot epochs
%     subplots_titles = {'Stimulus', 'Retention', 'Probe'};
    subplots_titles = {'Baseline', 'Stimulus', 'Retention'};

%     colors = {'#000000', '#494b4d', '#666666'};
    colors = {'#666666', '#494b4d', '#000000'};

    conditions = [1,2,3,4];
    memory_loads = [1,2,4,6];
    for c=1:length(conditions)
        cond = conditions(c);
        for e=1:3
            nexttile;   
            % plot data
            plot_matrix(squeeze(PAC_matrix(e, cond, :, :)), HF_filtersBands, LF_filtersBands, lim, cmap);
            if e==2
                title(sprintf("memory load %d", memory_loads(c)))
            end
            % set axes
            ax = gca;
            disableDefaultInteractivity(ax);
            ax.Toolbar.Visible = 'off';
            ax.XTickLabelRotation = 0;
            ax.XColor = colors{e};
            ax.YColor = colors{e};
            ax.LineWidth = 2.5;
            set(ax,'layer','top')
            % set epoch to user data (for later annotation)
            if c== 4
                ax.UserData = e;
            end
        end
    end

    % add colorbar
    cb = colorbar(); %add colorbar
    colormap(cb,cmap)
    cb.Label.String = cbar_legend;
    cb.Layout.Tile = 'east';
    caxis(lim);   % set colorbar limits
    
    % add annotation
    pause(0.1)
    axes_all = findall(tl, 'Type', 'Axes', '-property', 'UserData');
    axes_epochs = axes_all(arrayfun(@(x) ~isempty(x.UserData), axes_all));
    axes_epochs = axes_epochs(end:-1:1);
    for e=1:3
        ax = axes_epochs(e);
        width = 0.12;
        posAx = ax.Position;
        text_pos = [posAx(1) + posAx(3)/2 - width/2, 0.043, width, 0];
        anot = annotation('textbox', text_pos, 'string', subplots_titles{e},...
            "HorizontalAlignment", "center", "Color", colors{e}, "FontWeight", "bold",... 
            'FitBoxToText','on', 'LineWidth', 2, 'EdgeColor', colors{e}, 'FontSize', 12);
        % add annotation lines
        pause(0.1)
        posAn = anot.Position;
        heightL = 0.01;
        annotation('line',[posAn(1), posAx(1)],[posAn(2) + posAn(4)/2, posAn(2) + posAn(4)/2],...
            'Color', colors{e}, 'LineWidth',2);
        annotation('line',[posAn(1) + posAn(3), posAx(1) + posAx(3)], ...
            [posAn(2) + posAn(4)/2, posAn(2) + posAn(4)/2], 'Color', colors{e}, 'LineWidth',2);
    
        annotation('line',[posAx(1), posAx(1)], ...
            [posAn(2) + posAn(4)/2 - heightL, posAn(2) + posAn(4)/2 + heightL], ... 
            'Color', colors{e}, 'LineWidth',2);
        annotation('line',[posAx(1) + posAx(3), posAx(1) + posAx(3)], ...
            [posAn(2) + posAn(4)/2 - heightL, posAn(2) + posAn(4)/2 + heightL], ...
            'Color', colors{e}, 'LineWidth',2);
    end

    
    % add axes labels
    ylabel(tl,'amplitude frequency [Hz]')
    xlabel(tl,'phase frequency [Hz]')
    % add title
    title(tl, name, 'Interpreter', 'none')

    h = visualization.formatFigure(h, 'on');
    print(h, path + ".png",'-dpng','-r300');

    close(h);
end

%% --- plot comudologram
function plot_matrix(PAC_matrix, Hfilters, Lfilters, lim, cmap)
    pcolor(PAC_matrix)
    shading interp;
    colormap(cmap);
%     colormap turbo;
    clim(lim);  
    
    axis xy %origin in lower left; otherwise imagesc flips it weird
    xticks(1:size(PAC_matrix, 2))
    xticklabels(Lfilters(:, 1) + (Lfilters(:, 2) - Lfilters(:, 1))/2)
    
    yticks(1:4:size(PAC_matrix, 1))
    Hlabels = Hfilters(:, 1) + (Hfilters(:, 2) - Hfilters(:, 1))/2;
    yticklabels(Hlabels(1:4:end)) % TODO check
    
    
end