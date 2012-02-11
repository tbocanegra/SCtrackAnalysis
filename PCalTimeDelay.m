%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% PCalTimeDelay.m - G. Molera                    %
% Analyse Time Delay of the PCal signal in a scan%
% Input: .pcal file extracted from swspectrometer%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out] = PCalTimeDelay(fileName)
 IntegrationTime= 10 ;
 RecordedTime = 1140 ;
 NumSpec = RecordedTime/IntegrationTime;
 NumPCal = NumSpec * 8 * 2;
 TimeDelay(NumSpec/2)= 0;
 fs = 16e6;

 % Read one of the .spec.pcal
 fid=fopen(fileName);
 printf('reading %s \n',fileName)
 
 % Complex data
 pcal_complex = fread(fid,[NumPCal 2],'float32');
 pcal = complex(pcal_complex(:,1),pcal_complex(:,2));

 for i=1:NumSpec/2
  tmp = FindMax(pcal,1:NumPCal,(i-1)*NumPCal*2/NumSpec +1,i*NumPCal*2/NumSpec);
  TimeDelay(i) =(tmp(2)-tmp(1))/fs*1e9;
 end;
 
 out = TimeDelay;
end