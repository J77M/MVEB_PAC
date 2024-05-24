% Preprocessing of data with Bipolar reference (BIP).
% computes new data with BIP for all subjects. The new referenced "virtual 
% channels" are then localized in Mars Atlas and atlas labels are assigned. 
% for MarsAtlas and yeo7. Additionaly virtual channels are excluded if one
% of the original channels located in epileptic seizure onset zone or ictal.
% Notch filter is applied to filter 50 Hz noise from power line and their
% harmonic frequencies 50, 100, 150 Hz.
% Signal is filtered with high pass filter with cutoff 0.1 Hz


clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../lib'));
 

%% define paths, params and load data
data_path = "/home/jur0/project_iEEG/code/data/MVEB";
save_data_path = "/home/jur0/project_iEEG/code/data/MVEB_BIP/%s.mat";

[subjects, subjects_paths]= dataUtils.get_subjects(data_path);

marsAtlasPath = "/home/jur0/project_iEEG/code/data/MarsAtlas/colin27_MNI_MarsAtlas.nii";
yeo7AtlasPath = "/home/jur0/project_iEEG/code/data/yeo7Atlas-MNI152/Yeo2011_7Networks_MNI152_FreeSurferConformed1mm.nii.gz";

% define atlas labeling parameters
MarsFilterDist = 10; % mm ; exlude channels with distance > 10 mm from analysis
radius = 6; % mm ; initial radius for localization

%% define params for filtering
HP_cutoff = 0.1; % [Hz]  cutoff for high pass filter
ORD_HP = 3; % order of HP filter
F0_notch = 50; % [Hz] frequency for notch filter
N_notch = 3; % number of harmonic freqs. for notch filter. Will be filtered for 50 Hz, 100 Hz, 150 Hz
BW_notch = 1; % [Hz] bandwidth for notch filter
ORD_notch = 3; % order of notch filter. in reality, the filter will be 6-th order (docs for butter)

%% prepare atlas 
% load atlas
[Volume, transform] = localization.atlas.loadAtlasVolume(marsAtlasPath);
% convert to MNI
[atlasMNI, atlaslabels]= localization.atlas.volume2MNI(Volume, transform);

[Volume, transform] = localization.atlas.loadAtlasVolume(yeo7AtlasPath);
% convert to MNI
[atlasMNI2, atlaslabels2]= localization.atlas.volume2MNI(Volume, transform);


%% BIP for all subjects
for s=1:length(subjects)
    fprintf('----- preprocessing BIP started for subject %s -----\n', subjects{s});

    % paths
    subject_path = subjects_paths{s};
    subject_save_path = sprintf(save_data_path, subjects{s});
    % load SEEG data
    [CHANNELS, DATAraw] = preprocessing.loadData(subject_path);
    numChannels = length(CHANNELS);    
    % ---- Bipolar reference 
    % iterate over sessions
    DATA = {};
    session_idx = 1;
    for ses=1:length(DATAraw)
        % skip if numeric task
        MVEB_type = DATAraw{ses}.trials(1).stim_type{2};
        if ~isnan(str2double(MVEB_type))
            continue
        end
        
        % copy values to new structure
        ampData = DATAraw{ses}.ampData;
        fs = DATAraw{ses}.srate;
        DATA{session_idx}.srate = fs;
        DATA{session_idx}.timeAxis = DATAraw{ses}.timeAxis;
        DATA{session_idx}.trials = DATAraw{ses}.trials;
        DATA{session_idx}.gameType = DATAraw{ses}.gameType;
        DATA{session_idx}.units = DATAraw{ses}.units;


        % BIP reference (unfortunatelly the I didn't think about possibility 
        % of multiple sessions, therefore it is not effective aproach: TODO: separate function for CHANNELS and data)
        [vAmpData, vChannelsMNI, vExcludeChannels] =  preprocessing.rereferenceBIP(ampData, CHANNELS);
        
        % save referened data
        DATA{session_idx}.ampData = vAmpData;
        session_idx = session_idx + 1;
    end

    % ---- process channels (atlas Labeling)
  
    % get Mars Atlas label of virtual channels
    [vChannelsLabels, vChannelsApproxDist] = localization.MNI2MarsAtlas(vChannelsMNI, atlasMNI, atlaslabels, radius);
    % get yeo7 atlas labels
    [vChannelsLabels2, vChannelsApproxDist2] = localization.MNI2yeo7(vChannelsMNI, atlasMNI2, atlaslabels2, radius);
        
    % create new CHANNELS structucture
    vCHANNELS_indices = 1:length(vChannelsLabels);
    names = arrayfun(@num2str, vCHANNELS_indices, 'UniformOutput', 0);
    
    vCHANNELS = struct('name', names, 'numberOnAmplifier', num2cell(vCHANNELS_indices), ...
        'signalType', 'SEEG', 'MNI_x', num2cell(vChannelsMNI(:, 1).'), ...
        'MNI_y', num2cell(vChannelsMNI(:, 2).'), 'MNI_z', num2cell(vChannelsMNI(:, 3).'), ... 
        'ass_marsLat_name', vChannelsLabels, 'ass_marsLat_dist', num2cell(vChannelsApproxDist), ...
        'ass_yeo7_name', vChannelsLabels2, 'ass_yeo7_dist', num2cell(vChannelsApproxDist), ...
        'exclude', num2cell(vExcludeChannels));

    % ---- process ampData (exclude channels, high pass, low pass filter)
    vCHANNELS_glob = vCHANNELS;
    for ses=1:length(DATA)
        vCHANNELS = vCHANNELS_glob;
        vAmpData = DATA{ses}.ampData;

        % exclude Interictal Often and Seizure Onset channels
        [vAmpData,vCHANNELS, exculded_epi] = preprocessing.excludeSeizureChannels(vAmpData, vCHANNELS);
        
        % exclude channels with distance to atlas label >= 10 mm (white matter electrodes)
        [vAmpData, vCHANNELS, exculded_atlas] = localization.excludeChannelsByDistance(vAmpData, vCHANNELS, MarsFilterDist);
        
        % High Pass filter cutoff 0.1 Hz
        [bh, ah] = butter(ORD_HP,HP_cutoff/(fs/2),'high');
        vAmpData = filtfilt(bh, ah, vAmpData);

        % Notch filter 50 Hz
        [bn, an] = preprocessing.getNotchFilters(F0_notch, BW_notch, fs, ORD_notch, N_notch);
        vAmpData = preprocessing.powerLineFilter(vAmpData, an, bn);
        
        DATA{ses}.ampData = vAmpData;
    end

    fprintf("exluded: epi and bad channels %d | white matter %d\n", exculded_epi, exculded_atlas);

    % save to .mat
    CHANNELS = vCHANNELS;
    save(subject_save_path, "CHANNELS", "DATA")
    fprintf('virtual channels: %d | all contacts: %d \n', length(vCHANNELS), numChannels);
end
