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

        startbit = dbc.MessageInfo(msgIDidx).SignalInfo(sig).StartBit;
        endianess = dbc.MessageInfo(msgIDidx).SignalInfo(sig).ByteOrder;
        
        if(matches(endianess, 'BigEndian'))
            data_temp = byteReorder(8, data);                               % reorder entire data in message
            startbit = bigStartbit(startbit);
        else
            data_temp = data;
        end
        
        length = dbc.MessageInfo(msgIDidx).SignalInfo(sig).SignalSize;
        bitmask = 2^length - 1;
        bitmask = bitshift(uint64(bitmask),startbit);

        signal = bitshift(bitand(data_temp,bitmask), -1*startbit);

        signal = double(signal) * scale + offset;

        trace.(msgName).(sigName) = signal;
    end
end
end
