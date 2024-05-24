% selectivity figures
% figure 3.2 (B)-(D)

clear all; clc;
% add path to libraryq
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));

%% define paths and parameters
data_path = "/home/jur0/project_iEEG/code/data/analysis/HGB_channels";
save_path = "/home/jur0/project_iEEG/code/figs/OUT/localization_selectivity";

marsAtlasPath = "/home/jur0/project_iEEG/code/data/MarsAtlas/colin27_MNI_MarsAtlas.nii";
MarsAtlasINF = "/home/jur0/project_iEEG/code/data/MarsAtlas/marsAtlas.csv";
marsTable = readtable(MarsAtlasINF);

%% load subjects and find significant channels
CHANNELS_ALL = dataUtils.loadAllChannels(data_path);
subject_significance = cell2mat(utils.getChannelsValues(CHANNELS_ALL, 'significance'));
subjects = utils.getChannelsValues(CHANNELS_ALL, 'subject');
areas_mars_all = utils.getChannelsValues(CHANNELS_ALL, 'ass_marsLat_name');
areas_yeo7_all = utils.getChannelsValues(CHANNELS_ALL, 'ass_yeo7_name');

areas_mars = areas_mars_all(subject_significance == 1);
areas_yeo7 = areas_yeo7_all(subject_significance == 1);
subjects_sel = subjects(subject_significance == 1);


%% get yeo7 selectivity
[num_sel, num_all, labelsYeo7] = ROI.getSelectivity(areas_yeo7, areas_yeo7_all);
selectivity_yeo7 = 100*num_sel./num_all;

%% get mars atlas selectivity
[num_sel_mars, num_all_mars, labelsMars_] = ROI.getSelectivity(areas_mars, areas_mars_all);

min_subjects = 3;
[selectivity_mars, labelsMars] = ROI.selectorROI(areas_mars, areas_mars_all, subjects_sel, min_subjects);
selectivity_mars = 100*selectivity_mars;
% laterality for bar plot
[selectivity_ROIs, labels_ROIs] = ROI.getLateralitySelectivity(selectivity_mars, labelsMars);

%%  get lobes selectivity
[selectivity_lobe, labels_lobe] = ROI.getMarsRegionSelectivity(marsTable, areas_mars, areas_mars_all);

%% plot yeo7 and mars regions

h = visualization.getFigure(0.45);
t = tiledlayout(2, 2, "TileSpacing","compact", 'Padding','compact');

nexttile;
bar(selectivity_yeo7, 'FaceColor', '#7E2F8E')
set(gca,'XtickLabel',labelsYeo7)
set(gca,'Xtick',1:length(labelsYeo7))
yticks(0:20:40)
title("(B) Selectivity of Yeo7 labels")
ylabel('selectivity [%]')
xlabel('Yeo7 label')
ylim([0, 40])



nexttile;
bar(selectivity_lobe.')
set(gca,'XtickLabel',labels_lobe)
set(gca,'Xtick',1:length(labels_lobe))
yticks(0:20:40)
title("(C) Selectivity of MarsAtlas regions")
ylabel('selectivity [%]')
xlabel('MarsAtlas region')

ylim([0, 40])


nexttile([1 2]);
bar(selectivity_ROIs)
set(gca,'XtickLabel',labels_ROIs)
set(gca,'Xtick',1:length(labels_ROIs))
yticks(0:20:60)
title("(D) Selectivity of HGB memory-related ROIs")
ylabel('selectivity [%]')
xlabel('MarsAtlas label')
ylim([0, 60])

% add legend
lgd = legend({'right', 'left'}, 'Orientation', 'vertical', 'Location','northeastoutside');
title(lgd, 'hemisphere')
lgd.Layout.Tile = 'east';

h = visualization.formatFigure(h);

%% save 
visualization.saveFigure(h, save_path, 'png')
