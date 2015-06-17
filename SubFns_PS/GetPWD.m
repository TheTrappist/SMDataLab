function [NoPWD PWD]=GetPWD(Data,DeltaTOffset,DeltaTStep)

        NoPWD=0;
        
        PWD=[0];
        
        NP=length(Data);
        
%         StallDataWind=StallDataX((WindowNumber-1)*WindowSize+1:WindowNumber*WindowSize);
        
        for Delta=DeltaTOffset:DeltaTStep:NP/2          %Loops through the Delta(t)
            
%             Delta;
%             
%             DiffData=[0];
%             DiffArray=[0];
%             NewDiffData=[0];

            
%                DiffData=reshape(Data(1:Delta*floor(NP/Delta)),Delta,floor(NP/Delta));
%                
%                DiffArray=DiffData(:,2:end)-DiffData(:,1:end-1);
%                
%                NewDiffData=reshape(DiffArray,1,size(DiffArray,1)*size(DiffArray,2));
%                
%                PWD(NoPWD+1:NoPWD+length(NewDiffData))=NewDiffData;
%                
%                NoPWD=NoPWD+length(NewDiffData);

                DiffData=downsample(Data,Delta);
                
                NewDiffData=DiffData(2:end)-DiffData(1:end-1);
                
               PWD(NoPWD+1:NoPWD+length(NewDiffData))=NewDiffData;
               
               NoPWD=NoPWD+length(NewDiffData);
               

        end
        
        NoPWD;
        
        PWD;
