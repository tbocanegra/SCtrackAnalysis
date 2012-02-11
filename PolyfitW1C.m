%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% PloyfitW1C.m - G. Molera                       %
% Return the fit coeffs for the Weighted Polyfit %
% Input: tsp,FdetC,Weight,Npol                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Cp] = PolyfitW1C(x,y,w,np)
 nx = length(x);
 xx = max(x);
 xn = x/xx;
 
 Vp = zeros(1,np+1);
 Mp = zeros(np+1,np+1);
 
 for jp=1:np+1
     for jj=1:nx
         Vp(jp) = Vp(jp) + y(jj)*w(jj)*xn(jj)^(jp-1);
     end
     for ip=1:np+1
         for jj=1:nx 
             Mp(jp,ip) = Mp(jp,ip) + w(jj)*xn(jj)^(jp+ip-2);
         end
     end
 end
 Mr   = pinv(Mp);
 Cp   = Mr*Vp';
end
