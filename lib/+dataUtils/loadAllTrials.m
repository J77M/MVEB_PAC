function TRIALS_ALL = loadAllTrials(folder_path)
%LOADALLTRIALS load all trials data from data in one folder

    filePattern = fullfile(folder_path, '*.mat');
    files = dir(filePattern);
    TRIALS_ALL = [];
    for f=1:length(files)
        [~,DATA] = preprocessing.loadData(fullfile(folder_path, files(f).name));
        TRIALS_ALL = [TRIALS_ALL; DATA{1}.trials];
    end

end

