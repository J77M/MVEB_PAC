function [selectivity_lobe, labels_lobe] = getMarsRegionSelectivity(marsTable, areas_mars, areas_mars_all)

    labels_lobe = unique(marsTable.Lobe);
    
    num_lobe = zeros(2,length(labels_lobe));
    
    [labels_mars, ~, idc] = unique(areas_mars_all);
    num_mars = accumarray( idc, ones(size(idc)));
    for idx=1:length(labels_mars)
        % get laterality
        x = split(labels_mars{idx}, '-');
        lat = x{1}; mars_struct = x{2};
        % get lobe
        table_idx = find(contains(marsTable.Label, mars_struct));
        lobe = marsTable.Lobe{table_idx};%contains
        
        if strcmp(lat, 'R')
            row = 1;
        else
            row = 2;
        end
        
        col = find(strcmp(labels_lobe, lobe));
        %
        num_lobe(row, col) = num_lobe(row, col) + num_mars(idx);
    end
    
    num_lobe_all = num_lobe;
    
    num_lobe = zeros(2,length(labels_lobe));
    [labels_mars, ~, idc] = unique(areas_mars);
    num_mars = accumarray( idc, ones(size(idc)));
    for idx=1:length(labels_mars)
        % get laterality
        x = split(labels_mars{idx}, '-');
        lat = x{1}; mars_struct = x{2};
        % get lobe
        table_idx = find(contains(marsTable.Label, mars_struct));
        lobe = marsTable.Lobe{table_idx};%contains
        
        if strcmp(lat, 'R')
            row = 1;
        else
            row = 2;
        end
        
        col = find(strcmp(labels_lobe, lobe));
        %
        num_lobe(row, col) = num_lobe(row, col) + num_mars(idx);
    end
    
    selectivity_lobe = 100*num_lobe./num_lobe_all;


end