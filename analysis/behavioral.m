% behavioral analysis

clear all; clc;
% add path to library
filePath = fileparts(matlab.desktop.editor.getActiveFilename);
addpath(fullfile(filePath,'../lib'));
 
%% define paths, params and load data
data_path = "/home/jur0/project_iEEG/code/data/MVEB_BIP";
save_path = "/home/jur0/project_iEEG/code/figs/OUT/behavioral";

[subjects, subjects_paths]= dataUtils.get_subjects(data_path);

difficulties = {'1', '2', '4', '6'};

%% subjects
N_trials = zeros(length(difficulties), 1);
N_correct = zeros(length(difficulties), 1);
N_missed = zeros(length(difficulties), 1);
N_incorrect = zeros(length(difficulties), 1);
N_reaction_time_all = cell(length(difficulties), 1);

for s=1:length(subjects)
    % paths
    subject_path = subjects_paths{s};
    % load SEEG data
    [CHANNELS, DATA] = preprocessing.loadData(subject_path);
    DATA = dataUtils.joinSessions(DATA);
    trials = DATA{1}.trials;
    % get trials difficulties
    subject_difficulties = trialsUtils.getTrialsValues(trials, 'difficulty');
    % get reaction time
    reaction_time = cell2mat(trialsUtils.getTrialsValues(trials, 'reactionTime'));
    % iterate over difficulties
    for d=1:length(difficulties)
        % get indices of trials with difficulties
        diff_indices = find(contains(subject_difficulties, difficulties{d}));
        N_trials(d) = N_trials(d) + length(diff_indices);

        % get response values
        answers = trialsUtils.getTrialsValues(trials, 'answer_ok');
        answers = answers(diff_indices);
        N_correct(d) = N_correct(d) + length(find(contains(answers,'right')));
        N_missed(d) = N_missed(d) + length(find(contains(answers,'missed')));
        N_incorrect(d) = N_incorrect(d) + length(find(contains(answers,'wrong')));

        % get reaction time
        N_reaction_time_all{d} = [N_reaction_time_all{d}, reaction_time(diff_indices)];
    end
    fprintf('subject %s trials: %d\n', subjects{s}, length(trials));
end

%%
N_correct = 100*N_correct./N_trials;
N_incorrect = 100*N_incorrect./N_trials;
N_missed = 100*N_missed./N_trials;
N_reaction_time = cellfun(@(x) nanmean(x), N_reaction_time_all);

[r, p] = corr(N_reaction_time, [1 2 4 6].', 'type', 'Pearson', 'tail', 'right')

%% plot behavioral

% h = figure('Position',[370,340,800,220]);
h = visualization.getFigure(0.2);

tl = tiledlayout(1,2, 'Padding', 'compact', 'TileSpacing', 'compact'); 

X = categorical({'1','2','4','6'});
X = reordercats(X,{'1','2','4','6'});

ax = nexttile;
bar(X, [N_correct, N_incorrect, N_missed], 'stacked', 'BarWidth', 0.5)
xlabel('difficulty')
ylabel('answer type [%]')
title('answer type percentage')
ylim([0, 105])
yticks([0, 25, 50, 75, 100])
title("(A)")
legend(ax, {'right', 'wrong', 'missed'}, 'Orientation','horizontal', 'Location','south')

nexttile
bar(X, N_reaction_time, 'BarWidth', 0.5)
xlabel('difficulty')
ylabel('duration [s]')
title('average reaction duration')
ticks = 0.2:0.2:1.2;
yticks(ticks)
yticklabels(arrayfun(@(x) sprintf("%.1f", x), ticks))
title("(B)")

ylim([0, 1.2])

h = visualization.formatFigure(h);
%% save
% print(h, save_path + ".png",'-dpng','-r300');
visualization.saveFigure(h, save_path, 'pdf'); 
