clc
bytes = 4;
binStrLen = 8*bytes;
original = uint64(0x0D4A65FD);
fprintf('target binary:\n%s\n', layoutBits(dec2bin(original, binStrLen)));

var = uint64(0xFD654A0D);
fprintf('rearranged binary:\n%s\n', layoutBits(dec2bin(var, binStrLen)));

signal_res = uint64(0);

nBytes = bytes -1;
bytemask = uint64(0xFF);

for byte = 0:nBytes
    selectMask = bitshift(bytemask, 8*byte);
    fprintf('selection mask:\n%s\n', layoutBits(dec2bin(selectMask, binStrLen)));

    % select byte from variable
    signal_byte = bitand(var, selectMask);
    fprintf('selected byte:\n%s\n', layoutBits(dec2bin(signal_byte, binStrLen)))

    % shift byte to byte 0 (right most)
    signal_byte = bitshift(signal_byte, -8*byte);
    fprintf('shift by %i bytes to byte0:\n%s\n', -1*byte, layoutBits(dec2bin(signal_byte, binStrLen)))

    % shift byte to the target position
    targetByte = nBytes - byte;
    targetMask = bitshift(bytemask, 8 * targetByte);        % display the target position
    fprintf('target position:\n%s\n', layoutBits(dec2bin(targetMask, binStrLen)))

    signal_byte = bitshift(signal_byte, 8 * targetByte);
    fprintf('shift by %i bytes to target position:\n%s\n', targetByte, layoutBits(dec2bin(signal_byte, binStrLen)))

    % add the byte to the output varibale
    signal_res = bitor(signal_res, signal_byte);
    fprintf('add to output variable:\n%s\n', layoutBits(dec2bin(signal_res, binStrLen)))
end

signal_res2 = byteReorder(bytes, var);

fprintf('target value: \t%i\n', original);
fprintf('result value: \t%i\n', signal_res);
fprintf('function value: %i\n', signal_res2);

function strout = layoutBits(var)
strout = sprintf('%c%c%c%c ', var);
end
