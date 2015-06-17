function [paras NewDir pathname]=GetConversionParameters_PS(Dir)

button = questdlg('Do you have the PSD conversion parameters on file?','Finding conversion parameters','Yes','No ','No ');

if button == 'Yes'
    
    filecat1=strcat(Dir,'*XResponse.txt');
        
    [filenameX, pathnameX, filterindex] = uigetfile(filecat1, 'Select the X-axis conversion file');
        

    
    filepathX=strcat(pathnameX,filenameX);
    
    filecat2=strcat(pathnameX,'*YResponse.txt');
    
    textX=textread(filepathX,'%s');
    size(textX,1);
    
    if size(textX,1)==5
        
        paras(1)=0;%ax0
    paras(2)=str2double(textX(4,:));%ax1
    paras(3)=0;%ax2
    paras(4)=str2double(textX(5,:));%ax3
    
    else
    
    paras(1)=str2double(textX(4,:));%ax0
    paras(2)=str2double(textX(5,:));%ax1
    paras(3)=str2double(textX(6,:));%ax2
    paras(4)=str2double(textX(7,:));%ax3
    
    end
    
    [filenameY, pathnameY, filterindex] = uigetfile(filecat2, 'Select the Y-axis conversion file');
    
        filepathY=strcat(pathnameY,filenameY);
    
    textY=textread(filepathY,'%s');
    
    pathname = pathnameY;
    
    if size(textY,1)==5
        
        paras(5)=0;%ax0
    paras(6)=str2double(textY(4,:));%ax1
    paras(7)=0;%ax2
    paras(8)=str2double(textY(5,:));%ax3
    
    else
    
    paras(5)=str2double(textY(4,:));%ax0
    paras(6)=str2double(textY(5,:));%ax1
    paras(7)=str2double(textY(6,:));%ax2
    paras(8)=str2double(textY(7,:));%ax3
    
    end

    
    NewDir=filepathY;%pathnameY;
    
else
    
    parastr=inputdlg({'x0' 'x1' 'x2' 'x3' 'y0' 'y1' 'y2' 'y3'},'Obtaining the conversion parameters',1,{'0' '7e-4' '0' '-1e-9' '0' '6e-4' '0' '-1e-9'});
    
    for i=1:8
    
    paras(i)=str2double(parastr(i));
    
    end
    
    NewDir=dir;

end


