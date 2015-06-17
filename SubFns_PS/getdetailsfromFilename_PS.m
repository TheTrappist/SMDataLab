function [ANG SR ProtNum]=getdetailsfromFilename_PS(filename)
% Returns the angle of track rotation and sampling rate from the name of
% the file

firstANG=strfind(filename,'ANG')+3;
lastANG=strfind(filename,'_CH');
ANGlength=lastANG-firstANG;

negIND=1;

if ANGlength==6
    
    firstANG=firstANG+1;
    negIND=-1;
    
end

bigANG=str2num(filename(firstANG));
littleANG=str2num(filename(firstANG+2:firstANG+4));

angle=bigANG+littleANG/1000;

ANG=angle*negIND;

lastProtNum=strfind(filename,'PSDsignals')-1;
firstProtNum=strfind(fliplr(filename(1:lastProtNum)),'_');

ProtNum=str2num(filename(lastProtNum-firstProtNum+2:lastProtNum));

firstSR=strfind(filename,'_SR');
lastSR=strfind(filename,'NP');
SR=str2num(filename(firstSR+3:lastSR-1));