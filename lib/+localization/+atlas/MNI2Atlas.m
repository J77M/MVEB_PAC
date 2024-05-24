function [channelsLabels, channelsApproxDist] = MNI2Atlas(channelsMNI, atlasMNI, atlaslabels, radius_init)
%MNI2MARSATLAS Returns Mars Atlas labels of channels by their MNI coordinates
%   channelsMNI: (Nx3) MNI coordinates of channels
%   atlasMNI: atlas volume converted from volumetric data to MNI coordinates
%       of voxels (function volume2MNI)
%   atlaslabels: label of each voxel represented by MNI coordinates in atlasMNI 
%       (function volume2MNI) 

    if nargin < 4
        radius_init = 6;
    end

    radius_incr = 1; % mm
    MAX_ITERS = 15;
    numChannels = size(channelsMNI, 1);

    % allocate labels for channels
    channelsLabels = zeros(1, numChannels);
    % allocate approx distatnces for channels
    channelsApproxDist = zeros(1, numChannels);

    % find label for each channel
    for ch=1:numChannels
        % iterate over radius 
        localized = false;
        step = 0;
        radius = radius_init;
        while (~localized) && step <= MAX_ITERS
            step = step + 1;
            input_MNI = channelsMNI(ch, :);
    
            % compute distances between inputcoordinate and all volume coordinates 
            distances = sqrt(sum((atlasMNI - input_MNI).^2, 2));
            % find indices of coordinates within the sphere
            indices_within_sphere = distances <= radius;
            
            % get labels of coordinates_in
            labels_in = atlaslabels(indices_within_sphere);

            % check any atlas areas found in 
            if ~isempty(labels_in)
                % find unique labels and counts
                unique_labels = unique(labels_in);
                label_counts = histcounts(labels_in, [unique_labels; max(unique_labels)+1]);
                % find the label that occurred the most times
                [~, max_count_index] = max(label_counts);
                
                % get the most common label
                most_common_label = unique_labels(max_count_index);
                localized = true;
            else
                radius = radius + radius_incr;
            end
        end
        if ~localized
            most_common_label = nan;
            radius = nan;
        end
        
        channelsLabels(ch) = most_common_label;
        channelsApproxDist(ch) = radius;
    end

end

