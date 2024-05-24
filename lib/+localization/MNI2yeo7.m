function [channelsLabels, channelsApproxDist] = MNI2yeo7(channelsMNI, atlasMNI, atlaslabels, radius)
%MNI2MARSATLAS Returns Mars Atlas labels of channels by their MNI coordinates
%   channelsMNI: (Nx3) MNI coordinates of channels
%   atlasMNI: atlas volume converted from volumetric data to MNI coordinates
%       of voxels (function volume2MNI)
%   atlaslabels: label of each voxel represented by MNI coordinates in atlasMNI 
%       (function volume2MNI) 

    if nargin < 4
        radius = 6; % [mm] initial sphere radius
    end
    
    % define atlas params
    atlasIgnore = 0;
    yeo7_labels = {'Visual', 'Somatomotor', 'Dorsal Attention', 'Ventral Attention', ...
    'Limbic', 'Frontoparietal', 'Default'}; % correspod to label number in Volume

    % REMOVE atlasIgnore voxels (voxels without label)
    atlasMNI = atlasMNI(atlaslabels ~= atlasIgnore, :);
    atlaslabels = atlaslabels(atlaslabels ~= atlasIgnore);

    % RUN MNI 2 ATLAS
    [channelsLabels_, channelsApproxDist] = localization.atlas.MNI2Atlas(channelsMNI, atlasMNI, atlaslabels, radius);

    % convert to mars atlas string labels
    channelsLabels = cell(size(channelsLabels_));
    for ch= 1:length(channelsLabels)
        channelsLabels{ch} = yeo7_labels{channelsLabels_(ch)};
    end

end

