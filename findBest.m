function ind = findBest(LuT,sVal)
%FINDBEST find index of value in LuT that best fits the search value
%   LuT: Look up Table, vector to be searched
%   sVal: search Value, Value we want to find best match in LuT for
%   ind: index of value in LuT, that best fits sVal

%   See also find, min
[~,ind] = min(abs(LuT - sVal));
end

