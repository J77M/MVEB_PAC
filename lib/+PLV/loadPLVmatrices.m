function PLV_matrices_ALL = loadPLVmatrices(data_path, subjects, MNI, distance_filter)

    if nargin < 4
        distance_filter = 10;
    end

    PLV_matrices_ALL = nan(4, length(MNI), length(MNI));
    
    idx = 1;
    for s=1:length(subjects)
        % load PLV matrix
        load(fullfile(data_path, strcat(subjects{s}, '.mat')))    
        % filter out by distance
        Nchannels_subjects = size(PLV_matrices, 2);
        
        subject_range = idx:idx + Nchannels_subjects - 1;
        MNI_subject = MNI(subject_range, :);
        distances = pdist2(MNI_subject, MNI_subject);
        
        % filter by distance
        for c=1:size(PLV_matrices, 1)
            PLV_matrix = squeeze(PLV_matrices(c, :, :));
            PLV_matrix(distances < distance_filter) = nan;
            PLV_matrices_ALL(c, subject_range, subject_range) = PLV_matrix;
        end        
        idx = idx + Nchannels_subjects;
    end

end
