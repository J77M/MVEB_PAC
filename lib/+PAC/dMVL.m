function dMVL_val = dMVL(amp,phase)
    %   MVL Summary of this function goes here
    %   Detailed explanation goes here
      z = amp.*exp(1i*phase);
      dMVL_val = 1/sqrt(length(amp)) * (abs(sum(z)))/sqrt(sum(amp.^2)); 
end

