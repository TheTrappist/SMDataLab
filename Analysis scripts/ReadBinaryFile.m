function data = ReadBinaryFile(fileName,numChan, SR, length)
% Reads a binary file collected by the Yildiz Lab trap and returns an m by 
% n matrix of double, where m is the number of samples in the file and n is
% the number of channels

% Written by Vladislav Belyy
% Last updated on 2/28/2012


fid = fopen(fileName);

% read binary file:
binaryData = (fread(fid, [numChan SR*length], 'int32', 'ieee-be'))';

data = binaryData / 131072;
