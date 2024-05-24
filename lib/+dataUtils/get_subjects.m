function [subjects, subjects_paths ]= get_subjects(folder_path)
%GET_SUBJECTS Summary of this function goes here
%   Detailed explanation goes here
    files = dir(fullfile(folder_path, "*.mat"));
    subjects = arrayfun(@(x) x.name, files, 'UniformOutput', false);
    % workaround for sorting as S1, S2, .. S10,..(default matlab files sort as : S1, S10, S11, S2, ...)
    % https://www.mathworks.com/matlabcentral/answers/43816-how-can-i-sort-a-string-both-alphabetically-and-numerically
    if ~contains(subjects{1}, '_')
        R = cell2mat(regexp(subjects ,'(?<Name>\D+)(?<Nums>\d+)','names'));
        tmp = sortrows([{R.Name}' num2cell(cellfun(@(x)str2double(x),{R.Nums}'))]);
        subjects = strcat(tmp(:,1) ,cellfun(@(x) num2str(x), tmp(:,2),'unif',0));  
    end
    
    [~,subjects,~] = fileparts(subjects);
    subjects_paths = fullfile(folder_path, strcat(subjects, '.mat'));
end

