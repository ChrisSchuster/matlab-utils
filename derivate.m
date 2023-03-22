function [d_signal] = derivate(signal, timestep, order)
%DERIVATE calculate the derivative of a signal with respect to time
%   signal:     vector of the signal
%   timestep:   timestep of the signal in seconds
%   order:      order of the derivative (default is 1)

% first value of the derivate vector needs to be NaN
% signal:      v1    v2    v3    v4    v5
%               | \   | \   | \   | \   |
%               |  \  |  \  |  \  |  \  |
%               |   \ |   \ |   \ |   \ |
% derivative:  NaN   d12   d23   d34   d45

if nargin <= 2
    order = 1;
end

% convert timestep to type double
if isduration(timestep)
    timestep = seconds(timestep);
end

d_signal_t = diff(signal,order) / timestep;     % calculate the derivative
d_signal = [nan(order,1); d_signal_t];          % see explanation above


end

