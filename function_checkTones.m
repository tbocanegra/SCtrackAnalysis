%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% CheckTones.m - G. Molera                       %
% Return complex bins from the spacecraft signal %
% Input: filename + plot YES or NOT              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [handles] = function_checkTones(handles)
 bw      = handles.tonebw;
 sr      = 2*bw;
 dt      = 1/sr;
 Ovlp    = 2;
 Nav     = 2;            % Number of spectra to average
 Padd    = 2;
 Nps     = handles.tfft;
 Tt      = handles.ts;
 Nt      = Tt*sr;
 tw      = dt*Nps;
 Nspec   = floor(Nt/(Nps*Nav));
 Fmin    = 500;
 Fmax    = 1500;
 Fbw     = 300;
 Fvoid   = 5;
 jt      = 0:1:Nt-1;
 df      = sr/Nt;
 jspec   = 0:1:Nspec-1;
 Bav     = Nps*Nav;
 tspec   = (jspec+0.5)*Bav*dt;
 
 fileName   = strcat(handles.TonesPath,handles.TonesInput);
 fprintf('Checking the tones output of %s\n',fileName);
 
 Nspav = Nav*Ovlp-(Ovlp-1);
 Npadd = Nps*(Padd-1);
 
 if ( Padd == 1 )
    Npadd = 1;
 end
 
 jpad = 0:1:Npadd-1;
 dpadd(1:Npadd) = 0;
 jps  = 0:1:Nps-1;
 Win  = cos(pi/Nps.*(jps-0.5*Nps+0.5)).^2;
 Nfp  = Nps*Padd/2+1;
 jfs  = 0:1:Nfp-1;
 dfs  = 1/(tw*Padd);
 fs   = jfs.*dfs;

 Sp  = MakeSpec(fileName,Nspec,Nps,Nspav,Ovlp,Win,Padd,dpadd);
 xSp = mean(mean(Sp));
 Sp  = Sp./xSp;
 Spa = sum(Sp)./Nspec;
 xf  = zeros(Nspec,3);
 rmsd= zeros(Nspec,3);
 Fdet= zeros(1,Nspec);
 SNR = zeros(1,Nspec);
 
 for jj=1:Nspec
    xf(jj,:)   = FindMax(Sp(jj,:),fs,Fmin,Fmax);
    Fdet(jj)   = dfs.*(xf(jj,2)-1);
    rmsd(jj,:) = GetRMS(Sp(jj,:),fs,Fdet(jj),Fbw,Fvoid);
    SNR(jj)    = (xf(jj,3) - rmsd(jj,1))/rmsd(jj,2);
 end
 
 handles.Spa       = Spa;
 handles.fs        = fs;
 handles.ToneSNR   = SNR;
 handles.Fdet      = Fdet;
 handles.tspec     = tspec;
end