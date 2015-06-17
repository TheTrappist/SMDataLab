function [ANG, SR, ProtNum]=GetDetailsFromFilename(filename)
% Determines the angle of track rotation and sampling rate from the
% name of the file

% Adapted from Tom Bilyard's original code by Vladislav Belyy
% Last modified on 11/22/2011

firstANG=strfind(filename,'ANG')+3;
lastANG=strfind(filename,'_CH');
ANGlength=lastANG-firstANG;

negIND=1;

if ANGlength==6
    
    firstANG=firstANG+1;
    negIND=-1;
    
end

bigANG=str2double(filename(firstANG));
littleANG=str2double(filename(firstANG+2:firstANG+4));

angle=bigANG+littleANG/1000;

ANG=angle*negIND;

if isnan(ANG) % If can't read angle, assign zero
    ANG = 0;
    disp('Could not read angle; assigning zero instead')
end

lastProtNum=strfind(filename,'.bin')-1;
firstProtNum=strfind(fliplr(filename(1:lastProtNum)),'_');

ProtNum=str2double(filename(lastProtNum-firstProtNum+2:lastProtNum));

firstSR=strfind(filename,'_SR');
lastSR=strfind(filename,'NP');
SR=str2double(filename(firstSR+3:lastSR-1));