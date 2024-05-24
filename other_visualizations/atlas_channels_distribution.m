% distribution of channels in atlas areas

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../../lib'));

%% define paths and parameters

data_path = "/home/jur0/project_iEEG/code/data/MVEB_BIP";
[subjects, subjects_paths]= dataUtils.get_subjects(data_path);

save_path = "/home/jur0/project_iEEG/code/figs/OUT/vchannels_distribution";
MarsAtlasINF = "/home/jur0/project_iEEG/code/data/MarsAtlas/marsAtlas.csv";


%% load subjects channels
areas_mars_all = {};
areas_yeo7_all = {};

for s=1:length(subjects)
    subject = subjects{s};
    subject_data_path = subjects_paths{s};
   [CHANNELS, DATA] = preprocessing.loadData(subject_data_path);
   [~, CHANNELS] = preprocessing.excludeSeizureChannels(DATA{1}.ampData, CHANNELS);

    
    % add areas
    mars_areas = utils.getChannelsValues(CHANNELS, 'ass_marsLat_name');
    yeo7_areas = utils.getChannelsValues(CHANNELS, 'ass_yeo7_name');
    areas_mars_all = [areas_mars_all, mars_areas];
    areas_yeo7_all = [areas_yeo7_all, yeo7_areas];


end

%% get yeo7 
[labels_yeo7, ~, idc] = unique(areas_yeo7_all);
[num_sel, num_all, labels] = ROI.getSelectivity(areas_yeo7_all, labels_yeo7);

%% get mars atlas lobes

T = readtable(MarsAtlasINF);
labels_lobe = unique(T.Lobe);

num_lobe = zeros(2,length(labels_lobe));

[labels_mars, ~, idc] = unique(areas_mars_all);
num_mars = accumarray( idc, ones(size(idc)));
for idx=1:length(labels_mars)
    % get laterality
    x = split(labels_mars{idx}, '-');
    lat = x{1}; mars_struct = x{2};
    % get lobe
    table_idx = find(contains(T.Label, mars_struct));
    lobe = T.Lobe{table_idx};%contains
    
    if strcmp(lat, 'R')
        row = 1;
    else
        row = 2;
    end
    
    col = find(strcmp(labels_lobe, lobe));
    %
    num_lobe(row, col) = num_lobe(row, col) + num_mars(idx);
end

%% plot yeo 7

h = visualization.getFigure(0.3);
tl = tiledlayout(1, 2, 'TileSpacing','tight', 'Padding','compact');
nexttile
bar(num_sel)
set(gca,'XtickLabel',labels)
set(gca,'Xtick',1:length(labels))
xlabel("Yeo7 label")
ylabel("number of channels")
title("(A)")


%% plot Mars Lobes
nexttile
bar(num_lobe.')
set(gca,'XtickLabel',labels_lobe)

set(gca,'Xtick',1:length(labels_lobe))
xlabel("MarsAtlas region")
ylabel("number of channels")
lgd = legend({'right', 'left'}, 'Orientation','horizontal', 'Location','north');
title(lgd,'hemisphere')
title("(B)")
h = visualization.formatFigure(h);

%% save
visualization.saveFigure(h, save_path, 'pdf');
