%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% MakeSpec.m - G. Molera                         %
% Function to compute a dynamic spectra reading  %
% data directly from the tones output.           %
% Input: filename (Tone 0 file name)             %
%        Nspec  (# of spectra to coumpute)       %
%        Nps (# FFT samples)                     %
%        Nspav (# spectra to average)            %
%        Ovlp (overlapping parameter)            %
%        Win (Windows to apply)                  %
%        Padd (Padding coeff)                    %
%        dpadd (Vector of 0, length = NPadd)     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [spa] = MakeSpec(filename,Nspec,Nps,Nspav,Ovlp,Win,Padd,dpadd)
    Nfp    = Nps + 1;
    spa    = zeros(Nspec,Nfp);
    Nav    = 2;
    Bav    = Nav*Nps;
    fid    = fopen(filename,'rb');
    dinC   = fread(fid,[2 Bav*Nspec+1],'float32');
    tp     = complex(dinC(1,:),dinC(2,:));
    for jj=1:Nspec
       for jspav=0:1:Nspav-1
           abin = Bav*(jj-1)+jspav*Nps/Ovlp + 1;
           bbin = abin+Nps-1;
           din  = tp(abin:bbin);
           din  = din.*Win;
           if ( Padd > 1 )
               dinp = [din,dpadd];
           else
               dinp = din;
           end
           sp        = fft(dinp);
           spa(jj,:) = spa(jj,:) + real(sp(1:Nfp)).^2 + imag(sp(1:Nfp)).^2;
       end
    end
    fclose(fid);
end       