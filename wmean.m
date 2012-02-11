%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% wmean: Calculates the weighted mean to a given %
%       vector respect a Weight                  %
% Input:  Spec (power spectrum)                  % 
%         wgt  (weigth)                          %   
% Output: mean (mw/ww                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out] = wmean(Spec,wgt)
 ww = sum(wgt);
 mw = sum(wgt.*Spec); 
 out = mw/ww;
end
