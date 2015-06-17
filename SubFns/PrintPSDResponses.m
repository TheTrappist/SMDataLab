function PrintPSDResponses( dirName )
% PrintPSDResponses finds all PSD response files (with names ending in
% _XResponse.txt and _Yresponse.txt) in the specified directory and prints
% the corresponding parameters to Matlab's command window
%
% Written by Vladislav Belyy
% Last modified on 1/2/2012

xResponseFiles = dir([dirName,'\*_XResponse.txt']);
yResponseFiles = dir([dirName,'\*_YResponse.txt']);

allResponses = [xResponseFiles; yResponseFiles];


fileNames = {};

for i=1:length(allResponses)
    fileNames = [fileNames; allResponses(i).name];%#ok<AGROW>
end

fileNames = sort(fileNames);

for i=1:length(fileNames)
    fileID = fopen([dirName,'\',char(fileNames(i))]);
    fileContents = textscan(fileID,'%s','delimiter','\n'); % read file
    
    %Process filenames:
    scanAxisStr = fileContents{1}{1}; % String containing axis
    coeffsNum = str2double(fileContents{1}(2:5)); % numerical coefficients
    coeffs = cellstr(num2str(coeffsNum,'%2.2e'));
    coeffs = [coeffs{1}, '; ', coeffs{2}, '; ', coeffs{3}, '; ', ...
        coeffs{4}];
    disp(char(fileNames(i)));
    disp(' ');
    disp(scanAxisStr);    
    disp(coeffs);
    disp(' ');
    fclose(fileID);
end
    
    

%fileList = char(fileList);