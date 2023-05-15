function [signals] = loadMotec(sourcePath)
%LOADMOTEC loads Motec data into timetable
%   sourcePath:     path to the Motec exportet .mat file
%
%   returns:
%   signals:        timetable, contains metadata in var.Properties.UserData

data = load(sourcePath);                                                    % load file from disk

fldnames = fieldnames(data);                                                % get names of signals in file
nVariables = numel(fldnames);                                               % get the number of signals in file

nSamples = NaN(nVariables,1);                                               % list of sample counts per signal
for field=1:nVariables
    nSamples(field) = numel(data.(fldnames{field}).Time');
end

nSamples_bin = unique(nSamples);                                            % get a list of unique sample counts

% create bins for signals of same count
apped_table = false;
tic
for bin = 1:numel(nSamples_bin)
    signals_in_bin = find(nSamples==nSamples_bin(bin));                     % get a list of indices of signals in a bin of same sample count
    nSignals_in_bin(bin) = numel(signals_in_bin);                           % number of signals in each bin
    
    % get matching timestamps for the signals in the current bin
    result = compareTimestamps(data, fldnames(signals_in_bin), nSamples_bin(bin));

    if all(result)                                                          % all timestamps match: signals can be placed in a table directly
        temp_table = signals2table(data, fldnames(signals_in_bin), nSamples_bin(bin));
    else                                                                    % some timestamps are mismatch: further processing required
        % we group the signals into bins again
        % all signals matching with the first signal of the bin will be placed in a table
        binsRemaining = true;
        append_subtable = false;

        while binsRemaining
            % get indices of signals currently matching the timestamp bin
            signals_in_subBin = signals_in_bin(result);
            % create a table from these signals
            temp_table_subBin = signals2table(data, fldnames(signals_in_subBin), nSamples_bin(bin));
            % either this table is the basis for a syncronisation operation
            % next time around or it needs to be syncronised
            if append_subtable                                              % the table needs to be syncronised into an existing table
                temp_table = synchronize(temp_table, temp_table_subBin, 'union', 'previous');
            else                                                            % this table is the first for this sub bin operation
                temp_table = temp_table_subBin;
                append_subtable = true;
            end
            signals_in_bin = signals_in_bin(~result);                       % remove processed signals
            if isempty(signals_in_bin)                                      % check if there are any more timestamps bins
                binsRemaining = false;                                      % end operation
            else                                                            % look for new timestamp bins
                result = compareTimestamps(data, fldnames(signals_in_bin), nSamples_bin(bin));
            end
        end
    end

    % our table is either the basis for the output table or it needs to
    % syncronised into the output table
    if apped_table
        signals = synchronize(signals, temp_table, 'union', 'previous');
    else
        signals = temp_table;
        apped_table = true;
    end
end
toc

signals.Time.Format = 's';                                                  % show the timestamp as ss:SSS

[~,fName] = fileparts(sourcePath);
signals.Properties.UserData.srcFileName = fName;
signals.Properties.UserData.srcFilePath = sourcePath;

end

function temp_table = signals2table(data, signal_names, nSamples)
% this function creates a timetable from a list of signals

nSignals = numel(signal_names);                                             % number of signals, used to preallocate the matrix
signaltemp = NaN(nSamples, nSignals);                                       % sample count, used to preallocate the matrix
for signal = 1:nSignals                                                     % loop over all signals, enter into the matrix
    signaltemp(:,signal) = data.(signal_names{signal}).Value';
end
time = duration(0, 0, data.(signal_names{signal}).Time');                   % create the timestamp vector
temp_table = array2timetable(signaltemp, 'RowTimes', time, 'VariableNames', signal_names);  % create table from time vector and signal matrix

end

function result = compareTimestamps(data, signals, nSamples)
% this function returns a logical value for each signal
% it's true, when a signals timesteps match with the timesteps of the first
% signal in the list
% for the first signal it returns true (matches with itself)

result = true;

nSignals = numel(signals);

if nSignals < 2                                                             % end operation, when there is only one signal
    return
end

timestamps = NaN(nSamples, nSignals);                                       % store the timestamps for each signal of the bin
timestamps(:,1) = data.(signals{1}).Time';                                  % preload the array with the main timestamps we comapre against

for signal = 2:nSignals                                                     % loop over all signals in the bin
    timestamps(:, signal) = data.(signals{signal}).Time';                   % get timestamps of the current signal
    result(signal) = all(timestamps(:,1) == timestamps(:,signal));
end
end
