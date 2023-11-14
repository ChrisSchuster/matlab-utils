function msgtable = traceRead(fpath)
firstDataLine = 17;

numVars = 13;

opts = delimitedTextImportOptions('NumVariables', numVars);
opts.VariableNames = {'var1',   'timeOffs', 'direction',   'ID',     'DLC',    'byte0',  'byte1',  'byte2',  'byte3',  'byte4',  'byte5',  'byte6',  'byte7'};
opts.VariableTypes = {'single', 'double',   'categorical', 'string', 'single', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string'};
opts.SelectedVariableNames = 2:numVars;
opts.DataLines = firstDataLine;
opts.Delimiter = " ";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";
opts.TrailingDelimitersRule = "ignore";
% CAN ID
opts = setvaropts(opts, 4, 'NumberSystem', 'hex', 'FillValue', NaN, 'Type', 'uint16');

for variable = 6:13
    opts = setvaropts(opts, variable, 'NumberSystem', 'hex', 'FillValue', NaN, 'Type', 'uint64');
end


msgtable = readtable(fpath, opts);

msgtable.timeOffs = duration(0,0,0,msgtable.timeOffs);
msgtable.timeOffs.Format = "s";

msgtable.data = msgtable.byte0 .* 2^56 + ...
                msgtable.byte1 .* 2^48 + ...
                msgtable.byte2 .* 2^40 + ...
                msgtable.byte3 .* 2^32 + ...
                msgtable.byte4 .* 2^24 + ...
                msgtable.byte5 .* 2^16 + ...
                msgtable.byte6 .* 2^8 + ...
                msgtable.byte7;

msgtable.byte0 = [];
msgtable.byte1 = [];
msgtable.byte2 = [];
msgtable.byte3 = [];
msgtable.byte4 = [];
msgtable.byte5 = [];
msgtable.byte6 = [];
msgtable.byte7 = [];

end
