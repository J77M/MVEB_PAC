% PLV between HGB-memory related channels
% figure 3.9

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));

%% DEFINE VALUES and load data
data_path = "/home/jur0/project_iEEG/code/data/analysis/HGB_CHANNELS";
% [subjects, subjects_paths]= dataUtils.get_subjects(data_path);
save_path = "/home/jur0/project_iEEG/code/figs/OUT/PLV_ROI_HGB";


PLV_data_path = "/home/jur0/project_iEEG/code/data/analysis/PLV_conditions";

distance_filter = 10;

marsAtlasPath = "/home/jur0/project_iEEG/code/data/MarsAtlas/colin27_MNI_MarsAtlas.nii";

p_val_thresh = 0.05;
smoothness1 = 10;
smoothness2 = 50;
globalTitle = 'PLV-memory load correlation coefficient between HGB memory-related ROIs';

labelsMars = localization.atlas.getMarsAtlasLabels();
atlasLabelsMars = labelsMars(:, 2);
atlasLabelsYeo7 = localization.atlas.getYeo7Labels();

atlas_colors_yeo7 = [120 18 134; 70 130 180; 0 118 14; 196 58 250; 220 248 164; ...
        230 148 34; 205 62 78];

%% load data
[CHANNELS_ALL, subjects]= dataUtils.loadAllChannels(data_path);

MNI = utils.getChannelsMNI(CHANNELS_ALL);
channels_mars = utils.getChannelsValues(CHANNELS_ALL, 'ass_marsLat_name');
channels_subjects = utils.getChannelsValues(CHANNELS_ALL, 'subject');
% channels_yeo7 = utils.getChannelsValues(CHANNELS_ALL, 'ass_marsLat_name');
channels_significant = cell2mat(utils.getChannelsValues(CHANNELS_ALL, 'significance'));
significant_indices = find(channels_significant == 1);
channels_mars = channels_mars(significant_indices);
channels_subjects = channels_subjects(significant_indices);

%% load PLV matrices and average for MarsAtlas
PLV_matrices_ALL = PLV.loadPLVmatrices(PLV_data_path, subjects, MNI);
PLV_matrices_ALL = PLV_matrices_ALL(:, significant_indices, significant_indices);

PLV_matrix_mars = nan(4, length(atlasLabelsMars), length(atlasLabelsMars));
for c=1:4
    PLV_matrix_mars(c, :, :) = PLV.average4atlas(squeeze(PLV_matrices_ALL(c, :, :)), channels_mars, atlasLabelsMars);
end


%% compute correlation between PLV in MarsAtlas labels
[rho_values_mars, p_values_mars] = PLV.computeCorrelationPLV(PLV_matrix_mars);

% remove diagonal - self correlation in area
p_values_mars(eye(size(p_values_mars))==1) = nan;
rho_values_mars(eye(size(rho_values_mars))==1) = nan;


%% extract "ROI" (keep only areas where the connection was for more than > 2 subjects)
min_subjects = 3;

[rho_values_mars, labels] = ROI.selectorROI_PLV(channels_mars, atlasLabelsMars, channels_subjects, rho_values_mars, min_subjects);

%% 
h = visualization.getFigure(0.3);
tiledlayout(1,1, 'TileSpacing','tight', 'Padding','compact')
ax = nexttile;
cmap = turbo(256);
visualization.schemaball.schemaball2(ax, rho_values_mars, labels, cmap, [-1,1])

cb = colorbar(ax);
colormap(cmap);
cb.Layout.Tile = 'east';
cb.Label.String = 'Correlation coefficient';
caxis([-1,1])
title(globalTitle)
h = visualization.formatFigure(h);
ax.Box = 'on';
ax.Box = 'off';
set(ax, 'XTick', [], 'XTickLabel', []);
set(ax, 'YTick', [], 'YTickLabel', []);
set(get(ax, 'XAxis'), 'Visible', 'off');
set(get(ax, 'YAxis'), 'Visible', 'off');
%% save
visualization.saveFigure(h, save_path, 'png')

