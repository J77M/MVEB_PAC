% figures of surrogate data (ugly code I know, but It was painful)
% 1) components of data
% 2) filtered data

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));
%% save path
save_path = "/home/jur0/project_iEEG/code/figs/OUT/surrogate_";

%% create data
fs = 512;
t_stop = 14*2;

fp = 6;
fa = 40;
phi_c =  0; 
coupling = 0.1;
% phase signal
K_fp = 1;
% amplitude signal
K_fa = 0.5;    

pink_noise_SNR = 0; % dB

timeAxis = 0:1/fs:t_stop;
ch = coupling*ones(1, length(timeAxis));


[x_fp, x_fa] = synthesis.surrogate_components(fp, fa, phi_c, timeAxis, ch);

x_fa = K_fa * x_fa;
x_fp = K_fp * x_fp;
signal_clear = x_fa + x_fp;
signal = synthesis.add_noise(signal_clear, pink_noise_SNR);

%% plot 
time_selection = 1:round(3*fs/fp);
t = timeAxis(time_selection);
x_fa_ = x_fa(time_selection);
x_fp_ = x_fp(time_selection);
x = signal_clear(time_selection);
y = signal(time_selection);

h = visualization.getFigure(0.3);
tiledlayout(1,2, 'Padding', 'compact', 'TileSpacing', 'compact'); 

nexttile
p1 = plot(t, x, "LineWidth",2.5, 'Color', '#0072BD'); hold on;
p2 = plot(t, x_fa_, "LineWidth",2.5, 'Color', '#D95319'); hold on;
p3 = plot(t, x_fp_, "LineWidth",2.5, 'Color', '#77AC30'); hold on;
title("(A) Components of artificial signal")
xlim([0, max(t)])
% lgd = legend({'$x(t)$','$x_a(t)$', '$x_p(t)$'},'Interpreter','latex', 'FontSize', 13, 'NumColumns', 3, 'Location', 'southeast');

xlabel("t [s]", 'Interpreter','latex')
ylabel('amplitude [$\mu V$]', 'Interpreter', 'latex')

nexttile
p4 = plot(t, y, "LineWidth",2.5, 'Color', "#A2142F"); hold on;
plot(t, x, "LineWidth",2.5, 'Color', '#0072BD'); hold on;

xlabel("t [s]", 'Interpreter','latex')
ylabel('amplitude [$\mu V$]', 'Interpreter', 'latex')
title("(B) Artificial signal with noise")
xlim([0, max(t)])

leg = legend([p2, p3, p1, p4], {'$x_H(t)$', '$x_L(t)$', '$x(t)$','$s(t)$'}, ...
    'Interpreter','latex', 'FontSize', 13, 'Orientation', 'horizontal', 'Location', 'southeast');
leg.Layout.Tile = 'south';

h = visualization.formatFigure(h);

%% save
% print(h, save_path + "components" + ".png",'-dpng','-r300');
visualization.saveFigure(h, save_path + "components", 'pdf');


%% filtered data 
LF_range = [4,8]; % (Hz) range of low freq. signal
HF_range = [30, 50]; % (Hz) range of high freq. signal
LF_bandSize = 4; HF_bandSize = 20; % band size for band pass filters
LF_step = 4; HF_step = 20; % steps for overlapping filters 
% get filters
LF_filters = FH.getFilters(LF_range(1):LF_step:LF_range(2), fs, LF_bandSize);
HF_filters = FH.getFilters(HF_range(1):HF_step:HF_range(2), fs, HF_bandSize);

[~, Phase] = FH.computeHilbert(signal_clear, LF_filters);    
[Amp, ~] = FH.computeHilbert(signal_clear, HF_filters);

[~, PhaseS] = FH.computeHilbert(signal, LF_filters);    
[AmpS, ~] = FH.computeHilbert(signal, HF_filters);

% time selection
time_selection = round(fs/fp):round(9*fs/fp);
t = timeAxis(time_selection);
x_fa_ = x_fa(time_selection);
x_fp_ = x_fp(time_selection);
x = signal_clear(time_selection);
y = signal(time_selection);
Amp_ = Amp(time_selection);
Phase_ = Phase(time_selection);
AmpS_ = AmpS(time_selection);
PhaseS_ = PhaseS(time_selection);

%% plot
h = visualization.getFigure(0.3);
tiledlayout(1,2, 'Padding', 'compact', 'TileSpacing', 'tight'); 

% amp
nexttile
yyaxis left
p4 = plot(t, Amp_, "LineWidth",2.5, 'Color', "#D95319"); hold on;
ylabel("amplitude [$\mu V$]", 'Interpreter','latex')

yyaxis right
plot(t, Phase_, "LineWidth",2.5, 'Color', '#77AC30'); hold on;
ylabel("phase [rad]", 'Interpreter','latex')
yticks([-pi, -pi/2, 0, pi/2, pi])
yticklabels({'$-\pi$', '$-\pi/2$', '0', '$\pi/2$', '$\pi$'})
xlim([min(t), max(t)])

