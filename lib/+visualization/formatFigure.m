function hFig = formatFigure(hFig, box)
    if nargin < 2
        box = 'off';
    end
    FontSize = 12;
    TitleFontSize = 13;
    MainTitleFontSize = 14;
    
    % set all fonts to one size
    set(findall(hFig,'-property','FontSize', '-not', 'UserData', 'ignore'), 'FontSize',FontSize) % adjust fontsize to your document
%     set(findall(hFig,'-property','Interpreter'), 'Interpreter', 'latex') all to latex ?
    % set titles font sizes
    titles = findall(hFig,'-property','Title', '-not', 'Type', 'heatmap');
    otherTitle = findall(hFig, 'UserData', 'CustomTitle');
    for idx=1:length(titles)
        if strcmp(titles(idx).Type, 'tiledlayout')
            titles(idx).Title.FontSize = MainTitleFontSize;
        else
            titles(idx).Title.FontSize = TitleFontSize;
        end
        titles(idx).Title.FontWeight = 'bold';
    end
    if ~isempty(otherTitle)
        otherTitle.FontSize = MainTitleFontSize;
        otherTitle.FontWeight = 'bold';

    end
    % set interpreter
%     set(findall(hFig,'-property','Interpreter'),'Interpreter','latex') 
%     set(findall(hFig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
    
    % set boxes
    set(findall(hFig,'-property','Box', '-not', 'Type', 'Legend'), 'Box', box)

    % update latex font sizes
    latex_str = findall(hFig,'-property','FontSize', 'Interpreter', 'latex');
    latex_font = sprintf("\\fontsize{%d}{0}\\selectfont ", FontSize);
    for idx=1:length(latex_str)
        latex_str(idx).String = latex_font + latex_str(idx).String;
    end
    % for loop add to text \fontsize{12}{0} 
    
    % set position
    pos = get(hFig,'Position');
    set(hFig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])

    

end