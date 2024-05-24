function hFig = getFigure(ratio)
%GETFIGURE Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 1
        ratio = 1;
    end
    WIDTH = 26;
    UNITS = "centimeters";
    hFig = figure;
    hFig.Units = UNITS;
    hFig.Position(3) = WIDTH;
    hFig.Position(4) = WIDTH*ratio;
    set(groot,'defaultAxesFontSize',12)
end

