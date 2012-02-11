%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% CheckSNR.m - G. Molera                         %
% Return the SNR of a scan regarding its         %
% integration time								 %
% Input: filename                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out] = checkSNR(fileName)
 fftpoints = 1.6e6;			% Number of FFTs
 Fmin = 3.4e6/5;			% Set a frequency range around the PCal signal
 Fmax = 3.8e6/5;			% Fmin and Fmax	
 FAvoid = 0.1e3;			% Freq margin respect PCal 
 Fbw =  2e4;				% noise bw to check SNR
 Nspec = 227;				% Number of sub-scans 
 Nfft = fftpoints/2+1;
 fs = 1:Nfft;
 BW = 8e6;
 dt = 1/(2*BW);
 tw = dt * fftpoints; 		% Time span of the FFT
 Padd = 2;
 dfs = 1/(tw*Padd);

 xf = zeros(Nspec,3);
 rmsd = zeros(Nspec,3);
 Snr(1:Nspec) = 0;

 fprintf('File %s opened \n',fileName);
 fid = fopen(fileName);

 for k=1:Nspec;
	data = fread(fid,[Nfft 1],'float32');
	xf(k,:) = FindMax(data,fs,Fmin,Fmax);
	rmsd(k,:) = GetRMS(data,fs,xf(k,2),Fbw,FAvoid);
	SNR(k) = (xf(k,3) - rmsd(k,2))/rmsd(k,1);
 end

 fprintf ('SNR media:  %d', mean(SNR));
 out = SNR;
end
