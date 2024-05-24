function y = add_noise(x, pink_noise_SNR, white_noise_SNR)
%ADD_NOISE Summary of this function goes here
% base on: https://www.mathworks.com/help/audio/ref/pinknoise.html#d126e14397
    
    N = length(x);
    white_noise_SNR = nan; % uncomment for additionaly adding of white noise (exluded from thesis)
    %% create pink noise (brain activity); white noise (measure)
    pnoise = synthesis.pink_noise(N);

    signalPower = sum(x.^2)/N;
    %% scale pink noise for specified SNR
    pnoisePower = sum(pnoise.^2)/N;
    pscaleFactor = sqrt(signalPower./(pnoisePower *(10^(pink_noise_SNR/10))));

    y = pscaleFactor.*pnoise + x;

    %% scale white noise for specified SNR (uncomment for additional white noise)
%     y_ = pscaleFactor.*pnoise + x;
%     wnoise = randn(1, N);

%     signalPower_ = sum(y_.^2)/N;       
%     wnoisePower = sum(wnoise.^2)/N;
%     wscaleFactor = sqrt(signalPower_./(wnoisePower *(10^(white_noise_SNR/10))));
% 
%     y = wscaleFactor.*wnoise + y_;
end

