function [selectivity_ROI, labels_ROIS] = getLateralitySelectivity(selectivity_mars, labelsMars)
    parts_mars = split(labelsMars, '-');
    ROI_labels = parts_mars(:, :, 2);
    ROI_laterality = parts_mars(:, :, 1);
    labels_ROIS = unique(ROI_labels, 'stable');
    selectivity_ROI = zeros(length(labels_ROIS), 2);
    for l=1:length(labels_ROIS)
        idx = find(strcmp(ROI_labels, labels_ROIS{l}));
        laterality = ROI_laterality(idx);
        for ll=1:length(laterality)
            if strcmp(laterality{ll}, 'R')
                selectivity_ROI(l, 1) = selectivity_mars(idx(ll));
            else
                selectivity_ROI(l, 2) = selectivity_mars(idx(ll));
            end
    
        end
    end

end