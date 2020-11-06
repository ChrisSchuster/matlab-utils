function axSetup()
%AXSETUP Show grid and minor grid in all existing axes handles

axH = findobj('type','axes');
flds = {'XGrid','XMinorGrid','YGrid','YMinorGrid','ZGrid','ZMinorGrid'};
for ax = 1:numel(axH)
    for fld = 1:numel(flds)
        axH(ax).(flds{fld}) = true;
    end
end

