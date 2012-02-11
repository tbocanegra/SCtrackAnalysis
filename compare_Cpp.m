%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%												 %
% Comparing different polynomial coefficients    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Cpp0sv = textread('../data/v110325/v110325_Mh_MkIV_No0001_3200000pt_5s_ch1.poly6.txt');
Cpp0gm = textread('../data/v110325/v110325_Mh_MkIV_No0001_3200000pt_5s_ch1.poly6gmc.txt');
Cpp1sv = textread('../data/v110325/v110325_Mh_MkIV_No001_3200000pt_5s_ch1.poly6.rev2.txt');
Cpr1gm = textread('../data/v110325/v110325_Mh_MkIV_No001_3200000pt_5s_ch1.poly6.rev2.gmc.txt');

Np   = length(Cpp0sv)-1;
Sr   = 3.2e6;

Nt   = 1140;
jt   = 0:1:Nt-1;
tt   = jt;
tts  = tt.*Sr;

phA(1:Nt) = 0;
phB(1:Nt) = 0;

for jjt=1:Nt;
    for jj=3:Np
        phA(jjt) = phA(jjt) + Cpp0sv(jj)*tts(jjt).^(jj-1);
        phB(jjt) = phB(jjt) + Cpp0gm(jj)*tts(jjt).^(jj-1);
    end
end

Np2  = length(Cpp1sv)-1;
Sr   = 4000;
Nt2  = 1140;
jt2  = 0:1:Nt2-1;
tts2 = jt2.*Sr;
phA2(1:Nt2) = 0;
phB2(1:Nt2) = 0;

for jjt=1:Nt;
    for jj=3:Np
        phA2(jjt) = phA2(jjt) + Cpp1sv(jj)*tts2(jjt).^(jj-1);
        phB2(jjt) = phB2(jjt) + Cpp1gm(jj)*tts2(jjt).^(jj-1);
    end
end

figure(1);
plot(tt,phA,'b');hold on;plot(tt,phB,'r');
xlabel('tt');ylabel('CppA - Cppb');
legend('Cpp sv','Cpp gmc');

figure(2);
plot(tt,phA-phB,'g');
xlabel('tt');ylabel('PhA-PhB')
legend('residual Phase SV - Phase GMC');
