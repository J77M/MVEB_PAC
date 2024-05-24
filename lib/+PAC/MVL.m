function MVL_val = MVL(amp,phase)
%MVL Summary of this function goes here
%   Detailed explanation goes here
    MVL_val = abs(mean(amp.*exp(1i*phase)));
end

