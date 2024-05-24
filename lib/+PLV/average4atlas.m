function PLV_atlas= averagePLV4atlas(PLV_matrix, channels_atlas, atlas_labels)
    channels_indices = cellfun(@(x) find(strcmp(atlas_labels, x)), channels_atlas, 'UniformOutput', false);
    channels_indices_all = cell2mat(channels_indices);
    % exclude mars areas with only one electrode
%     atlas_counts = arrayfun(@(x)length(find(strcmp(channels_atlas, x))), unique(channels_atlas), 'Uniform', false);
%     atlas_counts = cell2mat(atlas_counts);
%     keep = find(atlas_counts > 1);
%     PLV_matrix = PLV_matrix(keep, keep);
%     channels_indices_all = channels_indices_all(keep);
    
    sz = length(atlas_labels);
    atlas_labels_num = 1:length(atlas_labels);
    PLV_atlas = nan(sz, sz);
    for v1=1:sz
        indices1 = find(channels_indices_all == atlas_labels_num(v1));
        if isempty(indices1)
            continue
        end

        for v2=1:sz
            indices2 = find(channels_indices_all == atlas_labels_num(v2));
            if isempty(indices2)
                continue;
            end
                PLV_atlas(v1, v2) = mean(PLV_matrix(indices1, indices2), 'all', "omitnan");
%                 PLV_atlas(v1, v2) = max(PLV_matrix(indices1, indices2),[], 'all');

        end
    end
    
end