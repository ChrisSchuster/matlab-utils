function [figH] = getFigH(numfigs,varargin)
%GETFIGH Summary of this function goes here
%   Detailed explanation goes here

% set default values
windowSyle = 'normal';

% parse variable inputs
for inp=1:2:numel(varargin)
    if ~(ischar(varargin{inp}))
        error('Variable Inputs must be a Name Value Pair.')
    end
    switch lower(varargin{inp})
        case 'windowstyle'
            if any(contains({'docked','modal','normal'},lower(varargin{inp+1})))
                windowSyle = lower(lower(varargin{inp+1}));
            else
                error('Unrecognized WindowStyle Parameter');
            end
    end
end

figHtemp = findobj('type','figure');
if logical(numel(figHtemp))
    map = [];
    for fig=1:numel(figHtemp)
        map(fig) = figHtemp(fig).Number;
    end
%     [~,map] = sort(map(:,2),'descend');
    for fig=1:numel(figHtemp)
        figH(fig) = figHtemp(map(fig));
        set(0,'CurrentFigure',figH(fig));clf;
    end
    for fig=fig:numfigs-numel(figHtemp)
        figH(fig+1) = figure();
        drawnow
    end
    delete(figHtemp(numfigs+1:end))
    clearvars figHtemp map
else
    for fig=1:numfigs
        figH(fig) = figure();
        drawnow();
    end
end
for fig=1:numel(figH)
    figH(fig).WindowStyle = windowSyle;
end

end

