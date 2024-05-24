function [AmpData,CHANNELS, exclude_num] = excludeChannelsByDistance(AmpData, CHANNELS, max_dist)
%EXCLUDECHANNELSBYDISTANCE Summary of this function goes here
%   Detailed explanation goes here

    exclude = zeros(1, length(CHANNELS));
    exclude_labels = {'ass_marsLat_dist', 'ass_yeo7_dist'};
    for ch=1:length(CHANNELS)
        for label=1:length(exclude_labels)
            if CHANNELS(ch).(exclude_labels{label}) >= max_dist
                exclude(ch) = 1;
                continue;
            end
        end
    end
    % Remove from ampData
    AmpData = AmpData(:, exclude == 0);
    CHANNELS = CHANNELS(exclude == 0);

    if nargout > 2
        exclude_num = sum(exclude);
    end
end

