%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% PloyfitW1.m - G. Molera                        %
% Creates a weighted polynomial fit to SNR       %
% Input: tsp,FdetC,Weight,Npol                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [yf] = PolyfitW1(x,y,w,np)
 nx = length(x);
 xx = max(x);
 xn = x/xx;

 Vp = zeros(1,np+1);
 Mp = zeros(np+1,np+1);
 yf = zeros(1,nx);

 for jp=1:np+1
	for jj=1:nx
		Vp(jp) = Vp(jp) + y(jj)*w(jj)*xn(jj)^(jp-1);
	end
	for ip=1:np+1
		for jj=1:nx 
			Mp(jp,ip) = Mp(jp,ip) + w(jj).*xn(jj).^(jp+ip-2);       
		end
	end
 end

 Mr = pinv(Mp);
 Cp = Mr*Vp';


 for jj=1:nx
	for jp=1:np+1
		yf(jj) = yf(jj) + Cp(jp)*xn(jj)^(jp-1);
	end
 end

end