ax = gca;
ax.YAxis(1).Color = '#D95319';
ax.YAxis(2).Color = '#77AC30';
ax.TickLabelInterpreter = 'latex';

xlabel("t [s]", 'Interpreter','latex')
title("\textbf{(A)} $x(t)$", 'Interpreter','latex')


nexttile
yyaxis left
p1 = plot(t, AmpS_, "LineWidth",2.5, 'Color', "#D95319"); hold on;
ylabel("amplitude [$\mu V$]", 'Interpreter','latex')

yyaxis right
p2 = plot(t, PhaseS_, "LineWidth",2.5, 'Color', '#77AC30'); hold on;
ylabel("phase [rad]", 'Interpreter','latex')
yticks([-pi, -pi/2, 0, pi/2, pi])
yticklabels({'$-\pi$', '$-\pi/2$', '0', '$\pi/2$', '$\pi$'})
xlim([min(t), max(t)])

ax = gca;
ax.YAxis(1).Color = '#D95319';
ax.YAxis(2).Color = '#77AC30';
ax.TickLabelInterpreter = 'latex';

xlabel("t [s]", 'Interpreter','latex')

title("\textbf{(B)} $s(t)$", 'Interpreter','latex')


leg = legend([p1, p2], {'$A(t)$', '$\varphi(t))$'}, ...
    'Interpreter','latex', 'FontSize', 12, 'Orientation', 'horizontal', 'Location', 'southeast');
leg.Layout.Tile = 'south';

h = visualization.formatFigure(h);

%% save
% print(h, save_path + "analytic_signal" + ".png",'-dpng','-r300');
visualization.saveFigure(h, save_path + "analytic_signal", 'pdf');


%% PAC methods
[~, Phase] = FH.computeHilbert(signal, LF_filters);    
[Amp, ~] = FH.computeHilbert(signal, HF_filters);

Amp_ = Amp(fs:end-fs);
Phase_ = Phase(fs:end-fs);
Nbins = 18;
p_bins = linspace(-pi, pi, Nbins);

h = visualization.getFigure(0.4);
tl = tiledlayout(1,3, 'Padding', 'compact', 'TileSpacing', 'tight'); 

% AVERAGE AMP 4 PHASE (SNR)
ax = nexttile;
hold on;
trials_data = zeros(12, Nbins);
for tr=1:12
    Amp_tr = Amp(tr*2*fs:(tr+1)*2*fs);
    Phase_tr = Phase(tr*2*fs:(tr+1)*2*fs);
    amp4phase = PAC.average_amp4phase(Amp_tr, Phase_tr, Nbins);
%     amp4phase = amp4phase./sum(amp4phase);
    leg_trial = plot(p_bins, amp4phase, 'Color', [.6 .6 .6, 0.6], 'LineWidth',1, 'LineStyle','-');
    trials_data(tr, :) = amp4phase;
end
% amp4phase = mean(trials_data);
amp4phase = PAC.average_amp4phase(Amp_, Phase_, Nbins);
leg_amp4phase = plot(p_bins, amp4phase, 'LineWidth',2.5, 'Color', '#0072BD');
ylim([0, max(trials_data, [], 'all') + 0.1])
xlim([min(p_bins), max(p_bins)])
title("(A) Height Ratio")
xticks([-pi, -pi/2, 0, pi/2, pi])
xticklabels({'$-\pi$', '$-\pi/2$', '0', '$\pi/2$', '$\pi$'})
ax.TickLabelInterpreter = 'latex';
% ylabel("$\langle A \rangle_{\phi (j)}$", 'Interpreter','latex')
ylabel("amplitude [$\mu V$]", 'Interpreter','latex')
xlabel("phase bin $k$ [rad]", 'Interpreter','latex');

% HEIGHT RATIO
% ax = nexttile(2);
% amp4phase = PAC.average_amp4phase(Amp_, Phase_, Nbins);
% plot(p_bins, amp4phase, 'LineWidth',2.5, 'Color', '#0072BD'); hold on;
% ylim([0.2, max(amp4phase) + 0.15])
% xlim([min(p_bins), max(p_bins)])
% title("(B) Height Ratio")
% xticks([-pi, -pi/2, 0, pi/2, pi])
% xticklabels({'$-\pi$', '$-\pi/2$', '0', '$\pi/2$', '$\pi$'})
% ax.TickLabelInterpreter = 'latex';
% ylabel("amplitude [$\mu V$]", 'Interpreter','latex')
% % xlabel("phase bin $k$ [rad]", 'Interpreter','latex');


