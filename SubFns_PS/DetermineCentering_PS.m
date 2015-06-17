function handles = DetermineCentering_PS(hObject, handles)
% Updates the handles structure to reflect the latest centering preferences
% handles.display.center: 0 = No centering, 1 = median, 2 = user values

% Written by Vladislav Belyy

MedianValues=(get(handles.MedianValues,'value'));
SelectValues=(get(handles.SelectValues,'value'));

if SelectValues
    handles.display.center = 2;
elseif MedianValues
    handles.display.center = 1;
else
    handles.display.center = 0;
end
    
% To get offset values run:
%Xoffset=str2double(get(handles.XOffset,'string'));
%Yoffset=str2double(get(handles.YOffset,'string'));


% Update handles structure
guidata(hObject, handles);