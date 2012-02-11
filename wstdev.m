%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% wmean: Calculates the standard deviation from a%
%       vector respect a Weight                  %
% Input:  Spec (power spectrum)                  % 
%         wgt  (weigth)                          %   
% Output: std (mw/ww)                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out] = wstdev(Spec,wgt)
 mw   = wmean(Spec,wgt);
 Spec = Spec - mw;
 ww   = sum(wgt.^2);
 dw   = sum((Spec.*wgt).^2);
 out  = sqrt(dw/ww);
end
