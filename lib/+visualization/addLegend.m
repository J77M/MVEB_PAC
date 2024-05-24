function leg = addLegend(names, colors, Ncols, height)
    if nargin < 3
        Ncols = length(names);
    end
    if nargin < 4
        height = 0.07;
    end
    dummy = zeros(length(names), 1);
    for s=1:length(names)
        dummy(s) = plot(nan,nan,'.', 'Color',colors{s}, 'MarkerSize',20);
    end
%     leg = legend(dummy, names, 'Orientation', 'vertical');
%     leg.Layout.Tile = 'east';
    leg = legend(dummy, names, 'Orientation', 'horizontal', 'NumColumns', Ncols);


    leg.TextColor = 'k'; % Ensure legend text color is white
    leg.Interpreter = 'none';
    leg.EdgeColor = 'k';
%     leg.Color = 'none';
    
    %  adjust the legend position
    pos_leg = get(leg, 'Position');
    pos_leg(1) = (1-pos_leg(3))/2;
    pos_leg(2) = 0.01;  
    pos_leg(4) = height;  
    pos_leg(3) = pos_leg(3) + 0.02; 
    set(leg, 'Position', pos_leg);
    leg.Box = 'off';
end