function handles = GetNewConversionParams_PS(hObject, handles)
% Prompts the user to input new PSD conversion parameters and updates the
% handles structure accordingly

button = questdlg('Do you have the PSD conversion parameters on file?','Finding conversion parameters','Yes','No ','No ');

if strcmp(button, 'Yes') % Coefficients are stored in a file 
    
    currPath = get(handles.FilePath,'string');
    
    %filecat1=strcat(handles.currentPath,'*XResponse.txt');
    filecat1=strcat(currPath,'*XResponse.txt');
        
    [filenameX, pathnameX, filterindex] = uigetfile(filecat1, ...
                                'Select the X-axis conversion file'); %#ok
        

    
    filepathX=strcat(pathnameX,filenameX);
    
    filecat2=strcat(filepathX);
    
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
    
    [filenameY, pathnameY, filterindex] = uigetfile(filecat2, ...
                        'Select the Y-axis conversion file'); %#ok
    
        filepathY=strcat(pathnameY,filenameY);
    
    textY=textread(filepathY,'%s');
    
    if size(textY,1)==5
        
        paras(5)=0;%ax0
    paras(6)=str2double(textY(4,:));%ax1
    paras(7)=0; %ax2
    paras(8)=str2double(textY(5,:)); %ax3
    
    else
    
    paras(5)=str2double(textY(4,:)); %ax0
    paras(6)=str2double(textY(5,:)); %ax1
    paras(7)=str2double(textY(6,:)); %ax2
    paras(8)=str2double(textY(7,:)); %ax3
    
    end

    
    NewDir=filepathY; %pathnameY;
    
else
    
    parastr=inputdlg({'x0' 'x1' 'x2' 'x3' 'y0' 'y1' 'y2' 'y3'},'Obtaining the conversion parameters',1,{'0' '7e-4' '0' '-1e-9' '0' '6e-4' '0' '-1e-9'});
    
    for i=1:8
    
    paras(i)=str2double(parastr(i));
    
    end
    
    NewDir=dir;

end


handles.currentPath=NewDir;

% Display the newly acquired parameters
set(handles.x0,'string',num2str(paras(1),'%0.2e'))
set(handles.x1,'string',num2str(paras(2),'%0.2e'))
set(handles.x2,'string',num2str(paras(3),'%0.2e'))
set(handles.x3,'string',num2str(paras(4),'%0.2e'))
set(handles.y0,'string',num2str(paras(5),'%0.2e'))
set(handles.y1,'string',num2str(paras(6),'%0.2e'))
set(handles.y2,'string',num2str(paras(7),'%0.2e'))
set(handles.y3,'string',num2str(paras(8),'%0.2e'))

%Update the conversion parameters in handles
handles.ax1=str2double(get(handles.x1,'string')); 
handles.ax3=str2double(get(handles.x3,'string')); 
handles.ax0=str2double(get(handles.x0,'string')); 
handles.ax2=str2double(get(handles.x2,'string')); 
handles.ay1=str2double(get(handles.y1,'string')); 
handles.ay3=str2double(get(handles.y3,'string'));
handles.ay0=str2double(get(handles.y0,'string'));
handles.ay2=str2double(get(handles.y2,'string'));

% Update handles structure
guidata(hObject, handles);