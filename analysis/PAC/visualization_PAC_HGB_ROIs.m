% average PAC correlation for HGB ROIs
% figure 3.5

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));

%% define paths and parameters
data_path = "/home/jur0/project_iEEG/code/data/analysis/PAC_CHANNELS";
data_path_localization = "/home/jur0/project_iEEG/code/data/analysis/HGB_CHANNELS";

save_path = "/home/jur0/project_iEEG/code/figs/OUT/PAC_ROIs_rho";

marsAtlasPath = "/home/jur0/project_iEEG/code/data/MarsAtlas/colin27_MNI_MarsAtlas.nii";

smoothness1 = 10;
smoothness2 = 50;
globalTitle = 'PAC correlation coefficient for HGB memory-related ROIs';

p_val_thresh = 0.05;

%% load subjects 
CHANNELS_ALL_localization = dataUtils.loadAllChannels(data_path_localization);
significance = cell2mat(utils.getChannelsValues(CHANNELS_ALL_localization, 'significance'));

CHANNELS_ALL = dataUtils.loadAllChannels(data_path);
PAC_MI = cell2mat(utils.getChannelsValues(CHANNELS_ALL, 'PAC').');
subjects = utils.getChannelsValues(CHANNELS_ALL, 'subject');
areas_mars_all = utils.getChannelsValues(CHANNELS_ALL, 'ass_marsLat_name');
areas_yeo7_all = utils.getChannelsValues(CHANNELS_ALL, 'ass_yeo7_name');

areas_mars = areas_mars_all(significance == 1);
areas_yeo7 = areas_yeo7_all(significance == 1);
subjects_sel = subjects(significance == 1);
PAC_MI = PAC_MI(significance == 1, :);


%% prepare data
min_subjects = 3;
[selectivity, labels] = ROI.selectorROI(areas_mars, areas_mars_all, subjects_sel, min_subjects);


%% compute average PAC MI for ROI and correlation

ROI_rho = zeros(1, length(labels));
ROI_pvals = zeros(1, length(labels));
for l=1:length(labels)
    label_indices = find(strcmp(areas_mars, labels{l}));
    ROI_MI = PAC_MI(label_indices, :);
    ROI_MI_average = mean(ROI_MI, 1);

    [rho, p_val] = corr(ROI_MI_average.', [1 2 4 6]', "Type", "Pearson", "Tail","right");
    ROI_rho(l) = rho;
    ROI_pvals(l) = p_val;
end

%% prepare atlas 
% load atlas
[Volume, transform] = localization.atlas.loadAtlasVolume(marsAtlasPath);
% convert to MNI
[MNI_V, labels_V]= localization.atlas.volume2MNI(Volume, transform);

%% get atlas areas (ROIs)
labelsMars = localization.atlas.getMarsAtlasLabels();
atlasLabelsNums = cell2mat(labelsMars(:, 1));
atlasLabelsNames = labelsMars(:, 2);
selectedAtlasROIs = zeros(1, length(ROI_rho));
for l=1:length(ROI_rho)
    idx = find(strcmp(labels{l}, atlasLabelsNames));
    selectedAtlasROIs(l) = atlasLabelsNums(idx);
end

% get colors from colormap
clrMap = turbo(256);
color_values = linspace(-1, 1, length(clrMap));
% get colors for corresponding to selectivity values (ugly I know :()

selected_color_indices = arrayfun(@(x) subsref(find(min(abs(color_values - x)) == abs(color_values - x)), struct('type', '()', 'subs', {{1}})), ROI_rho);


plotColors = clrMap(selected_color_indices, :);
plotColors = num2cell(plotColors, 2);

%% plot data
h = visualization.getFigure(0.45);

h = visualization.ROIplot(h, MNI_V,labels_V, selectedAtlasROIs, plotColors, smoothness1, smoothness2, globalTitle, 0.75);

cbar = colorbar;
colormap(clrMap);
caxis([-1, 1]);
cbar.Layout.Tile = 'east';
cbar.Label.String = 'correlation coefficient';
% cbar.Color = 'w';
cbar.Ticks = -1:0.5:1;
cbar.TickLabels = arrayfun(@(x) sprintf("%.1f", x), cbar.Ticks);

h = visualization.formatFigure(h);


%% save
visualization.saveFigure(h, save_path)

