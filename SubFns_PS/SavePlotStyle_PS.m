function [Xlim Ylim handles]=SavePlotStyle_PS(handles,val,str)

switch str{val};
case 'Dots' % User selects peaks
   handles.currentstyleX='b.';
   handles.currentstyleY='r.';
case 'Lines' % User selects membrane
   handles.currentstyleX = 'b-';
   handles.currentstyleY = 'r-';
end

Xlim=get(handles.axes1,'Xlim');
Ylim=get(handles.axes1,'Ylim');