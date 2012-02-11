%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% ChePolyfitW.m - G. Molera                      %
% Calculates a Weighted Chebyshev approximation  %
% input: vec1, vec2, weight vector, Num. Polys   %
% output: vector approximation                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dout] = ChePolyfitW(x,y,w,np)

 nx = length(x);
 xx = max(x);
 xy = min(x);
 xc = 0.5*(xx+xy);
 xa = 0.5*(xx-xy);
 xn = (x-xc)/xa;         % Xn = but normalized according (x-xc)/xa

 Vp(1:np+1)=0;
 Mp=zeros(np+1);
 yf(1:nx)=0;

 for ii=1:np+1
	tmpTcheb = 0;
	for jj=1:nx
		tmpTcheb = tmpTcheb + Tcheb(ii,xn(jj)).*y(jj).*w(jj);
	end
	Vp(ii) = tmpTcheb;
	for kk=1:np+1
		tmpTcheb = 0;
		for jj=1:nx
			tmpTcheb = tmpTcheb + Tcheb(ii,xn(jj)).*Tcheb(kk,xn(jj)).*w(jj);
		end
		Mp(ii,kk) = tmpTcheb;
	end
 end

 Mr = Mp^(-1);
 Cp = Mr*Vp';

 for jj=1:nx
	tmpTcheb = 0;
	for ii=1:np+1
		tmpTcheb = tmpTcheb + Cp(ii)*Tcheb(ii,xn(jj));
	end
	yf(jj)= tmpTcheb;
 end

 dout = yf;
end