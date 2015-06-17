function data = ReadHighFreqFile(fsamp,startpath,rootfile);

% data = ReadHighFreqFile(fsamp,path,file)
%
% Reads high frequency binary data file(s), and outputs to structure cell array "data". 
% fsamp = sampling rate, path = pathname, file = filename cell array.
%
% Set Data Paths 
global analysisPath;
global rawDataPath;

if nargin < 2
    if ~isempty(rawDataPath)
        startpath = [rawDataPath '\']; else startpath = [pwd '\']; 
    end
end;
if nargin < 3
    [rootfile, currentpath] = uigetfile([startpath '*.dat'], 'MultiSelect', 'on');
    startpath = currentpath;
end;

if ~iscell(rootfile)
    ind2 = 1;
    temp = rootfile;
    rootfile = cell(1, 1);
    rootfile{1} = temp;
    clear temp;
else
    [ind1, ind2] = size(rootfile);
end

data = cell(1,ind2);

letter = ['a' 'b' 'c' 'd' 'e' 'f' 'g'];
header = 85;

for j = 1:ind2
    for i = 1:8
        if i==1
            file = rootfile{j};
        else
            file = [letter(i-1) rootfile{j}];
        end;    
        % Parse data
        h = fopen([startpath file]);
        m = fread(h,1e10,'float32','ieee-be');
        n = m(header:(size(m)-header));
        c = size(n);
        l(i,:) = n(:);
        fclose(h);
        clear m n c;        
    end
    data{j}.path = startpath;
    data{j}.file = rootfile{j};

    N = length(l(1,:));
    data{j}.A_X = l(3,:)./l(7,:);
    data{j}.A_Y = l(1,:)./l(7,:);
    data{j}.A_Sum = l(7,:);
    data{j}.B_X = l(4,:)./l(8,:);
    data{j}.B_Y = l(2,:)./l(8,:);
    data{j}.B_Sum = l(8,:);
    data{j}.Mirror_X = l(5,:);
    data{j}.Mirror_Y = l(6,:);
    data{j}.time = (0:N-1)/fsamp;

    display(['Loaded ' rootfile{j}]);    
end
clear l;

