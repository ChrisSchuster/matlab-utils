function trace = loadPCANtrace(dbcPath, tracePath)
%PARSETRACE Summary of this function goes here
%   dbcPath:    path to the DBC file
%   tracePath:  path to the CAN trace file

dbc = canDatabase(dbcPath);     % load the dbc
rawTrace = traceRead(tracePath);

trace = struct();
nMsg = numel(dbc.Messages);

for msgIDidx = 1:nMsg       % message ID index

    mask = rawTrace.ID == dbc.MessageInfo(msgIDidx).ID;
    msgName = dbc.Messages{msgIDidx};
    data = rawTrace(mask,:).data;

    trace.(msgName) = rawTrace(mask,1);

    nSignals = numel(dbc.MessageInfo(msgIDidx).Signals);
    for sig = 1:nSignals
        % get signal metadata
        sigName = dbc.MessageInfo(msgIDidx).Signals{sig};
        offset = dbc.MessageInfo(msgIDidx).SignalInfo(sig).Offset;
        scale = dbc.MessageInfo(msgIDidx).SignalInfo(sig).Factor;               % signal scaling factor
        endianess = dbc.MessageInfo(msgIDidx).SignalInfo(sig).ByteOrder;

        startbit = dbc.MessageInfo(msgIDidx).SignalInfo(sig).StartBit;

        switch endianess
            case 'BigEndian'
                startbit = startbit - 8;
        end

        length = dbc.MessageInfo(msgIDidx).SignalInfo(sig).SignalSize;
        endbit = startbit + length;
        % bitorder in the CAN message is inverse to the bitorder we use
        invStartbit = 64 - endbit;
        % create mask to select signal from data
        bitmask = 2^length - 1;
        bitmask = bitshift(uint64(bitmask),invStartbit);

        signal = bitshift(bitand(data,bitmask), -1*invStartbit);

        %% rearrange bytes when byte order is little / intel
        switch endianess
            case 'LittleEndian'
                bytes = ceil(length / 8);
                if bytes > 1
                    signal = byteReorder(bytes,signal);
                end
        end

        signal = double(signal) * scale + offset;

        trace.(msgName).(sigName) = signal;
    end
end
end
