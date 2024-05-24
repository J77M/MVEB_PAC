% creates legend for 3D plot of MarsAtlas

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../../lib'));

%% define paths and parameters
save_path = "/home/jur0/project_iEEG/code/figs/OUT/MarsAtlasLegend";

marsAtlasColormapPath = "/home/jur0/project_iEEG/code/data/MarsAtlas/colorMaps/MarsAtlas-subCortical.ima";
MarsAtlasINF = "/home/jur0/project_iEEG/code/data/MarsAtlas/marsAtlas.csv";

%% prepare atlas 

% load colormap
atlasColors = utils.loadMarsAtlasColorMap(marsAtlasColormapPath);

T = readtable(MarsAtlasINF);
labels_lobe = unique(T.Lobe, 'stable');
lobes = T.Lobe;
markers = {'o', 'square', 'diamond', '^', 'v', '>', '<', 'hexagram'};

%% get atlas areas (ROIs)
labels = localization.atlas.getMarsAtlasLabels();
atlasLabelsNums = cell2mat(labels(:, 1));
% get atlas full names and labels
AtlasFull_names = T.FullName;
AtlasLabels = T.Label;
% get display names and colors
displayNames = cell(1, length(AtlasLabels));
plotColors = cell(1, length(AtlasLabels));
for s=1:length(AtlasLabels)
    if strcmp(lobes{s}, 'Subcortical')
        displayNames{s} = AtlasLabels{s};
    else
        displayNames{s} = sprintf('%s - %s', AtlasLabels{s}, AtlasFull_names{s});
    end
    clrIdx = T.LeftIndex(s);
    plotColors{s} = atlasColors(clrIdx, :)./256;
end

%% map markers
markers_areas = cell(1, length(AtlasLabels));
for s=1:length(AtlasLabels)
    idx = find(contains(labels_lobe, lobes{s}));
    markers_areas{s} = markers{idx};
end

%% plot data
% h = figure('position',[370,340,1000,400], 'Color', 'k');

%%
h = visualization.getFigure(0.65);

tl = tiledlayout(6,1, 'Padding', 'none', 'TileSpacing', 'none'); 
ax1 = nexttile([5 1]);
dummy = zeros(length(AtlasLabels), 1);
for s=1:length(AtlasLabels)
    dummy(s) = plot(nan,nan,'.', 'MarkerFaceColor',plotColors{s}, 'Marker', markers_areas{s}, ... 
        'MarkerSize',20, 'LineWidth', 1.2, 'MarkerEdgeColor', 'k', 'DisplayName', displayNames{s}); 
    hold on;
end
leg = legend(dummy, 'Orientation', 'vertical', 'NumColumns', 2, 'Location', 'north');
title(leg, 'MarsAtlas label')

color = get(h,'Color');
set(gca,'XColor',color,'YColor',color,'TickDir','out')

%%
ax2 = nexttile;
dummy = zeros(length(labels_lobe), 1);
for s=1:length(labels_lobe)
    dummy(s) = plot(nan,nan,'.','Marker', markers{s}, 'MarkerSize',20, 'LineWidth', 1.2, ...
        'MarkerEdgeColor', 'k', 'DisplayName', labels_lobe{s}); 
    hold on;
end
leg = legend(dummy, 'Orientation', 'horizontal', 'Location', 'north', 'NumColumns', 4);
title(leg, 'MarsAtlas region')

color = get(h,'Color');
set(gca,'XColor',color,'YColor',color,'TickDir','out')

%% format
ax1.Box = 'off';
set(ax1, 'XTick', [], 'XTickLabel', []);
set(ax1, 'YTick', [], 'YTickLabel', []);
set(get(ax1, 'XAxis'), 'Visible', 'off');
set(get(ax1, 'YAxis'), 'Visible', 'off');

ax2.Box = 'off';
set(ax2, 'XTick', [], 'XTickLabel', []);
set(ax2, 'YTick', [], 'YTickLabel', []);
set(get(ax2, 'XAxis'), 'Visible', 'off');
set(get(ax2, 'YAxis'), 'Visible', 'off');

title(tl, "(B) Legend")
h = visualization.formatFigure(h);


%% save
% print(h, save_path + ".png",'-dpng','-r300');
visualization.saveFigure(h, save_path,'eps');
