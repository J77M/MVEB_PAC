function [x_fp,x_fa] = surrogate_components(fp,fa, phi_c, t, ch)
%SURROGATE_COMPONENTS Summary of this function goes here
%   Detailed explanation goes here
    % phase signal
    K_fp = 1;
    x_fp = K_fp * sin(2*pi*fp*t);
    
    % amplitude signal
    K_fa = 1;    
    A_fa = K_fa*((1-ch).*sin(2*pi*fp*t - phi_c) + ch.*ones(1, length(t)) +ones(1, length(t)))./2;
%     A_fa = K_fa*((1-ch).*sin(2*pi*fp*t - phi_c) + ch.*ones(1, length(t)) +ones(1, length(t)))./2;

    x_fa = A_fa.*sin(2*pi*fa*t);
end


