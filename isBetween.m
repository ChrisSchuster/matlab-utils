function [state] = isBetween(signal, interval, interval_width)
%ISBETWEEN returns true when signal is between min and max
%   interval:   interval of interest
%   width:      width of the detection band in case of scalar interval
%
%   interval:
%       vector:             [lower upper]
%       scalar w width:     [center] (+/- width)
%       scalar w/o width:   [-value value]

if width(interval)==1           % scalars or single column vectors
    if nargin < 3
        min = -1 * interval;
        max =      interval;
    else
        min = interval - interval_width;
        max = interval + interval_width;
    end
else                            % vectors, or multi column vectors
    min = interval(:,1);
    max = interval(:,2);
end

state1 = signal > min;
state2 = signal < max;

state = and(state1, state2);

end

