%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% DeWrap.m - G. Molera                           %
% The tones file after sctracker is used as an   %
% input file. The output should extract signal   %
% phase and new tones with higher resolution     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [phc] = DeWrap(ph)
 np  = length(ph);
 dph(1:np) = 0;
 qph(1:np) = 0;
 phc(1:np) = 0;

 for jj = 2:1:np
     if(abs(ph(jj)-ph(jj-1)) < pi)
         dph(jj) = 0;
     else
         dph(jj) = sign(ph(jj)-ph(jj-1));
     end
 end
 for jj = 2:1:np
     qph(jj) = qph(jj-1) + dph(jj);
 end
 for jj = 1:np
     phc(jj) = ph(jj) - 2*pi*qph(jj);
 end
end
 
     