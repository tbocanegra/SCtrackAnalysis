%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
% Within a given frequency band, specific bins   % 
% and undesired spurs a cancelling mask(1,0).    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dout] = MakeMask(bspan,kfs,mk)
 len_mk=length(mk);
 dout(1:bspan)=0;

 for i=1:len_mk
    dout(mk(i))= 1;
 end
end
