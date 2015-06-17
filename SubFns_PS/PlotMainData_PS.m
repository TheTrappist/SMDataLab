function PlotMainData_PS(handles)
% Plots the main data

filename=get(handles.FileName,'string');
LongLog=get(handles.ShowX,'value'); % Plot x?
ShortLog=get(handles.ShowY,'value'); % plot y?

axes(handles.axes1)

% clear handles.axes1

plot(0,0)

hold on

if ShortLog==1 % Display 

plot(handles.currentdataT,handles.currentdataY,handles.currentstyleY)

end

if LongLog==1

plot(handles.currentdataT,handles.currentdataX,handles.currentstyleX)

end

xlabel(handles.currentXlabel);
ylabel(handles.currentYlabel);
title(filename,'Interpreter','none')

% Determine the legend
LogCase=2*LongLog+ShortLog;
if LogCase==1

    legend('Y')

elseif LogCase==2
    
    legend('X')
    
elseif LogCase==3
    
    legend('Y','X')
    
end

hold off