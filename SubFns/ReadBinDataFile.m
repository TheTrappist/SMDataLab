function data = ReadBinDataFile(fileName,ChannelLogic, numSamples)
% Reads a binary file collected by the Yildiz Lab trap and returns an m by 
% n matrix of double, where m is the number of samples in the file and n is
% the number of separate channels being measured (PSD1 x/y, PSD2 x/y, AOD
% trap x/y, and piezo trap x/y)
%
% Written by Vladislav Belyy
% Last updated on 2/12/2013


fid = fopen(fileName);

numChan = (ChannelLogic(1)+ChannelLogic(2))*4 + ... % PSD1 and PSD2
    (ChannelLogic(3)+ChannelLogic(4))*2;    % Trap position 1 and 2

% read binary file:
binaryData = (fread(fid, [numChan numSamples], 'int32', 'ieee-be'))';
rawData = binaryData / 131072; % convert back from int32 to double

fclose(fid);

data = [];
currInd = 1; % keeping track of channels already read

if ChannelLogic(1) % PSD1 recorded
    data = [rawData(:,2)./rawData(:,4), rawData(:,1)./rawData(:,3)];
    currInd = currInd + 4;
end

if ChannelLogic(2) % PSD2 recorded
    data = [data, rawData(:,currInd)./rawData(:,currInd+2), ...
        rawData(:,currInd+1)./rawData(:,currInd+3)];
    currInd = currInd + 4;
end

if ChannelLogic(3) % trap position 1 (AOD trap) recorded
    data = [data, rawData(:,currInd+1), rawData(:,currInd)];
    currInd = currInd + 2;
end

if ChannelLogic(4) % trap position 2 (piezo trap) recorded
    data = [data, rawData(:,currInd+1), rawData(:,currInd)];
end