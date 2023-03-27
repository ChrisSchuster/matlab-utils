function [state] = isBetween(signal, interval, width)
%ISBETWEEN returns true when signal is between min and max
%   interval:   interval of interest
%   width:      width of the detection band in case of scalar interval
%
%   interval:
%       vector:             [lower upper]
%       scalar w width:     [center] (+/- width)
%       scalar w/o width:   [-value value]

if isscalar(interval)
    if nargin < 3
        min = -1 * interval;
        max =      interval;
    else
        min = interval - width;
        max = interval + width;
    end
else
    min = interval(1);
    max = interval(2);
end

state1 = signal > min;
state2 = signal < max;

state = and(state1, state2);

end

