function [Xlim, Ylim, handles]=SaveYScale_PS(handles, str, val,method)

%method=1 for PS, =0 for Data display

ANG=handles.TrackAngle;

switch str{val};
    case 'Dimensionless PSD units' % User selects peaks
        handles.currentdataX=handles.Sx;
        handles.currentdataY=handles.Sy;
        handles.currentdataT=handles.t;
        handles.currentYlabel='PSD signal (dimensionless units)';
        if method==0
            set(handles.SaveFile,'Visible','off')
            set(handles.GridDiv,'string','0.02 units')
        end
        CurrentSelection='1: PSD signal'
        PrevSelection=handles.Ytype;
        PrevScale=handles.Yaxis;
    case 'Force (pN)' % User selects peaks
        
        M=[cos(-ANG) sin(-ANG); -sin(-ANG) cos(-ANG)];  % Re-rotate signals
        
        X=handles.X-handles.Flong;
        Y=handles.Y-handles.Fshort;
        
        S=[X;Y];

        D=M*S;

        x=D(1,:);
        y=D(2,:);
        
        Xforce=x*handles.KX;
        Yforce=y*handles.KY;
        
        SS=[Xforce;Yforce];
        
        MM=[cos(ANG) sin(ANG); -sin(ANG) cos(ANG)];
        
        DD=MM*SS;

        ForceXX=DD(1,:);
        ForceYY=DD(2,:);
        
        handles.currentdataX=ForceXX;
        handles.currentdataY=ForceYY;
        
%         handles.currentdataX=handles.KX*(handles.X-handles.Flong);%handles.ForceX;
%         handles.currentdataY=handles.KY*(handles.Y-handles.Fshort);%handles.ForceY;
        handles.currentdataT=handles.t;
        handles.currentYlabel='Force (pN)';
        if method==0
            set(handles.SaveFile,'Visible','on')
            set(handles.SaveFile,'string','Save Force (t,Fx,Fy) File')
            set(handles.GridDiv,'string','0.5 pN')
        end
        CurrentSelection='2: Force'
        PrevSelection=handles.Ytype;
        PrevScale=handles.Yaxis;
    case 'nm and rotated' % User selects membrane
        handles.currentdataX = handles.X;
        handles.currentdataY = handles.Y;
        handles.currentdataT=handles.t;
        handles.currentYlabel='position (nm)';
        if method==0
            set(handles.SaveFile,'Visible','on')
            set(handles.SaveFile,'string','Save t,X,Y File')
            set(handles.GridDiv,'string','8 nm')
        end
        CurrentSelection='3: nm and rotated'
        PrevSelection=handles.Ytype;
        PrevScale=handles.Yaxis;
    case 'Filtered'
%         paras.WindowLength=str2num(get(handles.WindowLength,'string'))/1000;
%         paras.CutoffFreq=str2num(get(handles.CutoffFreq,'string'))*2/handles.SR;
%         paras.FilterOrder=str2num(get(handles.FilterOrder,'string'));
%         Med=get(handles.MedianFilter,'Value');
%         Run=get(handles.RunningMean,'Value');
%         Butt=get(handles.Butterworth,'Value');
%         CurrentSelection='4: Filtered'
%         PrevSelection=handles.Ytype
%         PrevScale=handles.Yaxis
% 
%         if Med==1
% 
%             meth='median filter';
% 
%         end
% 
%         if Run==1
% 
%             meth='running mean';
% 
%         end
% 
%         if Butt==1
% 
%             meth='butterworth';
% 
%         end
%         
%         handles.Yaxis
%         
%         if handles.Ytype~=4
%             currently='filtering'
%         [handles.currentdataX sometime]=FilterStallData(handles.currentdataT,handles.currentdataX,paras,handles.SR,meth);
%         [handles.currentdataY handles.currentdataT]=FilterStallData(handles.currentdataT,handles.currentdataY,paras,handles.SR,meth);
%         end
%         
%         val=handles.Yaxis
        
end



Xlim=get(handles.axes1,'Xlim');
Ylim=get(handles.axes1,'Ylim');

Kx=str2num(get(handles.Kx,'string'));
Ky=str2num(get(handles.Ky,'string'));

if method==0
    
OldAxis=handles.Yaxis;
if OldAxis==1
    
    handles.ax1;
    handles.ay1;
    
    if val==2
        
        me=Kx;
        
        Yar=[Ylim(1)*Kx Ylim(2)*Kx Ylim(1)*Ky Ylim(2)*Ky];
        
        Ylimnew=[min(Yar) max(Yar)];
        
    elseif val==1
        
        Ylimnew=Ylim;
        
    else
        
        Ylimnew=handles.YlimOut*mean([handles.ax1 handles.ay1]);
        
    end
    
elseif OldAxis==2

    if val==1
        
        Yar=[Ylim(1)/Kx Ylim(2)/Kx Ylim(1)/Ky Ylim(2)/Ky];
        
        Ylimnew=[min(Yar) max(Yar)] ;
        
    elseif val==2
        
        Ylimnew=Ylim;
        
    else
        
        Ylimnew=handles.YlimOut*mean([handles.ax1 handles.ay1]);
        
    end
    
elseif OldAxis==3

        
%         ax=[handles.ax1 0 handles.ax3]
%         ay=[handles.ay1 0 handles.ay3]

% 
%         cd SubFns
% 
%         Ylimn1=convertPSD2position_PS(Ylim,ax);
%         Ylimn2=convertPSD2position_PS(Ylim,ay);
%         
%         cd ..
            
%     if val==1
%         
%         Yar=[Ylim(1)/handles.ax1 Ylim(2)/handles.ax1 Ylim(1)/handles.ay1 Ylim(2)/handles.ay1];
%         
%         Ylimnew=[min(Yar) max(Yar)] 
%         
%     elseif val==2
%         
%         Yar=[Ylim(1)/handles.ax1*Kx Ylim(2)/handles.ax1*Kx Ylim(1)/handles.ay1*Ky Ylim(2)/handles.ay1*Kx];
%         
%         Ylimnew=[min(Yar) max(Yar)] 
%         
%     else
%         
%         Ylimnew=Ylim
%         
%     end

    if val==2
        
        me=handles.YlimOut;
        
        Yar=[me(1)*Kx me(2)*Kx me(1)*Ky me(2)*Ky]
        
        Ylimnew=[min(Yar) max(Yar)];
        
    elseif val==3
        
        Ylimnew=Ylim;
        
    else
        
        Ylimnew=handles.YlimOut;%/mean([handles.ax1 handles.ay1])
        
    end
        
    
else
    
%     Ylimnew=Ylim
    Ylimnew=handles.YlimOut;
    
end

Ylim=Ylimnew;

end