function startbit_big = bigStartbit(startbit_little)
%INTELSTARTBIT Summary of this function goes here
%   Detailed explanation goes here

startbyte = floor(startbit_little ./ 8);
bitoffset = 7 - mod(startbit_little, 8);

startbit_big = 63 - (startbyte .* 8 + bitoffset);

end

