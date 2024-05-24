% creates 3D plot of MarsAtlas regions

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../../lib'));

%% define paths and parameters
save_path = "/home/jur0/project_iEEG/code/figs/OUT/MarsAtlasLobes";

marsAtlasPath = "/home/jur0/project_iEEG/code/data/MarsAtlas/colin27_MNI_MarsAtlas.nii";
marsAtlasColormapPath = "/home/jur0/project_iEEG/code/data/MarsAtlas/colorMaps/MarsAtlas-subCortical.ima";
MarsAtlasINF = "/home/jur0/project_iEEG/code/data/MarsAtlas/marsAtlas.csv";

lobes = {'Cingular', 'Frontal', 'Insula', 'Occipital', 'Orbito-Frontal', 'Parietal', 'Subcortical', 'Temporal'};


smoothness1 = 10;
smoothness2 = 50;
globalTitle = 'MarsAtlas regions';

%% prepare atlas 
% load atlas
[Volume, transform] = localization.atlas.loadAtlasVolume(marsAtlasPath);
% convert to MNI
[MNI_V, labels_V]= localization.atlas.volume2MNI(Volume, transform);
atlasIgnore = 255;
MNI_V = MNI_V(labels_V ~= atlasIgnore, :);
labels_V = labels_V(labels_V ~= atlasIgnore);
% load colormap
atlasColors = utils.loadMarsAtlasColorMap(marsAtlasColormapPath);

%% get atlas areas (ROIs)

T = readtable(MarsAtlasINF);
lobes_V = mars2lobes(labels_V, T, lobes);


plotColors = {'r', 'g', 'b', 'm', '#D95319', 'y', 'c', '#EDB120'};
plotColors = [plotColors, plotColors];

atlasLabelsNums = unique(lobes_V);
%% plot data
h = visualization.getFigure(0.45);

h = visualization.ROIplot(h, MNI_V,lobes_V, atlasLabelsNums, plotColors, smoothness1, smoothness2, globalTitle);
leg = visualization.addLegend(lobes, plotColors);
% title(leg, 'names of MarsAtlas regions')
leg.Box = 'on';

h = visualization.formatFigure(h);

%% save

visualization.saveFigure(h, save_path);

%% function 
function lobes_V = mars2lobes(labels_V, T, lobes)
    lobes_V = zeros(size(labels_V));
    labels_u = unique(labels_V);

    for u=1:length(labels_u)
        idx = find(T.RightIndex == labels_u(u));
        offset = 0;
        if isempty(idx)
            idx = find(T.LeftIndex == labels_u(u));
            offset = length(lobes);
        end
        new_val = find(strcmp(lobes, T.Lobe{idx})) + offset;
        lobes_V(labels_V == labels_u(u)) = new_val;
    end

    
end

