function [b, a] = getNotchFilters(freq, bandwidth, fs, order, N)
% getNotchFilters: computes coeficients of for Notch IIR butterworth filter 
% and returns transfer function coefficients with size [N,order*2+1]
% "For bandpass and bandstop designs, N represents one-half the filter order." 
% - https://www.mathworks.com/help/signal/ref/butter.html#bucse3u-2
% Filters are computed for harmonic frequencies (N)


    if nargin < 4
        order = 3; % order of butter
    end
    if nargin < 5
        N = 3; % Num of harmonic freqs
    end

    % allocation
    a = zeros(N, order*2+1);
    b = zeros(N, order*2+1);
    for fh=1:N
        f1 = fh*freq - bandwidth/2;
        f2 = fh*freq + bandwidth/2;
        [bfh,afh] = butter(order,[f1, f2]/(fs/2),'stop');
        a(fh, :) = afh;
        b(fh, :) = bfh;
    end

end