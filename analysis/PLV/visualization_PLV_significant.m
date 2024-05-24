% visualizations of significant mars connections
% figure 3.8

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));

%% DEFINE VALUES and load data
data_path = "/home/jur0/project_iEEG/code/data/MVEB_BIP";
% [subjects, subjects_paths]= dataUtils.get_subjects(data_path);
save_path = "/home/jur0/project_iEEG/code/figs/OUT/PLV_correlation_significant";


PLV_data_path = "/home/jur0/project_iEEG/code/data/analysis/PLV_conditions";

distance_filter = 10;

marsAtlasPath = "/home/jur0/project_iEEG/code/data/MarsAtlas/colin27_MNI_MarsAtlas.nii";

p_val_thresh = 0.05;
smoothness1 = 10;
smoothness2 = 50;
globalTitle = '(C) Significant PLV-memory load correlations';

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


%% load PLV matrices and average for MarsAtlas
PLV_matrices_ALL = PLV.loadPLVmatrices(PLV_data_path, subjects, MNI);

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

[p_values, labels] = ROI.selectorROI_PLV(channels_mars, atlasLabelsMars, channels_subjects, p_values_mars, min_subjects);


%% find significant correlation
[rIdx, cIdx] = find(p_values < p_val_thresh);
selected_labels_pairs1 = labels(rIdx);
selected_labels_pairs2 = labels(cIdx);
selected_labels = unique([selected_labels_pairs1, selected_labels_pairs2]);
PLV_matrix = zeros(length(selected_labels));
for idx1=1:length(selected_labels)
    idx1_p = find(strcmp(selected_labels{idx1}, labels));
    for idx2=1:length(selected_labels)
        idx2_p = find(strcmp(selected_labels{idx2}, labels));
        if p_values(idx1_p, idx2_p) < p_val_thresh
            PLV_matrix(idx1, idx2) = 1;
        end
    end
end


%% get atlas areas (ROIs)
labelsMars = localization.atlas.getMarsAtlasLabels();
atlasLabelsNums = cell2mat(labelsMars(:, 1));
atlasLabelsNames = labelsMars(:, 2);
selectedAtlasROIs = zeros(length(selected_labels), 1);

for l=1:length(selected_labels)
    idx1 = find(strcmp(selected_labels{l}, atlasLabelsNames));
    selectedAtlasROIs(l) = atlasLabelsNums(idx1);
end


%% set colors of ROIS
colors = visualization.distinguishable_colors(length(selectedAtlasROIs));
plotColors = num2cell(colors, 2);
plotColors = repmat({'#D95319'}, 1, length(selectedAtlasROIs));

%% prepare atlas 
% load atlas
[Volume, transform] = localization.atlas.loadAtlasVolume(marsAtlasPath);
% convert to MNI
[MNI_V, labels_V]= localization.atlas.volume2MNI(Volume, transform);

%%
h = visualization.getFigure(0.45);

h = visualization.ROIplotPLV(h, MNI_V,labels_V, selectedAtlasROIs, PLV_matrix, ... 
    plotColors, smoothness1, globalTitle, 0.75);

h = visualization.formatFigure(h);

%% save
visualization.saveFigure(h, save_path, 'png')





%% plot schemaball of significant channels

h = visualization.getFigure(0.5);
tl = tiledlayout(1,2, 'TileSpacing','tight', 'Padding','compact');

%% plot PLV correlation mars all
[rho_values, labels_rho] = ROI.selectorROI_PLV(channels_mars, atlasLabelsMars, channels_subjects, rho_values_mars, min_subjects);
ax = nexttile;
marsRegions_selected = localization.marsLabels2Regions(labels_rho);

[marsRegions_selected, I] = sort(marsRegions_selected);
labels_rho = labels_rho(I);
rho_values = rho_values(I, I);

marsRegions_all = unique(marsRegions_selected);
colors = visualization.distinguishable_colors(length(marsRegions_all));
colors = num2cell(colors, 2);

plot_colors = zeros(length(marsRegions_selected), 3);
for ii=1:length(marsRegions_selected)
    idx = find(strcmp(marsRegions_all, marsRegions_selected{ii}));
    plot_colors(ii, :) = colors{idx};
end



% rho_values(rho_values < 0) = 0;
% visualization.schemaball.schemaball3(ax, rho_values, labels_rho, marsRegions_selected, colors);
cmap = turbo(256);
visualization.schemaball.schemaball2(ax, rho_values, labels_rho, cmap, [-1, 1], plot_colors, 1);

% add colormap
cb = colorbar(ax);
colormap(cmap);
% cb.Layout.Tile = 'west';
cb.Location = 'eastoutside';
cb.Label.String = 'Correlation coefficient';
caxis([-1,1])

title("(A) PLV-memory load correlation coefficient")

ax.Box = 'off';
set(ax, 'XTick', [], 'XTickLabel', []);
set(ax, 'YTick', [], 'YTickLabel', []);
set(get(ax, 'XAxis'), 'Visible', 'off');
set(get(ax, 'YAxis'), 'Visible', 'off');
%% significant connections

marsRegions_selected = localization.marsLabels2Regions(selected_labels);

[marsRegions_selected, I] = sort(marsRegions_selected);
marsLabels_selected = selected_labels(I);
PLV_matrix_ = PLV_matrix(I, I); 

marsRegions = unique(marsRegions_selected);
plot_colors = cell(length(marsRegions));
for ii=1:length(marsRegions)
    idx = find(strcmp(marsRegions_all, marsRegions{ii}));
    plot_colors{ii} = colors{idx};
end



ax = nexttile;
visualization.schemaball.schemaball3(ax, PLV_matrix_, marsLabels_selected, marsRegions_selected, plot_colors);

% add legend 
tmp_plot = zeros(length(marsRegions_all), 1);
for ii=1:length(marsRegions_all)
    hold on;
    p = plot(nan, nan, 'LineWidth',2, 'Color', colors{ii});
    tmp_plot(ii) = p;
end
lgd = legend(tmp_plot, marsRegions_all{:}, 'Orientation', 'horizontal', 'NumColumns', 6);
lgd.Layout.Tile = 'south';
title(lgd, 'MarsAtlas region')
title("(B) Significant PLV-memory load correlations")

h = visualization.formatFigure(h);
ax.Box = 'off';
set(ax, 'XTick', [], 'XTickLabel', []);
set(ax, 'YTick', [], 'YTickLabel', []);
set(get(ax, 'XAxis'), 'Visible', 'off');
set(get(ax, 'YAxis'), 'Visible', 'off');
%% save
visualization.saveFigure(h, save_path + '_schemaball', 'png')

