function saveFigure(hFig, save_path, png)
    if nargin < 3
        png = 'png';
    end
    print(hFig, save_path + ".png",'-dpng','-r300');
    [filepath,name,~] = fileparts(save_path);
%     print(hFig, fullfile(filepath, 'eps', name)+ ".eps",'-depsc2', '-r600');
    if strcmp(png, 'pdf')
        print(hFig, fullfile(filepath, 'quality', name)+ ".pdf",'-dpdf', '-r600');
    elseif strcmp(png, 'eps')
        print(hFig, fullfile(filepath, 'quality', name)+ ".eps",'-depsc2', '-r600');
    else
        print(hFig, fullfile(filepath, 'quality', name)+ ".png",'-dpng','-r600');
    end
end