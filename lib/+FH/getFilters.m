function filters = getFilters(freqs,sample_freq,bandSize)
%GETFILTERS Summary of this function goes here
%   Detailed explanation goes here
startFreq = 0.1;
stopFreq = sample_freq/2 - 0.1;

fsize = length(freqs) - 1;
% if (freqLim(2)-freqLim(1))/4 ~= fsize
%     warning("filter design: exact freqLim not possible, instead: [%d, %d] Hz", freqLim(1), freqLim(1) + bandSize*fsize)
% end

% compute filters
filters = zeros(fsize, 2, 7); % [b,a] -> first col: b; second col: a
for f=1:fsize
    fc = [freqs(f), freqs(f) + bandSize];
    if fc(1)== 0
        fc(1) = startFreq;
    elseif fc(end) == sample_freq/2
        fc(end) = stopFreq;
    elseif fc(end) > sample_freq/2
        break;
    end
    [b,a] = butter(3,fc/(sample_freq/2));
    filters(f, 1, :) = b;
    filters(f, 2, :) = a;
end
end
