function [channelsLabels, channelsApproxDist] = MNI2MarsAtlas(channelsMNI, atlasMNI, atlaslabels, radius)
%MNI2MARSATLAS Returns Mars Atlas labels of channels by their MNI coordinates
%   channelsMNI: (Nx3) MNI coordinates of channels
%   atlasMNI: atlas volume converted from volumetric data to MNI coordinates
%       of voxels (function volume2MNI)
%   atlaslabels: label of each voxel represented by MNI coordinates in atlasMNI 
%       (function volume2MNI) 
    
    if nargin < 4
        radius = 6; % [mm] initial sphere radius
    end

    atlasIgnore = 255;

    % get Mars Atlas labels
    MarsLabels = localization.atlas.getMarsAtlasLabels();
    MarsAreasNumbers = cell2mat(MarsLabels(:, 1));
    MarsAreasLabels = MarsLabels(:, 2);

    % REMOVE atlasIgnore voxels (voxels without label)
    atlasMNI = atlasMNI(atlaslabels ~= atlasIgnore, :);
    atlaslabels = atlaslabels(atlaslabels ~= atlasIgnore);

    % RUN MNI 2 ATLAS
    [channelsLabels_, channelsApproxDist] = localization.atlas.MNI2Atlas(channelsMNI, atlasMNI, atlaslabels, radius);

    % convert to mars atlas string labels
    channelsLabels = cell(size(channelsLabels_));
    for ch= 1:length(channelsLabels)
        area_label = MarsAreasLabels{MarsAreasNumbers == channelsLabels_(ch)};
        channelsLabels{ch} = area_label;
    end

end

