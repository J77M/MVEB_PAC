% ---- citation ----
% H. Zhivomirov. A Method for Colored Noise Generation. Romanian Journal of Acoustics and Vibration,
% ISSN: 1584-7284, Vol. XV, No. 1, pp. 14-19, 2018. (http://rjav.sra.ro/index.php/rjav/article/view/40/29)

% Hristo Zhivomirov (2024). Pink, Red, Blue and Violet Noise Generation with Matlab 
% (https://www.mathworks.com/matlabcentral/fileexchange/42919-pink-red-blue-and-violet-noise-generation-with-matlab), 
% MATLAB Central File Exchange. Retrieved May 14, 2024.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Pink Noise Generation with MATLAB Implementation   %
%                                                      %
% Author: M.Sc. Eng. Hristo Zhivomirov       07/30/13  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = pink_noise(N)

% function: y = pinknoise(N) 
% N - number of samples to be returned in row vector
% y - row vector of pink (flicker) noise samples

% The function generates a sequence of pink (flicker) noise samples. 
% Pink noise has equal energy in all octaves (or similar log bundles) of frequency.
% In terms of power at a constant bandwidth, pink noise falls off at 3 dB per octave. 

% define the length of the vector
% ensure that the M is even
if rem(N,2)
    M = N+1;
else
    M = N;
end

% generate white noise
x = randn(1, M);

% FFT
X = fft(x);

% prepare a vector for 1/f multiplication
NumUniquePts = M/2 + 1;
n = 1:NumUniquePts;
n = sqrt(n);

% multiply the left half of the spectrum so the power spectral density
% is proportional to the frequency by factor 1/f, i.e. the
% amplitudes are proportional to 1/sqrt(f)
X(1:NumUniquePts) = X(1:NumUniquePts)./n;

% prepare a right half of the spectrum - a copy of the left one,
% except the DC component and Nyquist frequency - they are unique
X(NumUniquePts+1:M) = real(X(M/2:-1:2)) -1i*imag(X(M/2:-1:2));

% IFFT
y = ifft(X);

% prepare output vector y
y = real(y(1, 1:N));

% ensure unity standard deviation and zero mean value
y = y - mean(y);
yrms = sqrt(mean(y.^2));
y = y/yrms;

end