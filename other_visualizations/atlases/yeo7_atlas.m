% creates 3D plot of yeo7 atlas

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../../lib'));

%% define paths and parameters
yeo7AtlasPath = "/home/jur0/project_iEEG/code/data/yeo7Atlas-MNI152/Yeo2011_7Networks_MNI152_FreeSurferConformed1mm.nii.gz";
save_path = "/home/jur0/project_iEEG/code/figs/OUT/Yeo7";


atlas_colors = [120 18 134; 70 130 180; 0 118 14; 196 58 250; 220 248 164; ...
        230 148 34; 205 62 78];
atlas_labels = {'Visual', 'Somatomotor', 'Dorsal Attention', 'Ventral Attention', ...
        'Limbic', 'Frontoparietal', 'Default'};

smoothness1 = 10;
smoothness2 = 50;
globalTitle = 'Yeo7 labels';

%% prepare atlas 
% load atlas
[Volume, transform] = localization.atlas.loadAtlasVolume(yeo7AtlasPath);
% convert to MNI
[MNI_V, labels_V]= localization.atlas.volume2MNI(Volume, transform);
%% get atlas areas (ROIs)

% get colors from colormap
plotColors = num2cell(atlas_colors./255, 2);

atlasLabelsNums = [1,2,3,4,5,6,7];


%% plot data
h = visualization.getFigure(0.45);

h = visualization.ROIplot(h, MNI_V,labels_V, atlasLabelsNums, plotColors, smoothness1, smoothness2, globalTitle);
leg = visualization.addLegend(atlas_labels, plotColors);
% title(leg, 'Yeo7 labels names')
leg.Box = 'on';
h = visualization.formatFigure(h);

%% save
visualization.saveFigure(h, save_path);

