function data = ReadFile(fsamp,startpath,file);
% data = ReadFile(fsamp,path,file)
%
% Reads binary data file(s), and outputs to structure cell array "data". 
% fsamp = sampling rate, path = pathname, file = filename cell array.
%

global rawDataPath

if ~exist('fsamp') | (exist('fsamp') & isempty(fsamp))
    param = getnumbers('Enter sampling frequency:',{'fsamp (Hz)'},{'500'});
    fsamp = param(1);
end;    

if nargin <= 1
    if ~isempty(rawDataPath)
        startpath = [rawDataPath '\'];
    else
    startpath = [pwd '\'];
    end
end;    
if nargin < 3
    [file, currentpath] = uigetfile([startpath '*.dat'], 'MultiSelect', 'on');
    startpath = currentpath;
end;

if ~iscell(file)
    ind2 = 1;
    temp = file;
    file = cell(1, 1);
    file{1} = temp;
    clear temp;
else
    [ind1, ind2] = size(file);
end

data = cell(1, ind2);

header = 0;

% Parse data
for j=1:ind2
    display(['Loading ' file{j}]);
    data{j}.path = startpath;
    data{j}.file = file{j};
    data{j}.date = date;

    h = fopen([startpath file{j}]);
    m = fread(h,1e10,'float32','ieee-be');
    %n=m((1+header):(size(m)-header));
    l = reshape(m,8,length(m)/8);
    
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

    clear m;
    clear l;
    fclose(h); 
end


