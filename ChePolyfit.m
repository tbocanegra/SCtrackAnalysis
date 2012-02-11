%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% ChePolyfit.m - G. Molera                       %
% Calculates a Chebyshev approximation to data   %
% input: vector, weight vector, Num. Polys       %
% output: vector approximation                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dout] = ChePolyfit(x,y,np)

 nx = length(x);
 xx = max(x);
 xy = min(x);
 xc = 0.5*(xx+xy);
 xa = 0.5*(xx-xy);
 xn = (x-xc)/xa;         % Xn = but normalized according (x-xc)/xa

 for ii=1:np+1
	tmpTcheb = 0;
	for jj=1:nx
		tmpTcheb = tmpTcheb + Tcheb(ii,xn(jj))*y(jj);
	end
    
	Vp(ii) = tmpTcheb;    

    for kk=1:np+1
		tmpTcheb = 0;
		for jj=1:nx
            tmpTcheb = tmpTcheb + Tcheb(ii,xn(jj))*Tcheb(kk,xn(jj));
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