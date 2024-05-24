%% function for combination generation
function combinations = generateCombinations(values)
    n = numel(values);
    combinations = [];
    k = 1;
    for i = 1:n
        for j = i+1:n
            combinations(k,:) = [values(i), values(j)];
            k = k + 1;
        end
    end
end