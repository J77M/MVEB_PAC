function [newPLV_matrix, labels] = selectorROI_PLV(channels_labels, all_labels, channels_subjects, PLV_matrix, min_subjects)
    if nargin < 5
        min_subjects = 3;
    end
    
    labels = unique(all_labels);
    subjects = unique(channels_subjects);
    N = length(labels);
    number_of_connections  = zeros(N); % count total number of connections between areas
    subjects_matrix = zeros(N); % count number of subjects for which there is connection between areas
    for s=1:length(subjects)
        subject_channels_labels = channels_labels(strcmp(channels_subjects, subjects{s}));
        for idx1=1:N
            for idx2=1:N
                count1 = length(find(strcmp(subject_channels_labels, labels{idx1})));
                count2 = length(find(strcmp(subject_channels_labels, labels{idx2})));
                
                number_of_connections(idx1, idx2) = number_of_connections(idx1, idx2) + count1*count2;
                if count1*count2 > 0
                    subjects_matrix(idx1, idx2) = subjects_matrix(idx1, idx2) + 1;
                end
            end
        end
    end
    PLV_matrix(subjects_matrix < min_subjects) = nan;
    PLV_matrix(number_of_connections < min_subjects) = nan;
    indices_keep = find(~all(isnan(PLV_matrix), 2));
    newPLV_matrix = PLV_matrix(indices_keep, indices_keep);
    labels = labels(indices_keep);

end