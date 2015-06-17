function handles = FilterDataPS(hObject, handles)
% Returns data filtered in accordance with given method and parameters
% All filtered data is saved in handles.PSD1Data_Long_Filt and
% handles.PSD1Data_Short_Filt

tic % start timing

WindowLength=str2double(get(handles.WindowLength,'string'))/1000;
SR = handles.SamplingRate;

x = handles.PSD1Data_Long; % Long axis data
y = handles.PSD1Data_Short; % Short axis data

Med=get(handles.MedianFilter,'Value');
Run=get(handles.RunningMean,'Value');
Butt=get(handles.Butterworth,'Value');
L1PWC=get(handles.L1PWC,'Value');
%         CurrentSelection='4: Filtered'
%         PrevSelection=handles.Ytype
%         PrevScale=handles.Yaxis

if Med %Median filtered
    FilteredX=medfilt1(x,WindowLength*SR);
    FilteredY=medfilt1(y,WindowLength*SR);
 
elseif Run % Running mean filter
    FilteredX=filter(ones(1,WindowLength*SR)/(WindowLength*SR),1,x);
    FilteredY=filter(ones(1,WindowLength*SR)/(WindowLength*SR),1,y);

elseif Butt % Butterworth filter
    CutoffFreq=str2double(get(handles.CutoffFreq,'string'))*2/SR;
    FilterOrder=str2double(get(handles.FilterOrder,'string'));
    [b,a] = butter(FilterOrder,CutoffFreq,'low');
    FilteredX=filter(b,a,x);
    FilteredY=filter(b,a,y);

elseif L1PWC % L1 piecewise-constant filter
    lambda=str2double(get(handles.lambda,'string'));
    FilteredX=l1tf_integ(x',lambda);
    FilteredY=l1tf_integ(y',lambda);

else
    FilteredX=x;
    FilteredY=y;

end

% save data
handles.PSD1Data_Long_Filt = FilteredX;
handles.PSD1Data_Short_Filt = FilteredY;

filteringTime = toc; % end timing
disp(['Filtered in ', num2str(filteringTime), ' seconds']);

% Save the handles structure.
guidata(hObject,handles)