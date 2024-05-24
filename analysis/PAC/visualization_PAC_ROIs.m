% selectivity of PAC ROIs figure (3.4 E)

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));

%% define paths and parameters
data_path = "/home/jur0/project_iEEG/code/data/analysis/PAC_CHANNELS";

% [subjects, subjects_paths]= dataUtils.get_subjects(data_path);
save_path = "/home/jur0/project_iEEG/code/figs/OUT/PAC_ROIs";

marsAtlasPath = "/home/jur0/project_iEEG/code/data/MarsAtlas/colin27_MNI_MarsAtlas.nii";

smoothness1 = 10;
smoothness2 = 50;
globalTitle = '(E) Selectivity of PAC memory-related ROIs';

p_val_thresh = 0.05;

%% load subjects 
CHANNELS_ALL = dataUtils.loadAllChannels(data_path);
corr_pvals = cell2mat(utils.getChannelsValues(CHANNELS_ALL, 'PAC_pval'));
significance = corr_pvals < p_val_thresh;
subjects = utils.getChannelsValues(CHANNELS_ALL, 'subject');
areas_mars_all = utils.getChannelsValues(CHANNELS_ALL, 'ass_marsLat_name');
areas_yeo7_all = utils.getChannelsValues(CHANNELS_ALL, 'ass_yeo7_name');

areas_mars = areas_mars_all(significance == 1);
areas_yeo7 = areas_yeo7_all(significance == 1);
subjects_sel = subjects(significance == 1);


%% prepare data
min_subjects = 3;
[selectivity, labels] = ROI.selectorROI(areas_mars, areas_mars_all, subjects_sel, min_subjects);



%% prepare atlas 
% load atlas
[Volume, transform] = localization.atlas.loadAtlasVolume(marsAtlasPath);
% convert to MNI
[MNI_V, labels_V]= localization.atlas.volume2MNI(Volume, transform);

%% get atlas areas (ROIs)
labelsMars = localization.atlas.getMarsAtlasLabels();
atlasLabelsNums = cell2mat(labelsMars(:, 1));
atlasLabelsNames = labelsMars(:, 2);
selectedAtlasROIs = zeros(1, length(selectivity));
for l=1:length(selectivity)
    idx = find(strcmp(labels{l}, atlasLabelsNames));
    selectedAtlasROIs(l) = atlasLabelsNums(idx);
end

% get colors from colormap
clrMap = turbo(256);
color_values = linspace(0, 1, length(clrMap));
% get colors for corresponding to selectivity values (ugly I know :()

selected_color_indices = arrayfun(@(x) subsref(find(min(abs(color_values - x)) == abs(color_values - x)), struct('type', '()', 'subs', {{1}})), selectivity);


plotColors = clrMap(selected_color_indices, :);
plotColors = num2cell(plotColors, 2);

%% plot data
h = visualization.getFigure(0.45);

h = visualization.ROIplot(h, MNI_V,labels_V, selectedAtlasROIs, plotColors, smoothness1, smoothness2, globalTitle, 0.75);

cbar = colorbar;
colormap(clrMap);
cbar.Layout.Tile = 'east';
cbar.Label.String = 'selectivity';
% cbar.Color = 'w';
cbar.Ticks = 0:0.2:1;
cbar.TickLabels = arrayfun(@(x) sprintf("%d %%", 100*x), cbar.Ticks);

h = visualization.formatFigure(h);
    

%% save
visualization.saveFigure(h, save_path)

