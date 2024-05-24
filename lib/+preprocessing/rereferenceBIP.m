function [vAmpData, vChannelsMNI, excludeChannels] = rereferenceBIP(ampData, CHANNELS)
%REREFERENCEBIP creates Bipolar reference (BIP) of data
%   new data from virtual channels are defined as the difference between 
%   signals of contacts located next to each other on electrode shaft. 
%   MNI coordinates of virtual channels are computed as midline between the
%   original contacts. Additionaly an excludeChannels arrray is returned 
%   with the length of virtual channels and values 0, 1 (keep, exclude)
%   excludeChannels is 1 if one of the channels creating virtual channels
%   had at leas one of parameters:
%   SeizureOnset > 1, interictalOften > 1, lesion > 1, BrokenChannel > 1

    % get info if contains broken channel
    brokenCh = 0;
    if isfield(CHANNELS(1), 'brokenCh')
        brokenCh = 1;
    end

    
    [electrodes, shafts_unique] = preprocessing.extractElectrodeShafts(CHANNELS);

    % get MNI coordinates
    MNI_coordinates = cell(1, length(shafts_unique));
    for s=1:length(shafts_unique)
        channels = electrodes{s};
        MNI_x = zeros(1, length(channels));
        MNI_y = zeros(1, length(channels));
        MNI_z = zeros(1, length(channels));
        for ch=1:length(channels)
            MNI_x(ch) = CHANNELS(channels(ch)).MNI_x;
            MNI_y(ch) = CHANNELS(channels(ch)).MNI_y;
            MNI_z(ch) = CHANNELS(channels(ch)).MNI_z;
        end
        MNI_coordinates{s} = [MNI_x.', MNI_y.', MNI_z.'];
    end

    % -- create BIP (bipolar reference)
    % get number of virtual channels
    vChannelsNum = sum(cellfun(@(x) length(x)-1, electrodes));
    % allocate data
    vAmpData = zeros(size(ampData, 1), vChannelsNum);
    vChannelsMNI = zeros(3, vChannelsNum);
    excludeChannels = zeros(1, vChannelsNum);
    
    % iterate over electrodes (compute BIP, new MNI and info if to exclude channels)
    idx = 1;
    for s=1:length(shafts_unique)
        channels = electrodes{s};
        channels_MNI = MNI_coordinates{s};
        for ch = 2:length(channels)
            % get diff between electrodes
            vAmpData(:, idx) = ampData(:, channels(ch-1)) - ampData(:, channels(ch));
            % get new MNI coordinate
            vChannelsMNI(:, idx) = (channels_MNI(ch-1, :) + channels_MNI(ch, :))/2;
            % get av. seizureOnset value of channels
            vSeizureOnset = (CHANNELS(channels(ch-1)).seizureOnset + CHANNELS(channels(ch)).seizureOnset)/2;
            % get av. interictal
            vInterictalOften = (CHANNELS(channels(ch-1)).interictalOften + CHANNELS(channels(ch)).interictalOften)/2;
            % get av. lesion
            vlesion = (CHANNELS(channels(ch-1)).lesion + CHANNELS(channels(ch)).lesion)/2;

            % get av. broken Channel
            vBrokenChannel = 0;
            if brokenCh
                vBrokenChannel = (CHANNELS(channels(ch-1)).brokenCh + CHANNELS(channels(ch)).brokenCh)/2;
            end
            
            % decide if to exclude virtual channel
            if vSeizureOnset > 0 || vInterictalOften > 0 || vlesion > 0 || vBrokenChannel > 0
                excludeChannels(idx) = 1;
            end
            idx = idx +1;
        end
    end
    vChannelsMNI = vChannelsMNI.';
end
