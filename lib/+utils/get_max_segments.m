function [max_segments, sum_segments, segments_all, segments_indices]= get_max_segments(subject_pvals, thr)
    max_segments = zeros(1, size(subject_pvals, 2));
    sum_segments = zeros(1, size(subject_pvals, 2));
    segments_all = cell(1, size(subject_pvals, 2));
    segments_indices = cell(1, size(subject_pvals, 2));
    for ch=1:size(subject_pvals, 2)
        array = subject_pvals(:, ch);
        log_array = array < thr;
        segments_indices_ch = find(diff([0 log_array.'], 1) == 1);
        segments = [];
        current_segment = 0;
        for idx=1:length(array)
            if log_array(idx) == 0 && current_segment ~= 0
                segments = [segments, current_segment];
                current_segment = 0;
            elseif log_array(idx) == 1
                current_segment = current_segment + 1;
            end
        end
        if current_segment > 0
            segments = [segments, current_segment];
        end
        max_segments(ch) = max([segments, 0]);
        sum_segments(ch) = sum([segments, 0]);
        segments_indices{ch} = segments_indices_ch;
        segments_all{ch} = segments;
    end
end