%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% hanN.m - G. Molera                             %
% N times Hanning window of a set of vectors     %
% input: data vector, Nh (times)                 %
% output: smoothed vector                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dout] = hanN(dat,Nh)
 dout = han(dat);
 for i=1:Nh
    dout = han(dout);
 end
end