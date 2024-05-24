function [ampData] = powerLineFilter(ampData, a, b)
% Function powerLineFilter: filters recorded ampData with notch filters
% defined by a,b coeficient : expected size Nx2*order, where N is the
% number of filters (for filtering harmonic frequencies)

    for fh=1:size(a,1)
        ampData = filtfilt(b(fh, :), a(fh, :), ampData);
    end

end