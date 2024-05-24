function MI_val = MI(amp,phase, Nbins)
    %   MVL Summary of this function goes here
    %   Detailed explanation goes here
    amp_mean = PAC.average_amp4phase(amp, phase, Nbins);
    % normalize to probability
    prob_amp_mean = amp_mean ./ sum(amp_mean);

    MI_val=(log(Nbins)-(-sum((prob_amp_mean).*log((prob_amp_mean)))))/log(Nbins);
end

