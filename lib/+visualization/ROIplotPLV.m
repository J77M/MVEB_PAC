function hfig= ROIplotPLV(hfig, MNIatlasVolume, atlasLabels, ROIsNumbers, PLV_matrix ,colors, ...
     smoothness1, globalTitle, alpha)
% ROIplot:  plots Colin27 MNI Volume with 3 views: right, front, top
%           With different colors for different Mars Atlas Labels
%   ROIsNumbers is expected to be a an array with selected atlas labels numbers (Nx1),
%   each ROI will be displayed with color corresponding to its index in cell colors
%   ROIsNumbers are defined by function localization/atlas/getMarsAtlasLabels
% plot layout based on https://ieeexplore.ieee.org/document/8616016
% MNI coordinates:
%   https://www.fieldtriptoolbox.org/faq/coordsys/
%   https://mne.tools/0.22/overview/implementation.html
% views of right, front, top:
%   http://www.ece.northwestern.edu/local-apps/matlabhelp/techdoc/ref/view.html
    
    % test if correct input
    assert(length(ROIsNumbers) == length(colors), "number of colors must be the same as number of cells in MNIchannelsCell")
    if nargin < 7
      smoothness1 = 10; % set default smoothness of alpha shape
    end

    if nargin < 8
      globalTitle = nan;
    end
    if nargin < 9
        alpha = 0.5;
    end

    alpha_template = 0.04;
    smoothness1 = smoothness1/100;

    
    % define views and params
    azimuth = [90, 180, 0]; % right, front and top view
    elevation = [0, 0, 90]; % right, front and top view

    titles = {'right', 'front', 'top'}; 
    % colors
    backgroundClr = 'w';
    objectsClr = 'k';

    offset_text = 20;
    R = 3; % mm ; radius of ROI centers spheres


    % create volume envelope
    rand_indices = 1:round(1/smoothness1):length(MNIatlasVolume);
    shp_all = alphaShape(MNIatlasVolume(rand_indices, :));

    % get ROIs (mars areas) centers
    centers = zeros(length(ROIsNumbers), 3);
    for roi=1:length(ROIsNumbers)
        MNI_ROI = MNIatlasVolume(atlasLabels == ROIsNumbers(roi), :);
        centers(roi, :) = mean(MNI_ROI, 1);
    end

    % prepare figure
    hfig.Color = backgroundClr;
    t= tiledlayout(1,3, 'Padding', 'compact', 'TileSpacing', 'compact');
    
    % iterate over views
    for v=1:length(azimuth)
        nexttile
        
        plot(shp_all, 'FaceColor', objectsClr, 'FaceAlpha', alpha_template, 'EdgeColor','none')
        hold on;
        % iterate over sets of MNI channels
        for roi=1:length(ROIsNumbers)
%             MNI_ROI = MNIatlasVolume(atlasLabels == ROIsNumbers(roi), :);
            % plot spheres at ROI centers
            [X,Y,Z] = sphere(20);
            X = X*R + centers(roi, 1);
            Y = Y*R + centers(roi, 2);
            Z = Z*R + centers(roi, 3);
            surf(X,Y,Z,'FaceColor',colors{roi}, 'EdgeColor','none', 'FaceAlpha', alpha);

        end

        % plot connections
        combinations = PLV.generateCombinations(1:length(ROIsNumbers));
        for c=1:length(combinations)
            idx1 = combinations(c,1);
            idx2 = combinations(c,2);
            if idx1 == idx2 || isnan(PLV_matrix(idx1, idx2)) || PLV_matrix(idx1, idx2) == 0
                continue
            end
                plot3(centers([idx1, idx2], 1), centers([idx1, idx2], 2), centers([idx1, idx2], 3),...
                    'Color', '#0072BD', 'LineWidth', 2.5, 'Marker', 'none');

                
            % workaround plot3 and line 
%             [X,Y,Z] = visualization.cylinder2P(1, 6, 3, centers(idx1, :), centers(idx2, :));
%             surf(X,Y,Z,'FaceColor',squeeze(colors_Connections(idx1, idx2, 1:3)), ... 
%                 'EdgeColor','none', 'FaceAlpha', squeeze(colors_Connections(idx1, idx2, 4)));
                    
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