%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% CheckSCsignal.m - G. Molera                    %
% Return the power level of the SC signal        %
% integration time								 %
% Input: filename                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SClevel] = checkSCsignal(fileName)
 fftpoints = 3.2e6;			% Number of FFTs
 Fmin = 270e3;				% Set a frequency range around the SC signal
 Fmax = 290e3;				% Fmin and Fmax	
 FAvoid = 1e4;				% Freq margin respect PCal 
 Fbw = 3e4;					% noise bw to check SNR
 Nspec = 114;				% 87. Number of sub-scans 
 Nfft = fftpoints/2+1;
 fs = 1:Nfft;
 BW = 8e6;
 dt = 1/(2*BW);
 tw = dt * fftpoints; 		% Time span of the FFT
 Padd = 2;
 dfs = 1/(tw*Padd);

 SCsignal = zeros(Nspec,3);
 rmsd     = zeros(Nspec,2);
 SClevel(1:Nspec) = 0;

 fprintf('File %s opened \n',fileName);
 fid = fopen(fileName);

 for k=1:Nspec
	data         = fread(fid,[Nfft 1],'float32');
	semilogy(data,'b');pause(0.5);
	SCsignal(k,:)= FindMax(data,fs,Fmin,Fmax);
	rmsd(k,:)    = GetRMS(data,fs,SCsignal(k,2),Fbw,FAvoid);
	SClevel(k)  = (SCsignal(k,3) - rmsd(k,1))/rmsd(k,2);
 end

 fprintf ('SNR media: %f',mean(SClevel));
end