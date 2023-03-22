function [signals,dT] = loadMotec(data)
%LOADMOTEC Summary of this function goes here
%   Detailed explanation goes here

fldnames = fieldnames(data);
nSamples = length(data.(fldnames{1}).Time);
nVariables = numel(fldnames);
timestamps = data.(fldnames{1}).Time - min(data.(fldnames{1}).Time);

signals = timetable('Size',[nSamples nVariables],...
    'VariableTypes',repmat({'double'},[nVariables,1]),...
    'VariableNames',fldnames,...
    'RowTimes',duration(0, 0, timestamps));

for field=1:nVariables
    if numel(data.(fldnames{field}).Value)==nSamples
        signals{:,field} = data.(fldnames{field}).Value';
    end
end

dT = (signals.Time(end) - signals.Time(1))/height(signals);
signals.Time.Format = 's';

if any(matches(fldnames,"EShift_Encoder"))
    signals.angle = bits2rad(signals.EShift_Encoder);
end

if any(matches(fldnames,"EShift_Encoder_HD"))
    signals.angle_HD = bits2rad(signals.EShift_Encoder_HD);
end

end