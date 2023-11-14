function [var_res] = byteReorder(bytes, var)
%BYTEREORDER Summary of this function goes here
%   bytes:   size of the input variable datetype in byte
%   var:     variable
%   var_res: output variable

var_res = uint64(0);                                                        % prealloc output variable

nBytes = bytes -1;                                                          % we need byte numbers in reference to 0

for byte = 0:nBytes
    selectMask = bitshift(uint64(0xFF), 8*byte);                            % select byte from variable using mask

    signal_byte = bitshift(bitand(var,selectMask), 8*(nBytes - 2*byte));    % shift selected byte to target position

    var_res = bitor(var_res, signal_byte);                                  % add selected byte to the output variable
end

end
