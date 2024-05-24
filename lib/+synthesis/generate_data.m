clc; clear all;
% TODO check one plot (phase f. was not coupled correctly)

%% define constants
t_stop = 10;
fs = 1000;

lBand = 5;
hBand = 68;
epsilon = 0.1;
phiBand = pi/4;%[pi/2 - epsilon, pi/2 + epsilon];
coupling = 0.1;

SNR_pink_noise = 3; % dB
SNR_white_noise = 20; % dB

bandSize = 2;


%% generate data
    
x = surrogate(fs, t_stop, lBand, hBand, phiBand, coupling);
%     x = ones(1, t_stop*fs);
signal = add_noise(x, SNR_pink_noise, SNR_white_noise);

%% filter hilbert
filters = getFilters(bandSize, fs, [0, fs/2]);
[Power, Phase] = computeHilbert(signal, filters);
Power = Power./max(Power);
% remove beggining and end (hilbert artefacts)
e = 500;
Power = Power(e:end-e, :);
Phase = Phase(e:end-e, :);


%% PAC computation
% abs(mean(amp.*exp(1i*phi)))
Nfreqs = size(Power, 2);
PAC_matrix = zeros(Nfreqs, Nfreqs);
for f1=1:Nfreqs
    for f2 = 1:Nfreqs
        PAC_matrix(f1, f2) = abs(mean(Power(:, f1).*exp(1i*Phase(:, f2))));
    end
end
% remove 0 freq:
PAC_matrix(:, 1) = zeros(Nfreqs, 1);

%% plot

h = figure;
set(h,'position',[500,200,400,400])

af_lim = [56, 120] ./bandSize;
ap_lim = [2, 32./bandSize]; % TODO check if really
nPAC_matrix = PAC_matrix(af_lim(1):af_lim(2), ap_lim(1):ap_lim(2));
% imagesc(nPAC_matrix);
pcolor(nPAC_matrix)
shading interp

axis xy %origin in lower left; otherwise imagesc flips it weird
xticks(1:size(nPAC_matrix, 2))
xticklabels([1:size(nPAC_matrix, 2)].*bandSize)
yticks(1:2:size(nPAC_matrix, 1))
yticklabels([af_lim(1):1:af_lim(2)].*bandSize)
xlabel('phase frequency [Hz]')
ylabel('amplitude frequency [Hz]')

cb = colorbar(); %add colorbar
cb.Label.String = 'PAC value';

%%
gamma = extractFreqBand(Power, 4, [64, 72], fs);
amp = mean(gamma, 2);
theta = extractFreqBand(Phase, 4, [4, 8], fs);
phi = theta(:, 1);

% p_bins = (-pi:0.1:pi);				%Define the phase bins.
p_bins = linspace(-pi, pi, 16);
a_mean = zeros(length(p_bins)-1,1);	%Vector for average amps.
p_mean = zeros(length(p_bins)-1,1);	%Vector for phase bins.
  
for k=1:length(p_bins)-1			%For each phase bin,
    pL = p_bins(k);					%... lower phase limit,
    pR = p_bins(k+1);				%... upper phase limit.
    indices=find(phi>=pL & phi<pR);	%Find phases falling in bin,
    a_mean(k) = mean(amp(indices));	%... compute mean amplitude,
    p_mean(k) = mean([pL, pR]);		%... save center phase.
end


% PAC
