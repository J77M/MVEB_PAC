function hfig = MNIplot(hfig, MNIatlasVolume, MNIchannelsCell, colors, smoothness, globalTitle, markerSize)
% MNIplot:  plots Colin27 MNI Volume with 3 views: right, front, top
%           together with MNI coordinates of channels (or ROIs)
%   MNIchannelsCell is expected to be a cell with MNI coordinates (Nx3),
%   each cell will be displayed with Marker of color corresponding to cell
%   index in cell colors
% plot layout based on https://ieeexplore.ieee.org/document/8616016
% MNI coordinates:
%   https://www.fieldtriptoolbox.org/faq/coordsys/
%   https://mne.tools/0.22/overview/implementation.html
% views of right, front, top:
%   http://www.ece.northwestern.edu/local-apps/matlabhelp/techdoc/ref/view.html
    
    % test if correct input
    assert(length(MNIchannelsCell) == length(colors), "number of colors must be the same as number of cells in MNIchannelsCell")
    if nargin < 5
        smoothness = 10; % set default smoothness of alpha shape
    end
    if nargin < 6
        globalTitle = nan;
    end
    if nargin < 7
        markerSize = 5.7;
    end

    if length(markerSize) == 1
        markerSizes = markerSize*ones(1, length(colors));
    else
        markerSizes = markerSize;
    end

    alpha_template = 0.04;
    smoothness = smoothness / 100; % convert from % to 0-1;
    
    % define views and params
    azimuth = [90, 180, 0]; % right, front and top view
    elevation = [0, 0, 90]; % right, front and top view

    titles = {'right', 'front', 'top'}; 

    offset_text = 20;
    % colors
    backgroundClr = 'w';
    objectsClr = 'k';
    
    % create volume envelope (smoothed)
%     rand_indices = randperm(length(MNIatlasVolume), round(length(MNIatlasVolume)*smoothness));
    rand_indices = 1:round(1/smoothness):length(MNIatlasVolume);
    shp = alphaShape(MNIatlasVolume(rand_indices, :));


    % prepare figure
    hfig.Color = backgroundClr;
    t= tiledlayout(1,3, 'Padding', 'compact', 'TileSpacing', 'compact');
 

    % iterate over views
    for v=1:length(azimuth)
        nexttile
        
        plot(shp, 'FaceColor', objectsClr, 'FaceAlpha', alpha_template, 'EdgeColor','none')
        hold on;
        % iterate over sets of MNI channels
        for s=1:length(MNIchannelsCell)
            channels_MNI = MNIchannelsCell{s};
            plot3(channels_MNI(:, 1), channels_MNI(:, 2), channels_MNI(:, 3), ... 
                "Marker", '.', 'MarkerSize',markerSizes(s), "LineStyle", "none", "Color", colors{s}); % prev 7
        end
        
        view(azimuth(v), elevation(v))
    %     camlight;
        
        title(titles{v}, "Color",objectsClr);
        pbaspect([1,1,1])
        xlim([-89, 90])
        ylim([-108, 73])
        zlim([-74.5, 104.5])
        
        xlabel("MNI x [mm]")
        ylabel("MNI y [mm]")
        zlabel("MNI z [mm]")
        grid off;
    
        % set color
        ax = gca;
        set(ax, 'Color', backgroundClr, 'XColor', objectsClr, 'YColor', objectsClr, 'ZColor', objectsClr);
        set(ax, 'TickDir', 'out', 'TickLength', [0.02, 0.02]);
        % disable things 
        disableDefaultInteractivity(ax);
        ax.Toolbar.Visible = 'off';
        
        % get text labels with coordinates
        minX = ax.XLim(1) + offset_text; maxX = ax.XLim(2) - offset_text;
        minY = ax.YLim(1) + offset_text; maxY = ax.YLim(2) - offset_text;
        minZ = ax.ZLim(1) + offset_text; maxZ = ax.ZLim(2) - offset_text;

        switch v
            case 1
                text1 = 'back'; text2 = 'front';
                minX = 5; maxX = 5;
                maxZ = minZ;
            case 2
                text1 = 'left'; text2 = 'right';
                minY = 5; maxY = 5;
                maxZ = minZ;
            case 3
                text1 = 'left'; text2 = 'right';
                minZ = 5; maxZ = 5;
                maxY = minY;
        end
        % add text labels
        text(minX, minY, minZ, text1, "Color",objectsClr)
        text(maxX, maxY, maxZ, text2, "Color",objectsClr)
    end    

    % set title
    if ~isnan(globalTitle)
        % some wierd activity of matlab :( workaround) 
        anot = annotation('textbox',[0.5 0.85 0.1 0.1],'String',globalTitle, 'FitBoxToText','on', 'EdgeColor','none');
        anot.Color = objectsClr;
        anot.FontName = t.Title.FontName;
        anot.FontSize = t.Title.FontSize;
        anot.UserData = 'CustomTitle';
        pause(0.5)
        newPos = [anot.Position(1) - anot.Position(3)/2 anot.Position(2:end)];
        % real annotation
        set(anot, 'Position', newPos);
        pause(0.5)
    end

end