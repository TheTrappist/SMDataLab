function handles = GetNewConversionParams(hObject, handles)
% Prompts the user to input new PSD conversion parameters and updates the
% handles structure accordingly

% Adapted from Tom Bilyard's original code by Vladislav Belyy
% Last modified on 11/22/2011

loadError = 0; % Returns a 1 at the end if coefficients didn't load 
% properly (e.g. user hit cancel at some point)

button = questdlg('Do you have the PSD conversion parameters on file?', ...
    'Finding conversion parameters','Yes','No','No');

if strcmp(button, 'Yes') % Coefficients are stored in a file 
    
    try
        currPath = get(handles.FilePath,'string');
        
        %filecat1=strcat(handles.currentPath,'*XResponse.txt');
        filecat1=strcat(currPath,'*XResponse.txt');
        
        [filenameX, pathnameX, filterindex] = uigetfile(filecat1, ...
            'Select the X-axis conversion file'); %#ok
        
        warning('off', 'all')         
        filepathX=strcat(pathnameX,filenameX);
        
        
        filecat2=strcat(pathnameX,'*YResponse.txt');
        
        textX=textread(filepathX,'%s');
        
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
        
        warning('on', 'all')
        
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
        
        
        NewDir=pathnameY; %pathnameY;
        
    catch ME1 %#ok<NASGU>
        loadError = 1;
    end
    
elseif strcmp(button, 'No')
    
    parastr=inputdlg({'x0' 'x1' 'x2' 'x3'...
        'y0' 'y1' 'y2' 'y3'}, ...
        'Obtaining the conversion parameters', ...
        1,{'0' '7e-4' '0' '-1e-9' '0' ...
        '6e-4' '0' '-1e-9'});
    
    try
        for i=1:8
            paras(i)=str2double(parastr(i)); %#ok<AGROW>
        end
    catch ME1 %#ok<NASGU>
        loadError = 1;
    end
  
     
    NewDir=get(handles.FilePath,'string');


else 
    loadError = 1;
end



if ~loadError
    handles.currentPath=NewDir;
    set(handles.FilePath,'string', NewDir);
    
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
    
end
% Update handles structure
guidata(hObject, handles);