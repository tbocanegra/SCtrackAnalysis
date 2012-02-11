%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% MakeFiltX.m - G. Molera                        %
% Major function for phase tracking              %
% Down-conversion, Filtering, Hilbert Transform  %
% input: filename, Phcorr, Start and end bin, Es %
%      Nto, Bav, Nspec, Win, Nsegm, Nps, Ovlp    %
% output: vector output                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fout] = MakeFiltX(filename,Phcorr,Fbinstart,Fbinend,Es,Nto,Bav,Nspec,Wini,Wino,Nsegm,Npsi,Npso,Ovlp)
 fout(1:Nto) = 0;
 Npfo        = Npso/2;
 Oshifti     = Npsi/Ovlp;
 Oshifto     = Npso/Ovlp;
 dpadd(1:Npfo-1) = 0;
 fid         = fopen(filename,'rb');
 dinC        = fread(fid,[2 Bav*Nspec],'float32');
 tp          = complex(dinC(1,:),dinC(2,:));
 
 for jsegm = 1:Nsegm
     skip    = (jsegm-1)*Oshifti+1;
     din     = tp(skip:skip+Npsi-1);
     din     = din - 127;
     din     = din.*Wini;
     phc     = Phcorr(skip:skip+Npsi-1);
     ephc    = exp(1i.*phc);
     din     = din.*ephc;
     sp      = fft(din);
     spo     = sp(Fbinstart:Fbinend);
     spo(1)  = real(spo(1));
     spo(Npfo) = real(spo(Npfo));
     spop    = [spo,dpadd];
     out     = ifft(spop);
     dout    = out.*Wino;
     for jjso=1:Npso
        fout(jjso+(jsegm-1)*Oshifto) = fout(jjso+(jsegm-1)*Oshifto) + dout(jjso).*Es.^(jsegm-1); 
     end   
  end
 fclose(fid);
 end