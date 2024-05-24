function DATA = joinSessions(DATA)
%JOINSESSIONS if multiple sessions appeared, data are concatinated into one
%   DATA structure
%   Detailed explanation goes here
    
    % if only one session
    if length(DATA) == 1
        return;
    end
    
    % define trial time fields
    trial_times_labels = {'t_fix', 't_prep', 't_stim', 't_hold', 't_go', 't_reaction', 't_feedback'};
    % save data from first session
    newTrials = DATA{1}.trials;
    newAmpData = DATA{1}.ampData;
    newTimeAxis = DATA{1}.timeAxis;
    
    % add data from next sessions to the first one("new" variables)
    for ses=2:length(DATA)
        % ending time of previous session
        t_0 = newTimeAxis(end);
        
        % current session data
        nextTimeAxis = DATA{ses}.timeAxis;
        nextAmpData = DATA{ses}.ampData;
        nextTrials = DATA{ses}.trials;
        % update time axis
        nextTimeAxis = nextTimeAxis + t_0;
        % update trials
        for tr=1:length(nextTrials)
            for label=1:length(trial_times_labels)
                nextTrials(tr).(trial_times_labels{label}) = nextTrials(tr).(trial_times_labels{label}) + t_0;
            end
        end
        % save values to the "global" variables
        newAmpData = [newAmpData; nextAmpData];
        newTimeAxis = [newTimeAxis; nextTimeAxis];
        newTrials = [newTrials; nextTrials];
    end
    
    % keep the structure of DATA
    newDATA = cell(1);
    newDATA {1} = DATA{1};
    % update values
    newDATA{1}.ampData = newAmpData;
    newDATA{1}.timeAxis = newTimeAxis;
    newDATA{1}.trials = newTrials;
    DATA = newDATA;

end


