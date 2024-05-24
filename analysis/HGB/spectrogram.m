% script to produce spectrogram figures for each HGB memory-related channel
% section (2.7.3)

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));

%% DEFINE DATA PATHS and PARAMETERS
data_path = "/home/jur0/project_iEEG/code/data/MVEB_BIP";
[subjects, subjects_paths]= dataUtils.get_subjects(data_path);

localization_path = "/home/jur0/project_iEEG/code/data/analysis/HGB_channels/%s.mat";
figs_path = "/home/jur0/project_iEEG/code/figs/spectrograms";

% define p value
significance_thresh_pval = 0.01;
%% RUN ANALYSIS
for s=1:length(subjects)
    % paths
    subject_path = subjects_paths{s};
    subject_loc_path = sprintf(localization_path, subjects{s});
    % load localization data
    load(subject_loc_path);
    subject_significance = cell2mat(utils.getChannelsValues(CHANNELS, 'significance'));
    
    selected_channels = find(subject_significance == 1);

    % get max duration with pval < 0.01
    pvals = cell2mat(utils.getChannelsValues(CHANNELS(selected_channels), 'p_val'));
    [~, ~, segments, segments_indices] = utils.get_max_segments(pvals, significance_thresh_pval);

    fprintf('analysis started for subject %s | %d memory related ch.\n', subjects{s}, length(selected_channels));

    % load data
    [CHANNELS, DATA] = preprocessing.loadData(subject_path);
    DATA = dataUtils.joinSessions(DATA);

    % create spectrogram figure
    plotSubject(DATA, CHANNELS, selected_channels, segments, segments_indices, figs_path, subjects{s});
end

%% main function
function plotSubject(DATA, CHANNELS, selected_channels,segments, segments_indices, figs_path, subject)

%------- load data
timeAxis = DATA{1}.timeAxis;
ampData = DATA{1}.ampData;
trials = DATA{1}.trials;

fs = DATA{1}.srate;
Ntrials = length(trials);
ampData = ampData(:, selected_channels);
CHANNELS = CHANNELS(selected_channels);
channelsNum = size(ampData, 2);


%------- define filters for Filter-Hilbert
filters_range = [0,150]; % (Hz) filters for band pass
bandSize = 5;% band size for band pass filters
filter_step = 5;% steps for filters 

% get filters
filters = FH.getFilters(filters_range(1):filter_step:filters_range(2), fs, bandSize);
filtersBands = FH.getFiltersFreq(filters_range(1):filter_step:filters_range(2), bandSize);

Nfilters = size(filters,1); % number of frequency bands

%------- define values for analysis
epochs = {["t_fix", "t_stim"], ["t_stim", "t_hold"], ["t_hold", "t_go"], ["t_go", "t_feedback"]};
epochs_N = round([1,2,2,0.6]*fs); % duration of epochs (s)

% get trials difficulties 
trials_difficulties = trialsUtils.getTrialsDifficulty(trials);
conditions = [1,2,4,6];

%% iterate over channels
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
                Amp_epoch = trialsUtils.extractTrialsTimeSegments(Amp, timeAxis, t_start, t_stop);
                % normalize to same size over trials
                if e==1 % extract  -1s pre stimulus
                    Amp_epoch = Amp_epoch(end - epochs_N(e) + 1: end, :);
                % else crop to match
                else
                    Amp_epoch = Amp_epoch(1:epochs_N(e), :);
                end
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
    
%      baseline normalization
     baseline = squeeze(mean(epochs_values{1}, [1,3])); % baseline [-1.5, -0.5] s pre stimulus
     for e=1:length(epochs)
        epochs_values{e} = 10*log10(epochs_values{e}./baseline);
     end
    
    % create DIR
     dir_path = fullfile(figs_path, CHANNELS(ch).ass_marsLat_name);
     if ~exist(dir_path, 'dir')
        mkdir(dir_path)
    end
    path = fullfile(dir_path, CHANNELS(ch).name  + "_" + subject);
    name = sprintf("%s (%s)", CHANNELS(ch).ass_marsLat_name, subject);
    % plot data
    plot_epoch_data(epochs_values, segments_indices{ch}, segments{ch}, filtersBands, name, path);
