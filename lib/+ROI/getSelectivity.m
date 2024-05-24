function [num_sel, num_all, labels] = getSelectivity(selected_values, all_values)
%GETSELECTIVITY Summary of this function goes here
%   Detailed explanation goes here

    [labels, ~, idc] = unique(selected_values);
%     [labels, ~, idc] = unique(selected_values, 'stable');

    num_sel = accumarray( idc, ones(size(idc)));

    num_all = cellfun(@(x) sum(strcmp(all_values, x)), labels, 'UniformOutput', false);
    num_all = cell2mat(num_all).';
    
end

