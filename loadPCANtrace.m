function trace = loadPCANtrace(dbcPath, tracePath)
%PARSETRACE Summary of this function goes here
%   dbcPath:    path to the DBC file
%   tracePath:  path to the CAN trace file

dbc = canDatabase(dbcPath);                                                 % load the dbc

%% load the trace
firstDataLine = 17;                                                         % ignore the header of the trace file
numVars = 13;                                                               % define the number of columns the trace file is structured into

opts = delimitedTextImportOptions('NumVariables', numVars);
opts.VariableNames = {'var1',   'timeOffs', 'direction',   'ID',     'DLC',    'byte0',  'byte1',  'byte2',  'byte3',  'byte4',  'byte5',  'byte6',  'byte7'};
opts.VariableTypes = {'single', 'double',   'categorical', 'string', 'single', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string'};
opts.SelectedVariableNames = 2:numVars;
opts.DataLines = firstDataLine;
opts.Delimiter = " ";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";
opts.TrailingDelimitersRule = "ignore";

opts = setvaropts(opts, 4, 'NumberSystem', 'hex', 'FillValue', NaN, 'Type', 'uint16');  % special read instructions for the CAN ID column

for variable = 6:13
    opts = setvaropts(opts, variable, 'NumberSystem', 'hex', 'FillValue', NaN, 'Type', 'uint64');
end


msgtable = readtable(tracePath, opts);

msgtable.timeOffs = duration(0,0,0,msgtable.timeOffs);
msgtable.timeOffs.Format = "s";

bits = 8;

msgtable.data = bitshift(msgtable.byte0, 0*bits) + ...
                bitshift(msgtable.byte1, 1*bits) + ...
                bitshift(msgtable.byte2, 2*bits) + ...
                bitshift(msgtable.byte3, 3*bits) + ...
                bitshift(msgtable.byte4, 4*bits) + ...
                bitshift(msgtable.byte5, 5*bits) + ...
                bitshift(msgtable.byte6, 6*bits) + ...
                bitshift(msgtable.byte7, 7*bits);

%% parse the CAN trace message table

trace = struct();
nMsg = numel(dbc.Messages);

for msgIDidx = 1:nMsg       % message ID index

    mask = msgtable.ID == dbc.MessageInfo(msgIDidx).ID;
    msgName = dbc.Messages{msgIDidx};
    data = msgtable(mask,:).data;

    trace.(msgName) = msgtable(mask,1);

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
