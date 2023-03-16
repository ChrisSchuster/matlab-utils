function [index, value] = findBest(LuT,searchValue)
%FINDBEST find index of value in LuT that best fits the search value
%   LuT:         Look up Table, vector to be searched
%   searchValue: value we want to find the best match in LuT for
%   index:       index of value in LuT, that best fits the search value
%   value:       returns the value in LuT which best fits the search value

%   See also find, min
[~,index] = min(abs(LuT - searchValue));
value = LuT(index);

end
