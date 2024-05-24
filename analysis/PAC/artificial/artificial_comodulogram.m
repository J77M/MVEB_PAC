% NOT PART OF THE THESIS
clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../../lib'));

%% figs path
figs_path = "/home/jur0/project_iEEG/code/figs/OUT/exploratory_compare";


%% DEFINE parameters
% select method
PAC_methods = {'ratio', 'MI', 'MVL', 'dMVL'};
Nbins = 18; % phase bins for methods: MI, height ratio, SNR
Ntrials = 12;
fs = 512; % sampling rate
trial_duration = 2;
t_stop = trial_duration; % signal duration
t_stop = t_stop - 1/fs;
trialSamples = trial_duration*fs;
timeAxis = 0:1/fs:t_stop;
SNR_pink_noise = 0; % dB

lBand = [6,8]; % low frequency band (modulating signal)
hBand = [75, 80]; % high frequency band (modulated signal)

epsilon_ = 0.1; % max phase diviation across trials
phiBand = 0; % range of phase offset between low freq. and high freq. signals

chi = [0, 0.5, 0.9];
Nconditions = 3;

%% define filters for Filter-Hilbert

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

%% generate dataset
dataset = zeros(3, (Ntrials + 2)*length(timeAxis));
% get time points / indices if trials
trials_start = 1:trialSamples:(Ntrials + 2)*length(timeAxis);
trials_stop = [(trialSamples + 1):trialSamples:(Ntrials + 2)*length(timeAxis)+1] - ones(1, Ntrials + 2);
% generate data for each condition
for cond=1:Nconditions
    trialsData = zeros(Ntrials + 2, length(timeAxis));
    % each trial is unique (two trials more)
    for tr=1:Ntrials + 2
        signal = synthesis.surrogate(fs, t_stop, lBand, hBand, phiBand, chi(cond));
        % add noise to signal
        signal = synthesis.add_noise(signal, SNR_pink_noise);
        trialsData(tr, :) = signal;
    end
    trialsData = trialsData.';
    dataset(cond, :) = trialsData(:);
end

%% analysis
PAC_matrices = zeros(Nconditions, length(PAC_methods), N_HF, N_LF);

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
%         baseline = mean(Amp, 1);
%         Amp = Amp./baseline;
        
        Amp_trials = zeros(Ntrials, trialSamples, N_HF);
        Phase_trials = zeros(Ntrials, trialSamples, N_LF);

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
%         if strcmp(PAC_method, 'SNR')
%             PAC_matrix = 10*log10(PAC_matrix);
%         end
        
        PAC_matrices(cond, method_idx, :, :) = PAC_matrix;
        
    
       
    end
end
name = "Surrogate dataset";
plot_trial(PAC_matrices, PAC_methods, LF_filtersBands, HF_filtersBands, name, figs_path)

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
                case 'dMVL'
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
                        mean_amp4phase(tr, :) = mean_amp4phase_;% ./sum(mean_amp4phase_);
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
function plot_trial(PAC_matrix, PAC_methods, LF_filtersBands, HF_filtersBands,name, path)
    cmap = turbo;
%     cbar_legend = PAC_method;

    % create figure
%     h = figure('position',[370,340,700,700], "visible", "on");
%     h = figure('position',[370,340,850,600], "visible", "on");

%     h = figure('position',[370,340,850,650], "visible", "on");
    h =visualization.getFigure(0.75);
    h.Visible = 'on';


    tl = tiledlayout(4,3, 'Padding', 'loose', 'TileSpacing', 'tight'); 
     % get colormap limit
    limits = zeros(length(PAC_methods), 2);
    for m=1:length(PAC_methods)
        PAC_matrix_m = squeeze(PAC_matrix(:, m, :, :));
        limits(m, :) = [min(PAC_matrix_m, [],"all"), max(PAC_matrix_m, [],"all")];
    end

    % plot epochs
    subplots_titles = {'$\chi = 0$', '$\chi = 0.5$', '$\chi = 0.9$'};
    colors = {'#000000', '#494b4d', '#666666'};

    for m=1:length(PAC_methods)
        lim = limits(m, :);
        for e=1:3
            nexttile;   
            % plot data
            plot_matrix(squeeze(PAC_matrix(e, m, :, :)), HF_filtersBands, LF_filtersBands, lim, cmap);
            if e==2
                title(PAC_methods{m})
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
            if m== 4
                ax.UserData = e;
            end
        end
        % set colorbar
        cb = colorbar(); %add colorbar
        colormap(cb,cmap)
        cb.Label.String = PAC_methods{m};
%         cb.Layout.Tile = 'east';
        caxis(lim);   % set colorbar limits
    end

    % add axes labels
    ylabel(tl,'amplitude frequency [Hz]')
    xlabel(tl,'phase frequency [Hz]')
    % add title
    title(tl, name, 'Interpreter', 'none')
    h = visualization.formatFigure(h, 'on');

    % add annotation
    pause(0.5)
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
            'FitBoxToText','on', 'LineWidth', 2, 'EdgeColor', colors{e}, 'FontSize', 12, ...
            'Interpreter','latex');
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

    

    h = visualization.formatFigure(h, 'on');
%     print(h, path + ".png",'-dpng','-r300');
    visualization.saveFigure(h, path);


%     close(h);
end
%%
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
    

%     xlabel('phase frequency [Hz]')
%     ylabel('amplitude frequency [Hz]')
    
end