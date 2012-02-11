%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% detectionTone.m - G. Molera                    %
% Simulating the detection Tone of a SC          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BW   = 250e3;
Nt   = 8*1024*1024;
Nps  = 16*1024;
Ovlp = 2;
Nav  = 8;
Padd = 2;
Sr   = 2*BW;
dt   = 1/Sr;
Tspan = Nt*dt;
jt = 0:1:Nt-1;
tt = jt.*dt;
jps = 0:1:Nps-1;

Win = cos(pi/Nps.*(jps - 0.5*Nps+0.5)).^2;
filename = 'example.bin';

tw = dt*Nps;
df = 1/tw;

Nspav  = Nav*Ovlp-(Ovlp-1);
Oshift = Nps/Ovlp;
Nspec  = Nt/(Nps*Nav);
Bav    = Nps*Nav;
jspec  = 0:1:Nspec-1;
tspec  = (jspec+0.5).*Bav.*dt;

Npadd  = Nps*(Padd-1);

if (Padd == 1)
    Npadd = 1;
end

jpad = 0:1:Npadd-1;
dpadd(1:Npadd) = 0;

Nfp = Nps*Padd/2+1;
jfs = 0:1:Nfp-1;
dfs = 1/(tw*Padd);
fs  = jfs.*dfs;
Tnorms = 16.777216;
Tnorm  = 16.777216;

fprintf('1 - Read Doppler Frequency polynomials\n\n');

Cpp = [0;440130.2839;22157.239;-16522.292;1.7353];
Cpm = [3.0833;440132.694;1320.398;-58.684; 0 ];
Cf  = [70048.91028919304;7052.868226490915;-7888.813451185823;1.104737497866154];
Npf = 3;

for jpf=1:Npf+1
  Cfs(jpf) = Cf(jpf)/(Tspan^(jpf-1));  % Freq polys to seconds
end;

Phdopp(1:Nt)  = 0;
Phinput(1:Nt) = 0;
for jt=1:Nt;
    for jjp=3:5
        tmp = Cpp(jjp).*(tt(jt)/Tnorms).^(jjp-1);
        tmr = Cpm(jjp).*(tt(jt).^(jjp-1));
    end
	Phdopp(jt)  = Tnorm*tmp;
	Phinput(jt) = tmr;
end

Fm(1:Nt) = 0;
for jpfit=1:Npf
    for jj=1:Nt
        Fm(jj) = Fm(jj) + Cfs(jpfit)*tt(jj)^(jpfit-1);
    end
end


Ndec   = 1000;
jtd    = 0:1:floor(Nt/Ndec)-1;
jtd1   = 0:1:floor(Nt/Ndec)-2;
ttd    = tt(1:Nt/Ndec);
Phd    = Phdopp(1:floor(Nt/Ndec));
Phi    = Phinput(1:floor(Nt/Ndec));
dPhd   = Phi - Phd;

fprintf('2 - Create the dynamic spectrum\n\n');
Spd = zeros(Nspec-1,Nfp);
Spm = zeros(Nspec-1,Nfp);

for jj=1:Nspec-1
    Spd(jj,:) = MakeSpec(filename,jj,Phdopp,Nfp,Nps,Nspav,Bav,Ovlp,Win,Padd,dpadd);
end

for jj=1:Nspec-1
    Spm(jj,:) = MakeSpec(filename,jj,Phinput,Nfp,Nps,Nspav,Bav,Ovlp,Win,Padd,dpadd);
end
xSpd = max(Spd');
xSpm = max(Spm');
for jj=1:Nspec-1
    Spd(jj,:) = Spd(jj,:)/xSpd(jj);
    Spm(jj,:) = Spm(jj,:)/xSpm(jj);
end

Spdav = 1/Nspec*sum(Spd,1);
Spmav = 1/Nspec*sum(Spm,1);

fprintf('3 - Measure the maximum value of the spectra and RMS\n\n');
FsearchMin = 60e3;
FsearchMax = 80e3;
HalfWindow = 8e3;
LineAvoidance = 0.5e3;
 
xfd = zeros(Nspec,3);
xfm = zeros(Nspec,3);
rmsd = zeros(Nspec,3);
rmsm = zeros(Nspec,3);
for jj=1:Nspec-1
    xfd(jj,:) = FindMax(Spd(jj,:),fs,FsearchMin,FsearchMax);
    xfm(jj,:) = FindMax(Spm(jj,:),fs,FsearchMin,FsearchMax);
end

Fdet = dfs.*xfd(:,2);
Fmod = dfs.*xfm(:,2);
for jj=1:Nspec-1
    rmsd(jj,:) = GetRMS(Spd(jj,:),fs,Fdet(jj),HalfWindow,LineAvoidance);
    rmsm(jj,:) = GetRMS(Spm(jj,:),fs,Fdet(jj),HalfWindow,LineAvoidance);
end

SNRd = (xfd(:,3) - rmsd(:,1))./rmsd(:,2);
SNRm = (xfm(:,3) - rmsm(:,1))./rmsm(:,2);
Weight=(SNRd./max(SNRd)).^2;

% %dFdet = Fdet - Fmod;
% % dFrq  = Spline(ttd,dFdm,tspec);
