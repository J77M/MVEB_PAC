function [CHANNELS,DATA] = loadData(data_path)
%LOADDATA loands data from MVEB task and removes not SEEG channels 
    
    load(data_path);
    % get indices to keep
    keep = zeros(1, length(CHANNELS));
    for ch=1:length(CHANNELS)
        if strcmpi(CHANNELS(ch).signalType, 'SEEG')
            keep(ch) = 1;
        end
    end
    % remove CHANNELS
    CHANNELS = CHANNELS(keep == 1);
    % remove ampData
    ampData = DATA{1}.ampData;
    DATA{1}.ampData = ampData(:, keep == 1);
end

