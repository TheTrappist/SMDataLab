function [hdr, rawData] = ReadYTDdataFile(fileName)
% Reads a .ytd file collected by the Yildiz Lab trap and returns all the 
% information stored in the file's header in 'hdr' and an m by n matrix of 
% data, where m is the number of samples in the file and n is
% the number of separate channels being measured. 

% Written by Vladislav Belyy
% Last updated on 7/17/2013


fid = fopen(fileName, 'r','ieee-le');
errors = {};

%% Read file header and store all relevant parameters in the hdr struct

hdr = struct([]); % hdr stores all relevant header info

hdr(1).firstChunkID = (fread(fid,[1,4],'*char')); % should read YTDF
if ~strcmp(hdr(1).firstChunkID, 'YTDF') 
    errors = [errors, 'improper file type']; end
hdr(1).firstChunkSize = fread(fid,1,'uint64');
%hdr(1).firstChunkSizeBytes = fread(fid,8,'uint8'); % debug only
hdr(1).secondChunkID = fread(fid,[1,4],'*char'); % FRMT chunk
hdr(1).secondChunkSize = fread(fid,1,'uint64');
hdr(1).nChannels = fread(fid,1,'uint16');
hdr(1).chanIDs = fread(fid,[1,8*hdr(1).nChannels], '*char');
hdr(1).nSamplesSec = fread(fid,1,'uint32');
hdr(1).nSamples= fread(fid,1,'uint64');
hdr(1).bitRes = fread(fid,1,'uint16');
hdr(1).timeStamp = fread(fid,1,'uint64');
%hdr(1).padding = % combine with next line for debugging
fread(fid,[1,(192-(8*hdr(1).nChannels))],'*char'); % padding - ignore
hdr(1).thirdChunkID = fread(fid,[1,4],'*char'); % CALB chunk
hdr(1).thirdChunkSize = fread(fid,1,'uint64');

if hdr(1).thirdChunkSize == 100
    formatVersion = 1.0;
elseif hdr(1).thirdChunkSize == 172
    formatVersion = 1.1;
else
    errors = [errors, 'Unknown format version']; 
end

hdr(1).trackAngle = fread(fid,1,'single');
hdr(1).nmPerMHz = fread(fid,1,'single');
hdr(1).nmPerVolt = fread(fid,1,'single');
hdr(1).coeffsPSD1 = fread(fid,8,'single');
hdr(1).coeffsPSD2  = fread(fid,8,'single');
hdr(1).springConstAOD = fread(fid,2,'single');
hdr(1).springConstPiezo = fread(fid,2,'single');
hdr(1).laserPwrAOD = fread(fid,1,'single');
hdr(1).laserPwrPiezo = fread(fid,1,'single');

if formatVersion == 1.1
    hdr(1).trapOffsets = fread(fid,2,'single');
    fread(fid,[1,64],'*char'); % padding - ignore
end

hdr(1).fourthChunkID = fread(fid,[1,4],'*char'); % DATA chunk
hdr(1).fourthChunkSize = fread(fid,1,'uint64');

%% read actual data


rawData = (fread(fid, [hdr(1).nChannels hdr(1).nSamples], ...
    'int32', 'ieee-le'))';

if isempty(rawData)
    errors = [errors, 'file is empty'];
end

if ~isempty(errors), disp(errors); end

fclose(fid);

