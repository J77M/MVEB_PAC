function [selectivity, labels] = selectorROI(selected_areas, all_areas, subjects_selected_areas, min_subjects)
    if nargin < 4
        min_subjects = 3;
    end
    
    [num_sel, num_all, labels] = ROI.getSelectivity(selected_areas, all_areas);
    % num_all = num_all(num_sel > min_channnels);
    % labels = labels(num_sel > min_channnels);
    % num_sel = num_sel(num_sel > min_channnels);
    
    % test - keep only ROIs with channels from at least two participants
    keep = zeros(1, length(labels));
    for l=1:length(labels)
        subjects_ROI = subjects_selected_areas(strcmp(selected_areas, labels{l}));
        if length(unique(subjects_ROI)) >= min_subjects
            keep(l) = 1;
        end
    end
    num_all = num_all(keep == 1);
    labels = labels(keep == 1);
    num_sel = num_sel(keep == 1);
    
    selectivity = num_sel./num_all;

end