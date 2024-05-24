function filters = getFiltersFreq(freqs,bandSize)
%GETFILTERS Summary of this function goes here
%   Detailed explanation goes here

fsize = length(freqs) - 1;
% if (freqLim(2)-freqLim(1))/4 ~= fsize
%     warning("filter design: exact freqLim not possible, instead: [%d, %d] Hz", freqLim(1), freqLim(1) + bandSize*fsize)
% end

% compute filters
filters = zeros(fsize, 2); % [b,a] -> first col: b; second col: a
for f=1:fsize
    fc = [freqs(f), freqs(f) + bandSize];
    filters(f, :) = fc;
end
end
