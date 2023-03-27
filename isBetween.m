function [state] = isBetween(signal,min,max)
%ISBETWEEN returns true when signal is between min and max
%   Detailed explanation goes here

state1 = signal > min;
state2 = signal < max;

state = and(state1,state2);

end

