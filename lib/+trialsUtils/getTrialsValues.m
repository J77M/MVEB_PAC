function vals = getTrialsValues(trials, property)
%GETCHANNELSVALUES Summary of this function goes here
%   Detailed explanation goes here
    vals = cell(1, length(trials));
    for ch=1:length(trials)
        vals{ch} = trials(ch).(property);
    end
end

