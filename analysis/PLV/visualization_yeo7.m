% PLV correlation for yeo7
% figure3.7

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));

%% DEFINE VALUES and load data
data_path = "/home/jur0/project_iEEG/code/data/MVEB_BIP";

save_path = "/home/jur0/project_iEEG/code/figs/OUT/PLV_rho_yeo7";

PLV_data_path = "/home/jur0/project_iEEG/code/data/analysis/PLV_conditions";

distance_filter = 10;

labelsMars = localization.atlas.getMarsAtlasLabels();
atlasLabelsMars = labelsMars(:, 2);
atlasLabelsYeo7 = localization.atlas.getYeo7Labels();

atlas_colors_yeo7 = [120 18 134; 70 130 180; 0 118 14; 196 58 250; 220 248 164; ...
        230 148 34; 205 62 78];

%%
[CHANNELS_ALL, subjects]= dataUtils.loadAllChannels(data_path);

MNI = utils.getChannelsMNI(CHANNELS_ALL);
%%
% areas_mars_all = utils.getChannelsValues(CHANNELS_ALL, 'ass_marsLat_name');
channels_yeo7 = utils.getChannelsValues(CHANNELS_ALL, 'ass_yeo7_name');

PLV_matrices_ALL = PLV.loadPLVmatrices(PLV_data_path, subjects, MNI);

PLV_matrix_yeo7 = nan(4, length(atlasLabelsYeo7), length(atlasLabelsYeo7));
for c=1:4
    PLV_matrix_yeo7(c, :, :) = PLV.average4atlas(squeeze(PLV_matrices_ALL(c, :, :)), channels_yeo7, atlasLabelsYeo7);
end

%% correlation yeo7

[rho_values_yeo7, p_values_yeo7] = PLV.computeCorrelationPLV(PLV_matrix_yeo7);


%% schemaball yeo7
h = visualization.getFigure(0.45);
tl = tiledlayout(1,2, 'TileSpacing','compact', 'Padding','compact');
cmap = turbo(256);

nexttile
hmap = heatmap(atlasLabelsYeo7, atlasLabelsYeo7, round(rho_values_yeo7, 2));
hmap.ColorbarVisible = 'off';
hmap.NodeChildren(3).YDir='normal';  
colormap(cmap);
caxis([-1,1])
title("(A)")


ax = nexttile;
labels_indices = [7 6 1 2 3 4 5];
visualization.schemaball.schemaball2(ax, rho_values_yeo7(labels_indices, labels_indices), atlasLabelsYeo7(labels_indices), cmap, [-1,1])

cb = colorbar(ax);
colormap(cmap);
cb.Layout.Tile = 'east';
cb.Label.String = 'Correlation coefficient';
caxis([-1,1])
title("(B)")

% title(globalTitle)
ax.Box = 'off';
set(ax, 'XTick', [], 'XTickLabel', []);
set(ax, 'YTick', [], 'YTickLabel', []);
set(get(ax, 'XAxis'), 'Visible', 'off');
set(get(ax, 'YAxis'), 'Visible', 'off');

title(tl, "PLV - memory load correlation for Yeo7")

h = visualization.formatFigure(h);

%% 
visualization.saveFigure(h, save_path, 'png')

