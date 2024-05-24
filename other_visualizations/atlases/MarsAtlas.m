% creates 3D plot of MarsAtlas

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../../lib'));

%% define paths and parameters
save_path = "/home/jur0/project_iEEG/code/figs/OUT/MarsAtlas";

marsAtlasPath = "/home/jur0/project_iEEG/code/data/MarsAtlas/colin27_MNI_MarsAtlas.nii";
marsAtlasColormapPath = "/home/jur0/project_iEEG/code/data/MarsAtlas/colorMaps/MarsAtlas-subCortical.ima";

smoothness1 = 10;
smoothness2 = 50;
globalTitle = '(A) MarsAtlas labels';

%% prepare atlas 
% load atlas
[Volume, transform] = localization.atlas.loadAtlasVolume(marsAtlasPath);
% convert to MNI
[MNI_V, labels_V]= localization.atlas.volume2MNI(Volume, transform);
% load colormap
atlasColors = utils.loadMarsAtlasColorMap(marsAtlasColormapPath);

%% get atlas areas (ROIs)
labels = localization.atlas.getMarsAtlasLabels();
atlasLabelsNums = cell2mat(labels(:, 1));
% get colors from colormap
plotColors = atlasColors(atlasLabelsNums, :) ./255;
plotColors = num2cell(plotColors, 2);


%% plot data
h = visualization.getFigure(0.45);

h = visualization.ROIplot(h, MNI_V,labels_V, atlasLabelsNums, plotColors, smoothness1, smoothness2, globalTitle);
h = visualization.formatFigure(h);

%% save
visualization.saveFigure(h, save_path);