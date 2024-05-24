% figure 3.4 (A), significant channels 3D plot

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));

%% define paths and parameters
data_path = "/home/jur0/project_iEEG/code/data/analysis/PAC_CHANNELS";

[subjects, subjects_paths]= dataUtils.get_subjects(data_path);
save_path = "/home/jur0/project_iEEG/code/figs/OUT/PAC_localization_channels";
marsAtlasPath = "/home/jur0/project_iEEG/code/data/MarsAtlas/colin27_MNI_MarsAtlas.nii";

smoothness = 10;
globalTitle = '(A) Locations of PAC memory-related channels';

p_val_thresh = 0.05;

%% load subjects 
CHANNELS_ALL = dataUtils.loadAllChannels(data_path);
corr_pvals = cell2mat(utils.getChannelsValues(CHANNELS_ALL, 'PAC_pval'));
significance = corr_pvals < p_val_thresh;

MNI = utils.getChannelsMNI(CHANNELS_ALL);
MNI_signif = MNI(significance == 1, :);
MNI_nonsignif = MNI(significance == 0, :);

% -- uncomment for showing all channels
% MNI_plot = {MNI_signif, MNI_nonsignif};
% plotColors = {'r', [0.5 0.5 0.5, 0.3]}; % or #D95319 ?
% markerSize = [8, 5];

markerSize = 8;
MNI_plot = {MNI_signif};
plotColors = {'r'};

%% prepare atlas 
% load atlas
[Volume, transform] = localization.atlas.loadAtlasVolume(marsAtlasPath);
% convert to MNI
[MNI_V, labels]= localization.atlas.volume2MNI(Volume, transform);

%% plot data
h = visualization.getFigure(0.45);

h = visualization.MNIplot(h, MNI_V, MNI_plot, plotColors, smoothness, globalTitle, markerSize);
% lgd = visualization.addLegend({'memory-related', 'other'}, plotColors, 8, 0.08);
% lgd.Box = 'on';
h = visualization.formatFigure(h);

%% save
visualization.saveFigure(h, save_path, 'png')
