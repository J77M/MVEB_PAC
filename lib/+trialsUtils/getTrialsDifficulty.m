function difficulties = getTrialsDifficulty(trials)
%GETTRIALDIFFICULTY Summary of this function goes here
    
    difficulties = zeros(1, length(trials));
    for tr=1:length(trials)
        difficulty = trials(tr).difficulty;
        difficulties(tr) = str2num(difficulty);
    end
end

