function heigh_ratio_val = height_ratio(amp,phase, Nbins)
    %   MVL Summary of this function goes here
    %   Detailed explanation goes here
    amp_mean = PAC.average_amp4phase(amp, phase, Nbins);
    % normalize to probability ?
%     prob_amp_mean = amp_mean./ sum(amp_mean);
    prob_amp_mean = amp_mean;
    % get max and min
    h_max = max(prob_amp_mean);
    h_min = min(prob_amp_mean);

    heigh_ratio_val = (h_max -h_min)/h_max;
end

