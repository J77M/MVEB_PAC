function [trialsData] = extractTrialsTimeSegments(data, timeAxis, t_start, t_stop)
% TODO: replace extractTrialsTimeSegments by extractTrialsTimeSegments2 in
% all scripts

%extractTrialsTimeSegments this function allow to extract time segments in trials for data with different dimensions
% returned size of trialsData is (size of time segment, other dims. of data, trials)
% where size of time segment is defined by t_start, t_stop
%
%   Expects that the first dim. of data are values corresponding to timeAxis
%   e.g., size(ampData) = (values, num of channels)
%   trials is struct with trials data (timing of events during recording session)
%   t_start, t_stop are vectors with length=trials which define start and stop time in each trial 
%   t_start, t_stop  difference should be the same across the trials if not
%   the time segment is shortened (less then t_stop) to match the min. duration
%   (so we could create multi dim. array ; and average data across trials for each time step)
    
    % allocation 
    startIdxs = zeros(1, length(t_start));
    stopIdxs = zeros(1, length(t_start));
    % iterate over trials to get indices of t_start and t_stop appearance in timeAxis 
    for tr=1:length(t_start)
        [~, idx_start] = min(abs(timeAxis-t_start(tr)));
        [~, idx_stop] = min(abs(timeAxis-t_stop(tr)));
        startIdxs(tr) = idx_start;
        stopIdxs(tr) = idx_stop;
    end
    % check if all time segments / epochs are the same size
    epochSize = stopIdxs(1) - startIdxs(1);
    if ~all(stopIdxs - startIdxs == epochSize)
        warning("time segment lengths not equal applying correction, std is %.2f frames", std(stopIdxs - startIdxs))
    end
    % the trials should have the same length therefore correction is applied
    % first the min. length of trial is determined and other trials are
    % shortened to match the length of the shortest trial - dont want to bias data
    
    minLength = min(stopIdxs - startIdxs);
    stopIdxs = stopIdxs - (stopIdxs - startIdxs - minLength);

    % allocation 
    newSize = [minLength + 1, size(data, 2:ndims(data)) length(t_start)];
    trialsData = zeros(newSize);
    % hack to make this function work with different dimensions
    % https://stackoverflow.com/questions/19955653/matlab-last-dimension-access-on-ndimensions-matrix
    otherdims = repmat({':'},1,ndims(data));

    % extract channel Data for each trial
    for tr=1:length(t_start)
        channelsTrialData = data(startIdxs(tr):stopIdxs(tr), otherdims{:});
        trialsData(otherdims{:}, tr) = channelsTrialData;
    end
end

