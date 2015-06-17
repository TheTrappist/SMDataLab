function handles = BuildCurrentPSDData(handles)
% Rotates PSD1 signal along the axoneme track and converts the signal to
% nanometers. 

% Written by Vladislav Belyy
% Last updated on 11/19/2013


% Read the polynomial coefficients used to convert raw PSD signals to
% nanometers

AODxCoeffs = [0 0 0 0];
AODxCoeffs(1)=str2double(get(handles.x_Trap1_0,'string'));
AODxCoeffs(2)=str2double(get(handles.x_Trap1_1,'string'));
AODxCoeffs(3)=str2double(get(handles.x_Trap1_2,'string')); 
AODxCoeffs(4)=str2double(get(handles.x_Trap1_3,'string')); 
 
AODyCoeffs = [0 0 0 0];
AODyCoeffs(1)=str2double(get(handles.y_Trap1_0,'string'));
AODyCoeffs(2)=str2double(get(handles.y_Trap1_1,'string'));
AODyCoeffs(3)=str2double(get(handles.y_Trap1_2,'string'));
AODyCoeffs(4)=str2double(get(handles.y_Trap1_3,'string'));

PiezoxCoeffs = [0 0 0 0];
PiezoxCoeffs(1)=str2double(get(handles.x_Trap2_0,'string'));
PiezoxCoeffs(2)=str2double(get(handles.x_Trap2_1,'string'));
PiezoxCoeffs(3)=str2double(get(handles.x_Trap2_2,'string')); 
PiezoxCoeffs(4)=str2double(get(handles.x_Trap2_3,'string'));

PiezoyCoeffs = [0 0 0 0];
PiezoyCoeffs(1)=str2double(get(handles.y_Trap2_0,'string'));
PiezoyCoeffs(2)=str2double(get(handles.y_Trap2_1,'string'));
PiezoyCoeffs(3)=str2double(get(handles.y_Trap2_2,'string'));
PiezoyCoeffs(4)=str2double(get(handles.y_Trap2_3,'string'));


filename = get(handles.FileName,'string');
[~, ~, extension]= fileparts(filename); 
if strcmp(extension, '.bin') % binary file
    %get angle of rotation and sampling rate from filename
    [ANG SR ProtNum]=GetDetailsFromFilename(filename); %#ok
    
    handles.trackAngle=ANG;
elseif strcmp(extension, '.ytd') % ytd file
    ANG = handles.trackAngle;
end
    


% Convert traces to nm and rotate along track
for i=1:length(handles.allTraces)
    validTrace = 1;
    if strcmp(handles.allTraces(i).TraceName, 'PSD1 X')
        X = ConvertPSD2position(...
            handles.allTraces(i).DataRaw,AODxCoeffs(2:4));
        Y = ConvertPSD2position(...
            handles.allTraces(i+1).DataRaw,AODyCoeffs(2:4));
    elseif strcmp(handles.allTraces(i).TraceName, 'PSD2 X')
        X = ConvertPSD2position(...
            handles.allTraces(i).DataRaw,PiezoxCoeffs(2:4));
        Y = ConvertPSD2position(...
            handles.allTraces(i+1).DataRaw,PiezoyCoeffs(2:4));
    elseif strcmp(handles.allTraces(i).TraceName, 'AOD Trap X')
        conversion = str2double(get(handles.AODnmMHz,'string'));
        X = conversion * handles.allTraces(i).DataRaw;
        Y = conversion * handles.allTraces(i+1).DataRaw;
    elseif strcmp(handles.allTraces(i).TraceName, 'Piezo Trap X')
        conversion = str2double(get(handles.PiezoNmVolts,'string'));
        X = conversion * handles.allTraces(i).DataRaw;
        Y = conversion * handles.allTraces(i+1).DataRaw;
    else
        validTrace = 0;
    end
    
    if validTrace
        % generate rotation matrix:
        M=[cos(ANG) sin(ANG);-sin(ANG) cos(ANG)]; 
        signalRotated = M*[X';Y']; % Rotate the signal along the track
        
        handles.allTraces(i).Data_nm = signalRotated(1,:)';
        handles.allTraces(i+1).Data_nm = signalRotated(2,:)';
    end

end

