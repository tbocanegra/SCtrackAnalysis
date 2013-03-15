%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% function_CheckSNR.m - G. Molera                %
% Return the SNR of a scan regarding its         %
% integration time								 %
% Input: filename                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [handles] = function_checkSNR(handles)
 FAvoid = 0.1e3;
 Fbw    = 10e3;
 Nfft   = handles.fftpoints/2+1;
 dt     = 1/(2*handles.BW);
 tw     = dt * handles.fftpoints;   % Time span of the FFT

 xf     = zeros(handles.Nspec,3);
 rmsd   = zeros(handles.Nspec,3);
 Snr(1:handles.Nspec) = 0;

 filename   = strcat(handles.SpectraPath,handles.SpectraInput);
 fprintf('File %s opened \n',filename);
 fid = fopen(filename);
 
 for k=1:handles.Nspec
      data = fread(fid,[Nfft 1],'float32');
      xf(k,:) = FindMax(data,handles.ff,handles.Fsmin,handles.Fsmax);
      rmsd(k,:) = GetRMS(data,handles.ff,xf(k,2)/tw,Fbw,FAvoid);
      SNR(k) = (xf(k,3)-rmsd(k,1))/rmsd(k,2);
 end
 
 fclose(fid);
 handles.SNR = SNR;
 fprintf ('SNR media: %s',mean(SNR))
end