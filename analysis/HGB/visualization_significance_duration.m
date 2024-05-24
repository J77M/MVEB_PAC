% NOT PART OF THE THESIS

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));

%% define paths and parameters
data_path = "/home/jur0/project_iEEG/code/data/analysis/localization_time";

% [subjects, subjects_paths]= dataUtils.get_subjects(data_path);
save_path = "/home/jur0/project_iEEG/code/figs/OUT/localizations_ROI2";

marsAtlasPath = "/home/jur0/project_iEEG/code/data/MarsAtlas/colin27_MNI_MarsAtlas.nii";

smoothness1 = 10;
smoothness2 = 50;
globalTitle = 'Average duration of significance';


%% load subjects 
CHANNELS_ALL = dataUtils.loadAllChannels(data_path);
subject_significance = cell2mat(utils.getChannelsValues(CHANNELS_ALL, 'significance'));
subjects = utils.getChannelsValues(CHANNELS_ALL, 'subject');
areas_mars_all = utils.getChannelsValues(CHANNELS_ALL, 'ass_marsLat_name');
pvals = cell2mat(utils.getChannelsValues(CHANNELS_ALL, 'p_val'));

areas_mars = areas_mars_all(subject_significance == 1);
subjects_sel = subjects(subject_significance == 1);
pvals2 = pvals(:, subject_significance == 1);

%% option 1 average significance duration for areas where at least 50 ms < 0.01 p val
% min_subjects = 3;
% [selectivity, labels] = ROI.selectorROI(areas_mars, areas_mars_all, subjects_sel, min_subjects);
% 
% 
% [~, sum_segments, segments_indices] = utils.get_max_segments(pvals, 0.05);
% 
% selectivity = zeros(size(selectivity));
% for l=1:length(labels)
%     indices = find(strcmp(areas_mars_all, labels{l}));
%     selectivity(l) = mean(sum_segments(indices));
% end
% 
% selectivity = selectivity./max(selectivity);

%% option 2 average significance duration for all areas (subjects > 2)
min_subjects = 3;
[selectivity, labels] = ROI.selectorROI(areas_mars_all, areas_mars_all, subjects, min_subjects);


[~, sum_segments, segments_indices] = utils.get_max_segments(pvals, 0.05);

selectivity = zeros(size(selectivity));
for l=1:length(labels)
    indices = find(strcmp(areas_mars_all, labels{l}));
    selectivity(l) = mean(sum_segments(indices));
end

% selectivity = selectivity./max(selectivity);
labels = labels(selectivity > 50); % filter out where average < 50 ms
selectivity = selectivity(selectivity > 50);

durations = selectivity;
% selectivity = selectivity./max(selectivity);
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
load("data/sky.mat");
clrMap = sky;
clrMap = turbo(256);
% clrMap = hot(256);
% clrMap = clrMap(256:-1:1, :);
color_values = linspace(0, 1, length(clrMap));
% get colors for corresponding to selectivity values (ugly I know :()

selected_color_indices = arrayfun(@(x) subsref(find(min(abs(color_values - x)) == abs(color_values - x)), struct('type', '()', 'subs', {{1}})), selectivity);


plotColors = clrMap(selected_color_indices, :);
plotColors = num2cell(plotColors, 2);

%% plot data
h = visualization.getFigure(0.45);

h = visualization.ROIplot(h, MNI_V,labels_V, selectedAtlasROIs, plotColors, smoothness1, smoothness2, globalTitle, 1);

cbar = colorbar;
colormap(clrMap);
cbar.Layout.Tile = 'east';
cbar.Label.String = 'duration [ms]';
% cbar.Color = 'w';
cbar.Ticks = 0:0.1:1;
cbar.TickLabels = arrayfun(@(x) sprintf("%d", x), round(1000*linspace(min(durations), max(durations), 11)./512));

h = visualization.formatFigure(h);


%% save
% visualization.saveFigure(h, save_path, 'png')

