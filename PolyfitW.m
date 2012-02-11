%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% PolyfitW.m - G. Molera                         %
% Calculates the polynomials fit                 %
% input: vector, weight vector, Num. Polys       %
% output: vector approximation                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [yf] = PolyfitW(x,y,w,np)

 nx = length(x);
 xx = max(x);
 xy = min(x);
 xc = 0.5*(xx+xy);
 xa = 0.5*(xx-xy);
 xn = (x-xc)./xa ;       % Xn = but normalized according (x-xc)/xa

 Vp = zeros(1,np+1);
 Mp = zeros(np+1);
 yf = zeros(1,nx);

 for jp=1:np+1
	for jj=1:nx
		Vp(jp) = Vp(jp) + y(jj).*w(jj).*(xn(jj)^(jp-1));
	end
	for ip=1:np+1
		for jj=1:nx
			Mp(jp,ip) = Mp(jp,ip) + w(jj).*(xn(jj).^(jp+ip-2));       
		end
	end
 end

 Mr = pinv(Mp);
 Cp = Mr*Vp';
 
 for jj=1:nx
	for jp=1:np+1
		yf(jj) = yf(jj) + Cp(jp).*(xn(jj)^(jp-1));
	end
  end

end