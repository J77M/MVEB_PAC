function hfig= ROIplot(hfig, MNIatlasVolume, atlasLabels, ROIsNumbers, colors, smoothness1, smoothness2, globalTitle, alpha)
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
    if nargin < 6
      smoothness1 = 10; % set default smoothness of alpha shape
    end
    if nargin < 7
      smoothness2 = 20; % set default smoothness of alpha shape    
    end
    if nargin < 8
      globalTitle = nan;
    end
    if nargin < 9
        alpha = 0.75;
    end
    
    alpha_template = 0.04;
    smoothness1 = smoothness1/100;
    smoothness2 = smoothness2/100;

    
    % define views and params
    azimuth = [90, 180, 0]; % right, front and top view
    elevation = [0, 0, 90]; % right, front and top view

    titles = {'right', 'front', 'top'}; 

    offset_text = 20;
    % colors
    backgroundClr = 'w';
    objectsClr = 'k';

    % get labels not in ROI
%     template_indices = [];
%     all_labels = unique(atlasLabels);
%     for v=1:length(all_labels)
%         if ~ismember(all_labels(v), ROIsNumbers)
%             template_indices = [template_indices, find(atlasLabels == all_labels(v)).'];
%         end
%     end
% 
%     %randomy select indices 
% %     template_indices_rand = randperm(numel(template_indices), round(numel(template_indices)*smoothness1));
%     template_indices_rand = 1:round(1/smoothness1):length(template_indices);
%     template_indices = template_indices(template_indices_rand);
% 
% 
%     % create volume envelope
% %     shp_all = alphaShape(MNIatlasVolume(1:smoothness1:end, :));
%     shp_all = alphaShape(MNIatlasVolume(template_indices, :));

    % create volume envelope
    rand_indices = 1:round(1/smoothness1):length(MNIatlasVolume);
    shp_all = alphaShape(MNIatlasVolume(rand_indices, :));


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
            MNI_ROI = MNIatlasVolume(atlasLabels == ROIsNumbers(roi), :);
            % select random indices (smoothness)
%             rand_indices = randperm(length(MNI_ROI), round(length(MNI_ROI)*smoothness2));
            rand_indices = 1:round(1/smoothness2):length(MNI_ROI);
            shp = alphaShape(MNI_ROI(rand_indices, :));
%             shp = alphaShape(MNI_label(1:smoothness2:end, :));
    
            plot(shp, 'FaceColor', colors{roi}, 'FaceAlpha', alpha, 'EdgeColor','none')
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

        % set light ?
%          l = light('Position',[0 0 100],'Style','infinite');
%          lighting gouraud;
%           l = light('Position',[0 80 0],'Style','infinite');
%          lighting gouraud;
%           l = light('Position',[80 0 0],'Style','infinite');
%          lighting gouraud;

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