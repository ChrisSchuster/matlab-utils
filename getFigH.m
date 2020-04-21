function [figH] = getFigH(numfigs,varargin)
%GETFIGH Summary of this function goes here
%   Detailed explanation goes here

% set default values
windowSyle = 'keep';
setcolor = false;

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
        case 'color'
            setcolor = true;
            switch lower(varargin{inp+1})
                case 'default'
                    color = '#F0F0F0';  % hex value of Matlab-default background color
                otherwise               % ToDo: proper detection of type and validity of input
                    color = lower(varargin{inp+1});
            end
    end
end

figHtemp = findobj('type','figure');
if logical(numel(figHtemp))
    map = [];
    for fig=1:numel(figHtemp)
        map =  [map; fig figHtemp(fig).Number];
    end
    [~,map] = sort(map(:,2),'descend');
    figH = gobjects(numfigs,1);
    for fig=1:numel(figHtemp)
        figH(fig) = figHtemp(map(fig));
        set(0,'CurrentFigure',figH(fig));clf;
    end
    for fig=fig:numfigs-numel(figHtemp)
        figH(fig+1) = figure();
        drawnow
    end
    delete(figHtemp(numfigs+1:end))
else
    for fig=1:numfigs
        figH(fig) = figure();
        drawnow();
    end
end
% apply configs
for fig=1:numel(figH)
    if strcmp(windowSyle,'keep')
        figH(fig).WindowStyle = figHtemp(map(fig)).WindowStyle;
    else
        figH(fig).WindowStyle = windowSyle;
    end
    if setcolor
        figH(fig).Color = color;
    end
end

end

