function [rereferenced_ampData] = rereferenceCAR(ampData)
%rereferenceCAR implementation of CAR (Common Average Reference) method 
%   mean of signal for all electrodes is computed and then subtracted from
%   each electrode
    common_average = mean(ampData, 2);
    common_average = repmat(common_average, 1, size(ampData, 2));
    rereferenced_ampData = ampData - common_average;
end

