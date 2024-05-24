function [CHANNELS_ALL, subjects]= loadAllChannels(folder_path)
%LOADALLCHANNELS load all channels from data in one folder

    filePattern = fullfile(folder_path, '*.mat');
    files = dir(filePattern);
    CHANNELS_ALL = [];
    subjects = cell(1, length(files));
    for f=1:length(files)
%         [CHANNELS,~] = preprocessing.loadData(fullfile(folder_path, files(f).name));
        load(fullfile(folder_path, files(f).name));
        parts = split(files(f).name, '.');
        subject = parts{1};
        CHANNELS = arrayfun(@(CHAN) setfield(CHAN, 'subject', subject), CHANNELS);
        CHANNELS_ALL = [CHANNELS_ALL, CHANNELS];
        subjects{f} = subject;
    end

end

