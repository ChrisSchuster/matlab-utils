function [signals,dT] = loadMotec(sourcePath)
%LOADMOTEC loads Motec data into timetable
%   sourcePath:     path to the Motec exportet .mat file
%
%   returnes:
%   signals:        timetable, contains metadata in var.Properties.UserData
%   dT:             duration, average timestep of signals <- this may be
%   removed. a timetable already has a field 'timestep' which seems to
%   return the same result

data = load(sourcePath);                                                    % load file from disk

fldnames = fieldnames(data);                                                % get names of signals in file
nSamples = length(data.(fldnames{1}).Time);                                 % get the number of samples in file
nVariables = numel(fldnames);                                               % get the number of signals in file
timestamps = data.(fldnames{1}).Time - min(data.(fldnames{1}).Time);        % shift time to begin sampling @ t=0, this should be selectable using an argument

signals = timetable('Size',[nSamples nVariables],...                        % init the output table
    'VariableTypes',repmat({'double'},[nVariables,1]),...
    'VariableNames',fldnames,...
    'RowTimes',duration(0, 0, timestamps));

for field=1:nVariables
    signals{:,field} = data.(fldnames{field}).Value';                       % restructure signals into timetable
end

dT = (signals.Time(end) - signals.Time(1))/height(signals);                 % calculate the timestep
% the timesteps in the MoTeC exportet files aren't constant
% for some applications it might be required to have a constant timestamp
% for such cases, this timestep as a average value may be used
signals.Time.Format = 's';                                                  % show the timestamp as ss:SSS

% add metadata to the return value for external use
signals.Properties.UserData.dT = dT;

[~,fName] = fileparts(sourcePath);
signals.Properties.UserData.srcFileName = fName;
signals.Properties.UserData.srcFilePath = sourcePath;

end
