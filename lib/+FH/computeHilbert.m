function [Amp, Phase] = computeHilbert(ampData, filters)
%COMPUTEHILBERT Summary of this function goes here
%   Detailed explanation goes here
    Amp = zeros(length(ampData), size(filters, 1));
    Phase = zeros(length(ampData), size(filters, 1));
    for f=1:size(filters, 1)
        b = squeeze(filters(f, 1, :));
        a = squeeze(filters(f, 2, :));
        x = filtfilt(b, a, ampData);
%         x = zscore(x);
        hx = hilbert(x);
        amp = abs(hx);
        Amp(:, f) = amp;
        phase = angle(hx);
        Phase(:, f) = phase;
    end
end

