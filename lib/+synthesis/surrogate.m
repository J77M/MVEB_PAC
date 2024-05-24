function x = surrogate(fs, t_stop, Lband, Hband, phiBand, coupling)
%SURROGATE Summary of this function goes here
    
    if length(Lband) == 1
        fp = Lband;
    else
        fp = round(Lband(1) + (Lband(2)-Lband(1))*rand(1)); % phase frequency
    end

    if length(Hband) == 1
        fa = Hband;
    else
        fa = round(Hband(1) + (Hband(2)-Hband(1))*rand(1)); % amplitude frequency
    end

    if length(phiBand) == 1
        phi_c = phiBand;
    else
        phi_c = phiBand(1) + (phiBand(2)-phiBand(1))*rand(1);
    end

    if length(coupling) == 1 % high: ch = 0.2; low = 0.8
        ch = coupling;
    else
        ch = coupling(1) + (coupling(2)-coupling(1))*rand(1);
    end

    t = 0:1/fs:t_stop;
    
    ch = ch*ones(1, length(t));
    
    % phase signal
    K_fp = 1;
    % amplitude signal
    K_fa = 0.5;    

    [x_fp, x_fa] = synthesis.surrogate_components(fp, fa, phi_c, t, ch);
    
    x = K_fa * x_fa + K_fp * x_fp;

end

