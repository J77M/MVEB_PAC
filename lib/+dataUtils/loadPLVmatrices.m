function PLV_matrices_ALL = loadPLVmatrices(data_path, subjects)
    

    PLV_matrices_ALL = cell(1, 4);
    PLV_matrix_ALL1 = [];
    PLV_matrix_ALL2 = [];
    PLV_matrix_ALL3 = [];
    PLV_matrix_ALL4 = [];
    for s=1:length(subjects)
        load(fullfile(data_path, strcat(subjects{s}, '.mat')))
        PLV_matrix_ALL1 = blkdiag(PLV_matrix_ALL1, squeeze(PLV_matrices(1, :, :)));
        PLV_matrix_ALL2 = blkdiag(PLV_matrix_ALL2, squeeze(PLV_matrices(2, :, :)));
        PLV_matrix_ALL3 = blkdiag(PLV_matrix_ALL3, squeeze(PLV_matrices(3, :, :)));
        PLV_matrix_ALL4 = blkdiag(PLV_matrix_ALL4, squeeze(PLV_matrices(4, :, :)));
    end
    PLV_matrices_ALL{1} = PLV_matrix_ALL1;
    PLV_matrices_ALL{2} = PLV_matrix_ALL2;
    PLV_matrices_ALL{3} = PLV_matrix_ALL3;
    PLV_matrices_ALL{4} = PLV_matrix_ALL4;

end