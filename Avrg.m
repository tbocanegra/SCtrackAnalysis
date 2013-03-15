%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% Avrg.m - G. Molera							 %
% Calcutes the average spectrum of the full      %
% spectra. The input is the array of vectors     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dout] = Avrg(Spec)
 sizenc = size(Spec);
 nrow = sizenc(1);         % FFT points
 ncol = sizenc(2);         % Number of scans
 av=zeros(nrow);
 for ii=1:nrow
    for kk=1:ncol
        av(kk) = av(kk) + Spec(ii,kk);
    end;
 end;
 dout = av/nc;
end
    
