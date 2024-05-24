function [pval, PAC_norm]= surrogate_test(Amp, Phase, PAC_fcn, raw_PAC, srate)
%SURROGATE_TEST Summary of this function goes here
%   surrogate testing based on Canolty

numpoints=length(Amp);
 % number of sample points in raw signal
numsurrogate=200;
 % number of surrogate values to compare to actual value
minskip=srate;
 % time lag must be at least this big
maxskip=numpoints-srate;
 % time lag must be smaller than this
skip=ceil(numpoints.*rand(numsurrogate*2,1));
skip(find(skip>maxskip))=[];
skip(find(skip<minskip))=[];
skip=skip(1:numsurrogate,1);
surrogate_m=zeros(numsurrogate,1);

% compute surrogate values
for s=1:numsurrogate
    surrogate_amplitude=[Amp(skip(s):end); Amp(1:skip(s)-1)];

    surrogate_m(s)=PAC_fcn(surrogate_amplitude, Phase);
end
[surrogate_mean,surrogate_std]=normfit(surrogate_m);
PAC_norm =(abs(raw_PAC)-surrogate_mean)/surrogate_std;
pval = 1 - normcdf(abs(raw_PAC), surrogate_mean, surrogate_std); % from Ozkurt
end

