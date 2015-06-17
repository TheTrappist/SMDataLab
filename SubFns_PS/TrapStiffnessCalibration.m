function TrapStiffnessCalibration

[X Y Fx Fy filename]=GetDataFromFile_PS();

[ANG SR ProtNum]=getdetailsfromFilename_PS(filename);

t=1/SR:1/SR:length(X)/SR;

plot(t,X,'b',t,Y,'r')