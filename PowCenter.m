%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% Power Center: Calculates the gravitational     %
%       moment of the spacecraft carrier signal. %
% Input:  Spec (power spectrum)                  % 
%         Xm   (position of max power)           %   
%         Nx   (Number of bins to check)         %   
% Output: dxo (deviation of the measured posi-   %
%       tion of the maximum from the first       %
%       iteration of the value of Xm.)           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dxo] = PowCenter(Spec,Xm,Nx)
 xo = floor(Xm + 0.5);
 mp = sum(Spec(xo-Nx:xo+Nx));
 wp = sum(Spec(xo-Nx:xo+Nx).*((xo-Nx:xo+Nx)-Xm));
 dxo = wp/mp;
end