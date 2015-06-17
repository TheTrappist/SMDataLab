function XYPath=nameXYfilefromPSDsignals_PS(PSDpath,method,FilterLogic)

TxtInd=regexpi(PSDpath,'.txt');

TruncPath=PSDpath(1:TxtInd-1);

PSDSigPath=regexpi(TruncPath,'PSDsignals');

OrigPath=TruncPath(1:PSDSigPath-1);

method2=method;

size(method);

if FilterLogic==1

    switch method2

        case 'nm and rotated'

            XYPath=strcat(OrigPath,'_XY_GUI_FILTERED.txt');

        case 'Force (pN)'

            XYPath=strcat(OrigPath,'_Force_GUI_FILTERED.txt');

        case 'Power Spectrum'

            XYPath=strcat(OrigPath,'_PowerSpectrum_GUI_FILTERED.txt');

        case 'Stalls'

            XYPath=strcat(OrigPath,'_Stalls_FILTERED.mat');

        otherwise

            XYPath='';


    end

else
    
    switch method2

        case 'nm and rotated'

            XYPath=strcat(OrigPath,'_XY_GUI.txt');

        case 'Force (pN)'

            XYPath=strcat(OrigPath,'_Force_GUI.txt');

        case 'Power Spectrum'

            XYPath=strcat(OrigPath,'_PowerSpectrum_GUI.txt');

        case 'Stalls'

            XYPath=strcat(OrigPath,'_Stalls.mat');

        otherwise

            XYPath='';


    end
    
end
    
