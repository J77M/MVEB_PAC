% 3D locations of bipolar channels

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));

%% define paths and parameters
data_path = "/home/jur0/project_iEEG/code/data/MVEB_BIP";
[subjects, subjects_paths]= dataUtils.get_subjects(data_path);
save_path = "/home/jur0/project_iEEG/code/figs/OUT/subjects_vchannels";

marsAtlasPath = "/home/jur0/project_iEEG/code/data/MarsAtlas/colin27_MNI_MarsAtlas.nii";

globalTitle = 'Locations of channels';
smoothness = 10;

%% load subjects channels MNI coordinates

subjects_MNI = cell(1);
for s=1:length(subjects)
    subject = subjects{s};
    subject_data_path = subjects_paths{s};
    [CHANNELS, DATA] = preprocessing.loadData(subject_data_path);
%     [~, CHANNELS] = preprocessing.excludeSeizureChannels(DATA{1}.ampData, CHANNELS);
    subjects_MNI{s} = utils.getChannelsMNI(CHANNELS);
end

%% prepare atlas 
% load atlas
[Volume, transform] = localization.atlas.loadAtlasVolume(marsAtlasPath);
% convert to MNI
[MNI_V, labels]= localization.atlas.volume2MNI(Volume, transform);

%% plot data
% h = figure('position',[370,340,1000,420], 'Color', 'k');
h = visualization.getFigure(0.45);

plotColors = hsv(length(subjects));
plotColors = num2cell(plotColors, 2);

h = visualization.MNIplot(h, MNI_V, subjects_MNI, plotColors, smoothness, globalTitle);
lgd = visualization.addLegend(subjects, plotColors, 8, 0.08);
% title(lgd, 'subjects')
lgd.Box = 'on';

h = visualization.formatFigure(h);


%% save
visualization.saveFigure(h, save_path);