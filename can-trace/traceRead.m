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

bits = 8;

msgtable.data = bitshift(msgtable.byte0, 0*bits) + ...
                bitshift(msgtable.byte1, 1*bits) + ...
                bitshift(msgtable.byte2, 2*bits) + ...
                bitshift(msgtable.byte3, 3*bits) + ...
                bitshift(msgtable.byte4, 4*bits) + ...
                bitshift(msgtable.byte5, 5*bits) + ...
                bitshift(msgtable.byte6, 6*bits) + ...
                bitshift(msgtable.byte7, 7*bits);

end
