function [electrodes, shafts_unique] = extractElectrodeShafts(CHANNELS)
%EXTRACTELECTRODESHAFTS Summary of this function goes here
%   expects that CHANNELS data were loaded by loadData function (removal of non SEEG channels)
%   electrodes: cell with elements as arrays of channel indices on the same
%   shaft
%   shafts: list of electrode shafts "names" 

    % get naming of electrodes
%     if length(CHANNELS(1).name) <= 2
%         shaftN = 1; % if naming of channels e.g. N1
%     else
%         shaftN = 2; % if naming of channels e.g. As1
%     end
%     % extract electrodes shafts
%     shafts = cell(1, length(CHANNELS));
%     for ch=1:length(CHANNELS)
%         shafts{ch} = CHANNELS(ch).name(1:shaftN);
%     end
%     shafts_unique =unique(shafts, 'stable'); 
    
    % get channels names
    names = utils.getChannelsValues(CHANNELS, 'name');
    % easy solution with regex. from chatgpt to get only letters parts of the names 
    pattern = '^[a-zA-Z]+';
    shafts = cellfun(@(x) regexp(x, pattern, 'match'), names, 'UniformOutput', false);
    shafts = cat(2, shafts{:});
    
    shafts_unique =unique(shafts, 'stable'); 


    % split channels based on electrode shaft 
    electrodes = cell(1, length(shafts_unique));
    for s=1:length(shafts_unique)
        electrodes{s} = find(ismember(shafts, shafts_unique{s}));
    end
end

