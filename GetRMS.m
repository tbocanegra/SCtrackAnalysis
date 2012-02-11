%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% GetRMS.m - G. Molera                           %
% Gets the mean and RMS value in a set window    %
% Input: Spectra,freq scale,freq window,         %
% 		 line to avoid                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out] = GetRMS(Spec,Fscale,Fline,Fspan,Fvoid)
 np = length(Spec);
 mw = 0;
 ww = 0;
 dw = 0;
 for jj=1:np
	if ((abs(Fscale(jj)-Fline) > Fvoid) && (abs(Fscale(jj)-Fline) < Fspan))
		ww = ww + 1;
		mw = mw + Spec(jj);
	end
 end
 mm = mw/ww;
 for jj=1:np
	if (abs(Fscale(jj)-Fline) > Fvoid) && (abs(Fscale(jj)-Fline) < Fspan)
		dw = dw + (Spec(jj)-mm).^2;
	end    
 end
 rm  = sqrt(dw/ww);
 out = cat(1,mm,rm,ww);
end