function channelsLabels = getChannelsMarsLabels(CHANNELS)
%GETCHANNELSMARSLABELS returns mars atlas labels of channels as cell array
    
    channelsNum = length(CHANNELS);
    channelsLabels = cell(1, channelsNum);
    for ch=1:channelsNum
        label = CHANNELS(ch).ass_marsLat_name;
        channelsLabels{ch} = label;
    end
end

