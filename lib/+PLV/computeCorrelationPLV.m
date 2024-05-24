function [rho_matrix, p_matrix] = computeCorrelationPLV(PLV_matrices)

    N = size(PLV_matrices, 2);
    rho_matrix = zeros(N);
    p_matrix = zeros(N);
    for i = 1:N
        for j = 1:N
            if isnan(PLV_matrices(:, i, j))
                rho_matrix(i, j) = nan;
                p_matrix(i, j) = nan;
            else
                % Extract the current NxN matrix
                current_matrix = squeeze(PLV_matrices(:, i, j));
                % Compute correlation coefficient and p-value
                [rho, p] = corr(current_matrix(:), [1 2 4 6]', "Type", "Pearson", "Tail","right");
                % Store the values in the corresponding positions
                p_matrix(i, j) = p;
                rho_matrix(i, j) = rho;
            end
        end
    end

end