function [AmpData,CHANNELS, exclude_num] = excludeSeizureChannels(AmpData,CHANNELS)
%EXCLUDE Summary of this function goes here
%   Detailed explanation goes here
    
    % localize channels located in epileptic seizure onset zone
    exclude = zeros(1, length(CHANNELS));
    exclude_labels = {'seizureOnset', 'interictalOften', 'brokenCh', 'exclude'};
    for ch=1:length(CHANNELS)
        for label=1:length(exclude_labels)
            if isfield(CHANNELS(ch), exclude_labels{label})
                if CHANNELS(ch).(exclude_labels{label}) > 0
                    exclude(ch) = 1;
                    continue;
                end
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

