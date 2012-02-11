%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% FindMax.m - G. Molera                          %
% find the Cpp coefficients from the spectra     %
% the basic spectra                              %
% Input: spectrum, frequency scale, search       % 
%        windows defined by max and min          % 
% Output: bin of max value, bin parabolic        %
%        estimate of max position, max value     % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function [out] = FindMax(Spec,Fscale,Fmin,Fmax)
 np = length(Spec);
 mx = 0;
 jmax = 1;
 for jj =1:np
	if (Spec(jj) > mx && Fmin < Fscale(jj) && Fscale(jj) < Fmax)
		mx = Spec(jj);  % max value from the spectra
		jmax = jj;      % return position on the vector of the max value.
	end
 end
 if (jmax == 1)
	jmax = 2;
 end
 if (jmax == np)
	jmax = np-1;
 end
 a1 = 0.5*(Spec(jmax+1) - Spec(jmax-1));
 a2 = 0.5*(Spec(jmax+1) + Spec(jmax-1) - 2*Spec(jmax));
 djx = -a1/(2*a2);
 
 xmax = jmax + djx;
 out = cat(1,jmax,xmax,mx);
end