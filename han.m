%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% han.m - G. Molera                              %
% Does a Hanning window from an input vector     %
% input: data vector                             %
% output: smoothed vector                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dout] = han(dat)
 nd = length(dat);
 dout(1)=0.5*(dat(1)+dat(2));
 dout(nd)=0.5*(dat(nd-1)+dat(nd));
 for i=2:nd-1
    dout(i)=0.5*(0.5*dat(i-1)+dat(i)+0.5*dat(i+1));
 end
end