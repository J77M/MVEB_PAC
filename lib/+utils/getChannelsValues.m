function vals = getChannelsValues(CHANNELS, property)
%GETCHANNELSVALUES Summary of this function goes here
%   Detailed explanation goes here
    vals = cell(1, length(CHANNELS));
    for ch=1:length(CHANNELS)
        vals{ch} = CHANNELS(ch).(property);
    end
end

