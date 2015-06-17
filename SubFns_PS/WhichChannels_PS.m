function ChannelLogic=WhichChannels_PS(filename)
% Extracts channel information from a trap data file name and returns it as
% an array of four 1's and 0's in the following order:
% 1) PSD1, 2) PSD2, 3) Trap position, 4) BrightField logic


ChLoc=strfind(filename,'_CH');

ChannelLogicStr=filename(ChLoc+3:ChLoc+6);

for i=1:4;
    
    if strcmp(ChannelLogicStr(i),'t')
        
        ChannelLogic(i)=1;
        
    else
        
        ChannelLogic(i)=0;
        
    end
    
end