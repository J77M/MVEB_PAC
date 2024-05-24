% Script to additionally convert MNI coordinates of CHANNELS structure
% to atlas labes

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../lib'));

%% define paths
% data for conversion path
data_path = "/home/jur0/project_iEEG/code/data/MVEB_BIP";
output_path = "/home/jur0/project_iEEG/code/data/MVEB_BIP";

% localization parameter
radius = 6; % [mm] for sphere about electrode center

% atlas path
marsAtlasPath = "/home/jur0/project_iEEG/code/data/MarsAtlas/colin27_MNI_MarsAtlas.nii";
yeo7AtlasPath = "/home/jur0/project_iEEG/code/data/yeo7Atlas-MNI152/Yeo2011_7Networks_MNI152_FreeSurferConformed1mm.nii.gz";


data_path_search = data_path + "/*.mat";

%% load atlas data
[Volume, transform] = localization.atlas.loadAtlasVolume(marsAtlasPath);
% convert to MNI
[atlasMNI_mars, atlaslabels_mars]= localization.atlas.volume2MNI(Volume, transform);

[Volume, transform] = localization.atlas.loadAtlasVolume(yeo7AtlasPath);
% convert to MNI
[atlasMNI_yeo7, atlaslabels_yeo7]= localization.atlas.volume2MNI(Volume, transform);

%% load data
files = dir(data_path_search);
for f=1:length(files)
    % load file
    file = files(f);
    load_path = fullfile(data_path, file.name);
    save_path = fullfile(output_path, file.name);
    
    load(load_path)
%     CHANNELS = newCHANNELS;

    % get MNI coordinates and original atlas labels
    MNI = utils.getChannelsMNI(CHANNELS);
    prev_labels_mars = utils.getChannelsValues(CHANNELS, 'ass_marsLat_name');
    prev_labels_yeo7 = utils.getChannelsValues(CHANNELS, 'ass_yeo7_name');
    
    % new atlas based localization of electrodes
    [labels_mars, ApproxDist_mars] =  ... 
        localization.MNI2MarsAtlas(MNI, atlasMNI_mars, atlaslabels_mars, radius);

    [labels_yeo7, ApproxDist_yeo7] =  ... 
        localization.MNI2yeo7(MNI, atlasMNI_yeo7, atlaslabels_yeo7, radius);

    % report how values changed
    same_mars = cellfun(@(x,y) strcmp(x,y), labels_mars, prev_labels_mars);
    same_yeo7 = cellfun(@(x,y) strcmp(x,y), labels_yeo7, prev_labels_yeo7);

    fprintf("%s | mars: %d values changed, %.1f %% values same\n", file.name, ... 
         sum(same_mars == 0),100*sum(same_mars)/length(same_mars));
    fprintf("%s | yeo7: %d values changed, %.1f %% values same\n", file.name, ... 
        sum(same_yeo7== 0), 100*sum(same_yeo7)/length(same_yeo7));
    
    % convert 
    for ch=1:length(CHANNELS)
        CHANNELS(ch).ass_marsLat_name = labels_mars{ch};
        CHANNELS(ch).ass_yeo7_name = labels_yeo7{ch};

        CHANNELS(ch).ass_marsLat_dist = ApproxDist_mars(ch);
        CHANNELS(ch).ass_yeo7_dist = ApproxDist_yeo7(ch);
    end
    
    % save
    if exist("DATA", 'var')
        save(save_path, "CHANNELS", "DATA");
    else
        save(save_path, "CHANNELS");
    end
    fprintf("%s saved\n--------\n", file.name);

end

