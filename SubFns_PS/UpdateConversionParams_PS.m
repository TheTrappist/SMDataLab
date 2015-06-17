function UpdateConversionParams_PS(hObject, handles)
% Reads the current PSD conversion parameters and writes them to the
% variables ax0, ax1... etc. in the handles structure.

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