% PROB. DISTRIBUTION (MI)
ax = nexttile;
hold on;
amp4phase_prob = amp4phase./sum(amp4phase);
% bar(p_bins,ones(size(p_bins))/length(p_bins))
leg_bar = bar(p_bins,amp4phase_prob, 'FaceColor', '#4DBEEE');
ylim([0, 0.1])
xlim([min(p_bins)-0.2, max(p_bins)+0.2]);
title("(C) MI")
xticks([-pi, -pi/2, 0, pi/2, pi])
xticklabels({'$-\pi$', '$-\pi/2$', '0', '$\pi/2$', '$\pi$'})
ax.TickLabelInterpreter = 'latex';
% ylabel("$\langle A \rangle_{\phi (j)}$", 'Interpreter','latex')
ylabel("probability [-]", 'Interpreter','latex')
xlabel("phase bin $k$ [rad]", 'Interpreter','latex');




% POLAR PLOT (MVL)
ax = nexttile;
% Phase_ = Phase_(1:fs);
% Amp_ = Amp_(1:fs);
leg_trialP = polarplot(Phase_, Amp_, '.', 'MarkerSize', 8, 'Color', [.6 .6 .6, 0.1]);
ax = gca;
ticks1 = linspace(0, max(Amp_), 4);
ax.RTick = ticks1;
ax.RTickLabel = sprintfc('%.1f',ticks1);
ax.RAxisLocation = 90;

ax.RAxis.FontSize = 11;
% ax.RAxis.FontWeight = 'bold';
max_val = max(Amp_);
rlim([0, max_val + 0.2])

hold on

% plot mean amp4phase
polarplot(p_bins, amp4phase, 'Color', '#0072BD', 'LineWidth', 2.5)

z = mean(Amp_.*exp(1i*Phase_));
ph = angle(z); 
am = abs(z);

% plot MVL
polarplot([ph, ph], [0, max(Amp_)], 'Color', '#A2142F', 'LineWidth',3)
leg_MVL = polarplot( ph, max(Amp_)-0.03, 'Color', '#A2142F', 'Marker', '>', 'MarkerSize', 10, 'MarkerFaceColor', '#A2142F');
% set to radians
ax.ThetaAxisUnits = 'radians';
ax.TickLabelInterpreter = 'latex';

ticks2 = linspace(0, am, 4);
rlbl = sprintfc('%.2f',ticks2(2:end));
ticks2coordsR = ticks1(2:end);
ticks2coordsTh = ones(1,3)*(-pi/2);

% [ticks2coordsX, ticks2coordsY] = pol2cart(ticks2coordsTh, ticks2coordsR);
% ticks2coordsY = ticks2coordsY- 0.1;
% ticks2coordsX = ticks2coordsX - 0.1;
% [ticks2coordsTh, ticks2coordsR] = cart2pol(ticks2coordsX, ticks2coordsY);
text(ticks2coordsTh, ticks2coordsR, rlbl, 'Color','#A2142F', 'FontWeight','normal', 'Interpreter','latex');          % Label Radii
set(ax,'layer','top')

% add legend
ax = tl.Children(3);
tmp_vec = quiver(ax, 0, 1, 'Color', '#A2142F', 'LineWidth',2);
% tmp_vec.Visible = 'of';

leg = legend([leg_amp4phase, leg_trial, leg_bar, leg_trialP, tmp_vec],...
    {'$\langle A \rangle_{\phi}(k)$', '$\langle A_{tr} \rangle_{\phi}(k)$', "$f(k)$",...
    '$[A(t), \varphi(t)]$', 'MVL'}, 'Interpreter', 'latex', 'AutoUpdate','off');
leg.Orientation = 'horizontal';
leg.Layout.Tile = 'south';

title("(D) MVL")

h = visualization.formatFigure(h);
% ADD ANOTATION to HEIGHT RATIO
ax = tl.Children(4);
plot(ax, p_bins, min(amp4phase)*ones(size(p_bins)), 'k--')
plot(ax, p_bins, max(amp4phase)*ones(size(p_bins)), 'k--')

% annotation('textarrow',xnorm(x),ynorm(y),'string','Arrow Text');
pause(1)
ax = tl.Children(4);
% Define helper funcitons to normalize from axis coordinates to normalized position in figure.
xnorm = @(x)((x-ax.XLim(1))./(ax.XLim(2)-ax.XLim(1))).*ax.InnerPosition(3)+ax.InnerPosition(1);
ynorm = @(y)((y-ax.YLim(1))./(ax.YLim(2)-ax.YLim(1))).*ax.InnerPosition(4)+ax.InnerPosition(2);

[v, idx] = max(amp4phase);
x = [p_bins(idx), p_bins(idx)]; 
y = [min(amp4phase), max(amp4phase)]; 
annotation('doublearrow', xnorm(x), ynorm(y));

text(ax, -1.3, min(amp4phase) + 0.03, '$h_{min}$','Interpreter','latex');
text(ax, -2, max(amp4phase) + 0.03, '$h_{max}$','Interpreter','latex');
centr = (max(amp4phase) - min(amp4phase))/2 + min(amp4phase);
text(ax, 0.2, centr, '$h_{diff}$','Interpreter','latex');



h = visualization.formatFigure(h);

%% save
% print(h, save_path + "PAC_methods" + ".png",'-dpng','-r300');
visualization.saveFigure(h, save_path + "PAC_methods", 'png');