end

utils.progress('_erase');
end


%% plotting functions
function plot_epoch_data(epochs_values,segments_indices, segments, filtersBands, name, path)
% Ugly plotting function ... AT YOUR OWN RISK

    Nfilters = size(epochs_values{1}, 2);
    Nconditions = size(epochs_values{1},1);
    conditions = [1,2,4,6];
    
    max_val = max(cellfun(@(x) max(x, [], 'all'), epochs_values));
    min_val = min(cellfun(@(x) min(x, [], 'all'), epochs_values));
    lim = [min_val, max_val];

    offset = 20;

    h = visualization.getFigure(0.65);
    h.Visible = 'off';

    tl = tiledlayout(4,1, 'Padding', 'loose', 'TileSpacing', 'tight'); 


    for c=1:Nconditions
        plot_data = [];
        for e=1:length(epochs_values)
            epoch_values = epochs_values{e};
            epoch_values = squeeze(epoch_values(c, :, :));
            % add offset
            if e > 1
                plot_data = [plot_data, nan(Nfilters, offset), epoch_values];
            else
                plot_data = [plot_data, epoch_values];
            end
        end
        % plot
        nexttile;
        pcolor(plot_data)
        shading interp;
        colormap turbo;
        clim(lim);  

        % set axes
        ax = gca;
        disableDefaultInteractivity(ax);
        ax.Toolbar.Visible = 'off';
        set(ax,'layer','top')

        % set yticcks
        ticks_vals = linspace(0, size(filtersBands,1), 7);
        labels = 25:25:150;
        yticks(ticks_vals(2:end))
        yticklabels(labels)

        t_fix = size(epochs_values{1}, 3);
        t_stim = size(epochs_values{2}, 3);
        t_ret = size(epochs_values{3}, 3);
        t_probe = size(epochs_values{4}, 3);
    
        ticksy = [1, t_fix+offset/2, t_fix+t_stim+ 3/2*offset,t_fix+t_stim+t_ret + 5/2*offset, size(plot_data, 2)-1];
        xticks(ticksy)
        xticklabels([-1, 0, 2, 4, 4.6])
%         xlabel('time [s]')

        % plot segments of significance
        t0 = ticksy(3) + offset/2;
        hold on;
        for seg=1:length(segments_indices)
            plot([t0 + segments_indices(seg), t0 + segments_indices(seg) + segments(seg)], [1 1],... 
                'Marker', '|', 'MarkerSize', 10, 'Color', 'k', 'LineWidth',1.3)
        end
        if c == Nconditions
            ax = gca;
            pos=ax.Position;
            positions = [t_fix/2, t_fix+t_stim/2+offset, t_fix+t_stim+2*offset+t_ret/2, t_fix+t_stim+t_ret+3*offset + t_probe/2];
            width = 0.12;
            TextOffset = 0; %0.01;
            positions = pos(3)*positions/size(plot_data, 2) + pos(1) - width/2; % scale to axis
            texts = {'Baseline', 'Stimulus', 'Retention', 'Probe'};
            for t=1:length(texts)
                annotation('textbox', [positions(t) - TextOffset, 0.05, width, 0], 'string', texts{t},...
                    "HorizontalAlignment", "center", "Color", "black", "FontWeight", "bold",... 
                    'FitBoxToText','on', 'LineWidth', 1);
            end
        end
        title(sprintf('memory load %d', conditions(c)))
    end
    % add ylabel
    ylabel(tl,'frequency [Hz]')
    xlabel(tl,'time [s]')

    % add colorbar
    cb = colorbar(); %add colorbar
    colormap turbo;
    cb.Label.String = 'event-related spectral perturbations [dB]';
    cb.Layout.Tile = 'east';
    caxis(lim);   % set colorbar limits
    title(tl, name, 'Interpreter', 'none');

    h = visualization.formatFigure(h);

    print(h, path + ".png",'-dpng','-r300');
% 
    close(h);
    
end
