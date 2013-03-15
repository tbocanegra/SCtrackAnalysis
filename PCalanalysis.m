%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% PCalanalysis.m - G. Molera                     %
% Analyse Pulse Delay from the PCal signal of    %
% several scans                                  %
% Input: filename and path of all PCal files     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out] = PCalanalysis(filename,path)
 Nscan = 6;
 fftpoints=1600e3;
 Nfft=fftpoints/2 + 1;
 IntegrationTime= 10 ;
 RecordedTime = 1140 ;
 NumSpec = RecordedTime/IntegrationTime;
 Spec(1:Nfft) = 0;

 Fmin = 90000;
 Fmax =110000;
 Fscale = 1:Nfft;

 % Read from a file the files and names available.

 printf('opening the file: %s where all pcal scan files are detailed for a session \n',filename)
 fid=fopen(filename);

 for k=1:Nscan
  fname(k).fn = strcat(path,fgetl(fid));
 end
 
 fclose(fid); 
 fprintf ('We take all the recorded scans for one day\n and we append all in same array.\n');

 NumPCalSamples = Nscan*(NumSpec-1);
 PCalTime(1:NumPCalSamples)= 0 ;
 PulseDelay(1:NumPCalSamples)= 0;
 tmp = 0;

 for k=1:Nscan
	fid = fopen(fname(k).fn,'rb');
	fprintf('File: %s opened \n', fname(k).fn);
	for i=1:NumSpec-1
		Spec = fread(fid, [Nfft 1], 'float32');
		tmp = FindMax(Spec,Fscale,Fmin,Fmax);
		PulseDelay((k-1)*(NumSpec-1)+1) =tmp(1);
		PCalTime((k-1)*(NumSpec-1)+i) = tmp(3);
	end
	fclose(fid);
 end

 out(:,1) = PCalTime;
 out(:,2) = PulseDelay;

 figure(1);plot(PCalTime);
 figure(2);plot(PulseDelay);

end
