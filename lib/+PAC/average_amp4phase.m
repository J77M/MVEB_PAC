function amp_mean = average_amp4phase(amp,phase, Nbins)
    %   MVL Summary of this function goes here
    %   Detailed explanation goes here
    
    p_bins = linspace(-pi, pi, Nbins+1);
    amp_mean = zeros(length(p_bins)-1,1);	
     
    % for each phase bin
    for k=1:length(p_bins)-1
        % set phase limits
        pL = p_bins(k);					
        pR = p_bins(k+1);				
        % compute mean amplitude for amplitude in phase bin
        amp_mean(k) = mean(amp(phase>=pL & phase<pR));
    end
end

