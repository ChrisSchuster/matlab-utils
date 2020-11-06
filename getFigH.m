function [varargout] = getFigH(numfigs,varargin)
%  [figH] = GETFIGH(numfigs,varargin) Creates figure handles
%   Matlab plotting features per default create figure objects as parent
%   object. Manipulating them requires having a reference to the object
%   handle. GETFIGH creates a handle to figure objects, that can be passed
%   to plotting features and can be manipulated more easily.
%
%%   Arguments:
%    - numfigs: number of figures to create
%    - WindowStyle: docked (default), modal, normal, keep
%    - Color: default, hexcode
%   Explanation:
%    - WindowStyle: modal: floating window, figures are tabbed in the
%                   window
%                   docked: window element is docked in the Matlab UI
%                   int the position last used
%    - Color: default: uses the default color Matlab uses as backdrop for
%             figures
%             hexcode: sets the hexcode provided as backdrop color
%%

% set default values
windowStyleMode = 'default';
windowStyle = 'docked';     % default window style
setcolor = false;           % per default no color is specified
caxis = false;              % per default no axis handles are createds

% check for empty input
if ~nargin
    numfigs = 1;            % default is 1 figure handle
end
% when 2 outputs are specified, create and return an axis handle
if nargout==2
    caxis = true;
end
% parse variable inputs
for inp=1:2:numel(varargin)
    if ~(ischar(varargin{inp}))
        error('Variable Inputs must be a Name Value Pair.')
    end
    switch lower(varargin{inp})
        case 'windowstyle'
            if any(contains({'docked','modal','normal'},lower(varargin{inp+1})))
                windowStyleMode = 'setspecific';
                windowStyle = lower(lower(varargin{inp+1}));
            elseif strcmpi('keep',varargin{inp+1})
                windowStyleMode = 'keep';
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
        case 'createaxis'
            warning("The argument 'createaxis' is depreciated. Specifying two output variables is emough, to recieve an axis handle as well.")
            caxis = true;
    end
end

figHtemp = findobj('type','figure');            % retrieve handles for currently existing figures
if logical(numel(figHtemp))                     % if there currently exist figures, reuse the handles
    map = [];
    for fig=1:numel(figHtemp)                   % create a map from from handle index in struct to inherent sequential number of the figure handle
        map =  [map; fig figHtemp(fig).Number];
    end
    [~,map] = sort(map(:,2),'ascend');
    figH = gobjects(numfigs,1);                 % empty graphic object to be filled with figure handles
    for fig=1:min(numfigs,numel(figHtemp))      % fill gobject with existing figure handles
        figH(fig) = figHtemp(map(fig));
        set(0,'CurrentFigure',figH(fig));clf;   % activate each and clear the figure
    end
    for fig=(fig+1):numfigs                     % if fewer handles exist previously than requested, create the remaining amount
        figH(fig) = figure();
        drawnow();
    end
else                                            % if no handles exist previously, create all of them
    for fig=1:numfigs
        figH(fig) = figure();
        drawnow();
    end
end
if caxis                                        % if requested create empty graphic object to be filled with axis handles
    axH = gobjects(numfigs,1);
end
% apply configs
for fig=1:numel(figH)
    switch windowStyleMode
        case 'keep'
            figH(fig).WindowStyle = figHtemp(map(fig)).WindowStyle;
        case 'default'
            figH(fig).WindowStyle = windowStyle;
        case 'setspecific'
            figH(fig).WindowStyle = windowStyle;
    end
    if setcolor
        figH(fig).Color = color;
    end
    if caxis
        axH(fig) = axes(figH(fig));
        axH(fig).XGrid = 'on';
        axH(fig).YGrid = 'on';
        axH(fig).ZGrid = 'on';
        axH(fig).XMinorGrid = 'on';
        axH(fig).YMinorGrid = 'on';
        axH(fig).ZMinorGrid = 'on';
    end
end

if numel(figHtemp)
    delete(figHtemp(map(numfigs+1:end)))
end
% return handles
varargout{1} = figH;
% when create axis flag is set, also return the axis handle
if caxis
    varargout{2} = axH;
end
end