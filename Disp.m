%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% Disp.m - G. Molera                             %
% Checks for anomalous dispersion                %
% Input: Spectra + Average spectrum              %
% Output: One spectrum vector                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dout] = Disp(Spectra,Avspectrum)
 sizenc = size(Spectra);
 nd = sizenc(1);
 nc = sizenc(2);
 disp(1:nc)=0;
 for jc=1:nd
	for jj=1:nc
		disp(jj) = disp(jj) + (Spectra(jc,jj) - Avspectrum(jj))^2;
	end
 end

 dout = disp./nd;
end