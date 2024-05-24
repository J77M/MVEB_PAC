% creates figure with localized HGB memory-related channels 
% figure 3.2 (A)

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));

%% define paths and parameters
data_path = "/home/jur0/project_iEEG/code/data/analysis/HGB_channels";
[subjects, subjects_paths]= dataUtils.get_subjects(data_path);

save_path = "/home/jur0/project_iEEG/code/figs/OUT/localized_channels";
marsAtlasPath = "/home/jur0/project_iEEG/code/data/MarsAtlas/colin27_MNI_MarsAtlas.nii";

smoothness = 10;
globalTitle = '(A) Locations of HGB memory-related channels';
% markerSize = 6;


%% load subjects 
CHANNELS_ALL = dataUtils.loadAllChannels(data_path);
significance= cell2mat(utils.getChannelsValues(CHANNELS_ALL, 'significance'));

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
% -- uncomment for showing all channels
% lgd = visualization.addLegend({'memory-related', 'other'}, plotColors, 8, 0.08);
% lgd.Box = 'on';

h = visualization.formatFigure(h);

%% save
visualization.saveFigure(h, save_path, 'png')
