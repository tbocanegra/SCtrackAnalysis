%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% functionPLL.m - G. Molera                      %
% The tones file after sctracker is used as an   %
% input file. The output should extract signal   %
% phase and new tones with higher resolution     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [handles] = function_PLL(handles)
 fprintf('1 - Initializing the digital Phase-Locked-Loop\n');
 tonebin = strcat(handles.TonesPath,handles.TonesInput(1:39),'_tonebinning.txt');
 timebin = strcat(handles.TonesPath,handles.TonesInput(1:39),'_starttiming.txt');
 BW      = 2e3;%handles.tonebw;         % Output bandwidth of the tone, by default 2 kHz.
 BWo     = 100;
 BWn     = 20;
 %fprintf('%s',tonebin);
 fid     = fopen(tonebin,'r');
 top     = fgetl(fid);
 Tbinfo  = textscan(fid,'%f %f %f %f %f');
 ToneNr  = Tbinfo{1,1};
 StartBin= Tbinfo{1,2};
 StopBin = Tbinfo{1,3};
 StartF  = Tbinfo{1,4}; % Frequency start
 StopF	 = Tbinfo{1,5};
 fid     = fopen(timebin,'r');
 top     = fgetl(fid);
 Tcinfo  = textscan(fid,'%f %f %f');
 fclose(fid);
 Start   = Tcinfo{1,2};       % Start should read the starttiming file from the SWspec
 Nscan   = str2double(handles.TonesInput(19:22));
 StarT   = Start; %+ 1200*Nscan;
 Flo     = 8411.99e6;
 Tspan   = handles.ts;  % Time duration of the scan in [s]
 Sr      = 2*BW;        % Sampling rate
 Nt      = Tspan*Sr;    % Number of samples in the input file
 Ovlp    = 2;           % Overlap factor to calculate spectra
 Nav     = 2;           % Number of spectra to average
 Padd    = 2;           % Padding value  
 Nfft    = handles.tfft;% Numberf of FFT points per sample
 dt      = 1/Sr;        % Time resolution
 df      = Sr/Nfft;     % Frequency resolution, (2*BW/NFFT) [0.2Hz]
 
 jt      = 0:1:Nt-1;
 tw      = dt*Nfft;
 tt      = jt.*dt;
 ff      = 0:Sr/Nfft:Sr-1/Nfft;
 
 fprintf('2 - Read the the first polynomials coefficients\n');
 Cpr0    = textread(strcat(handles.TonesPath,handles.TonesInput(1:39),'.poly6.txt'));
 Cfs0    = textread(strcat(handles.TonesPath,handles.TonesInput(1:39),'.X5cfs.txt'));
 
 Nspav = Nav*Ovlp-(Ovlp-1);     % Number of spectra to average
 Nspec = floor(Nt/(Nfft*Nav));  % Number of spectra processed
 jspec = 0:1:Nspec-1;
 Bav   = Nfft*Nav;
 tspec = (jspec+0.5)*Bav*dt;
 Npadd = Nfft*(Padd-1);
 dpadd(1:Npadd) = 0;

 if ( Padd == 1 )
    Npadd = 1;
 end
 
 jps  = 0:1:Nfft-1;
 Win  = cos(pi/Nfft.*(jps-0.5*Nfft+0.5)).^2;
 Nfp  = Nfft*Padd/2+1;
 jfs  = 0:1:Nfp-1;
 dfs  = 1/(tw*Padd);
 fs   = jfs.*dfs;
 
 fprintf('3 - Getting the Tone file and calculating the averaged spectra\n');
 fileName   = strcat(handles.TonesPath,handles.TonesInput);
 Sp         = MakeSpec(fileName,Nspec,Nfft,Nspav,Ovlp,Win,Padd,dpadd);
 
 xSp   = mean(mean(Sp));
 Sp    = Sp./xSp;
 Spa   = sum(Sp)./Nspec;
 %fprintf(2,'ERROR: the bin is one offset to SVP');
 
 Dmaxa = FindMax(Spa,fs,BW*0.25,BW*0.75);
 Fmxa  = dfs.*(Dmaxa(2)-1);
 bmx   = Dmaxa(1)-1;
 Nx    = 50+1;
 fsx   = fs(bmx-Nx:bmx+Nx);
 Spx   = Sp(:,bmx-Nx:bmx+Nx);
 Spax  = Spa(bmx-Nx:bmx+Nx);

 fprintf('4 - Detect the frequency of the spacecraft tone\n');
 FsearchMin    = min(fsx);
 FsearchMax    = max(fsx);
 HalfWindow    = 40;%40
 LineAvoidance = 10;%10
 xf            = zeros(Nspec,3);
 rmsd          = zeros(Nspec,3);
 dxc(1:Nspec)  = 0;
 SNR(1:Nspec)  = 0;

 for jj=1:Nspec
    xf(jj,:)  = FindMax(Sp(jj,:),fs,FsearchMin,FsearchMax);
    dxc(jj)   = PowCenter(Sp(jj,:),xf(jj,2),5);
 end

 dxc           = dxc.*dfs;
 Fdet          = dfs.*(xf(:,2)-1);
 FdetZ         = Fdet + dxc';
 
 for jj=1:Nspec
   rmsd(jj,:) = GetRMS(Sp(jj,:),fs,FdetZ(jj),HalfWindow,LineAvoidance);
   SNR(jj)    = (xf(jj,3) - rmsd(jj,1))/rmsd(jj,2);
 end
 
 fprintf('5 - Create the second phase polynomials model\n');
 Weight    = SNR.^2;
 Npf       = 5;
 Npp       = Npf + 1;
 Ffit      = PolyfitW1(tspec,Fdet,Weight,Npf);
 rFdet     = Fdet' - Ffit;
 fprintf('    Std deviation: %f\n    SNR mean     : %f\n',std(rFdet),mean(SNR));
 FitCoeffs = PolyfitW1C(tspec,Fdet,Weight,Npf);

 fprintf('6 - Store the frequency detections, residuals and SNR\n');
 ToneSNR   = SNR;               % Store the SNR values to plot the results later
 tts       = tspec + StarT;     % time of the spectra + time beg of scan
 fdets     = zeros(Nspec,4);

 Cfs1(1:Npp)     = 0;
 Cpr1(1:Npp+1)   = 0;
 Ffirst(1:Nspec) = 0;
 
 for jj=1:Npp
    Cfs1(jj)   = FitCoeffs(jj)*Tspan.^-(jj-1);
    Cpr1(jj+1) = Cfs1(jj).*(jj)^-1;
 end
 
Cpr1    = Cpr1';
Cfs1    = Cfs1';
Fpolys  = Cfs0';

for jspec=1:Nspec
    for jj=2:Npp
        Ffirst(jspec) = Ffirst(jspec) + Fpolys(jj)*tspec(jspec)^(jj-1);
    end
end

Fvideo = StartF + Ffit + Ffirst;

% Fvideo includes the 1st polynomials the FdetZ only the second approach
fdets(:,1)= tts;               % fdets store spectra time
fdets(:,2)= SNR;               %             SNR
fdets(:,3)= Fvideo;             %  (FdetZ)    frequency detections
fdets(:,4)= rFdet;             %             residual frequency
fdets_fn = strcat(handles.TonesPath,'Fdets.vex20',handles.TonesInput(2:3),'.',handles.TonesInput(4:5),'.',handles.TonesInput(6:7),'.',handles.TonesInput(9:10),'.',handles.TonesInput(19:22),'.r2i.txt');
save(fdets_fn,'fdets','-ASCII','-double');

fprintf('7 - Store the coefficients of the second polynomials\n');
save(strcat(handles.TonesPath,handles.TonesInput(1:39),'.poly6.rev2.txt'),'Cpr1','-ASCII','-double');
save(strcat(handles.TonesPath,handles.TonesInput(1:39),'.X5cfs.rev2.txt'),'Cfs1','-ASCII','-double');

fprintf('8 - Integrate the phase and filters the signal using a decimation ratio of 1:100\n');
FO      = floor(BW/BWo);
Nffto   = floor(Nfft/FO);
Nsegm   = floor(Nt/Nfft)*Ovlp-(Ovlp-1);
jpso    = 0:1:(Nffto-1);
Npfo    = Nffto*0.5 + 1;
BWoh    = 0.5*BWo;
Nto     = Nt/FO;
dto     = dt*FO;
jto     = 0:1:Nto-1;
tto     = jto.*dto;
Oshifti = Nfft/Ovlp;
Oshifto = Nffto/Ovlp;
Wini    = cos(pi/Nfft.*(jps-0.5*Nfft+0.5));
Wino    = cos(pi/Nffto.*(jpso-0.5*Nffto+0.5));

Npp        = length(Cpr0)-1;
Npf        = Npp - 1;
Cf0(1:Npf) = 0;
Cf1(1:Npf) = 0;
for jj=1:Npf
    Cf0(jj) = Cpr0(jj+1)*jj/(2*pi);
    Cf1(jj) = Cpr1(jj+1)*jj/(2*pi);
end

Cf    = Cf0 + Cf1;
Cf(1) = Cf1(1);
Cpp(1:Npp+1) = 0;
for jj=2:Npp
    Cpp(jj)  = 2*pi*Cf(jj-1)./(jj-1);
end
Cpp(Npp+1) = Cpr1(Npp+1);

Fcc = Cpp(2);
Tspanp = Tspan;
Phdopp(1:Nt) = 0;
for jt=1:Nt
    tmp = 0;
    for jjp=3:Npf+1
        tmp = tmp + Cpp(jjp)*(tt(jt)/Tspanp)^(jjp-1);
    end
    Phdopp(jt) = Tspanp.*tmp;
end

% Make a segment time shift phase correction coefficient,
% actually a start bin of the filter can be selected in such way,
% that this coeff will be +1, -1 or even complex

Bsc     = floor((Fcc-BWoh)/df);
Bec     = Bsc+Npfo-1;
Fstartc = Bsc*df;
Pssc    = Fstartc*Oshifti*dt - floor(Fstartc*Oshifti*dt);
Esc     = exp(1i*2*pi*Pssc);
Esc     = -Esc;

fprintf('9 - Running the MakeFiltX stops the spectra in the narrow band\n');
sf    = MakeFiltX(fileName,Phdopp,Bsc,Bec,Esc,Nto,Bav,Nspec,Wini,Wino,Nsegm,Nfft,Nffto,Ovlp);
rsf   = real(sf);

% Npout_set = 600+1;
% Npout_len = length(tto) - Npout_set-2000+1;
% sf        = sf(Npout_set:Npout_len);
% tto       = tto(Npout_set:Npout_len);
% Nto       = length(tto);
% Tspan     = Nto*dto;

jto   = 0:1:Nto-1; 
ssf   = fft(sf);
ssfp  = abs(ssf).^2;
xssfp = max(ssfp);
ssfp  = ssfp./xssfp;
dfto  = 1/Tspan;
fto   = dfto.*jto;

Fmin    = 0.25*BWo;
Fmax    = 0.75*BWo;
xf      = FindMax(ssfp,fto,Fmin,Fmax);
fmax    = (xf(2)-1)*dfto;

spnoise = ssfp(Bsc-500:Bsc-100);
SNR     = std(spnoise)^-1;
dBSNR   = 10*log10(SNR);

fprintf('     dBSNR   : %f\n    Fmax    : %f\n',dBSNR,fmax);

fprintf(2,'/**************************************************/\n');
fprintf(2,'/If we take a close look to the tone bine now the  /\n');
fprintf(2,'/power line is still split between several spectral/\n');
fprintf(2,'/bins. The phase correction was not error free.    /\n');
fprintf(2,'/In the narrow band with PLL we can improve it.    /\n');
fprintf(2,'/**************************************************/\n');

fprintf('10 - Filtering again the data now to a band of 20 Hz\n');
Ftarg = 0.5*BWn;
%ftn   = fto(1:floor(BWn/dfto));
Frot  = fmax - Ftarg;

sfc   = sf.*exp(-2*pi*1i*Frot.*tto);
ssf   = fft(sfc);
ssfp  = abs(ssf).^2;
xssfp = max(ssfp);
ssfp  = ssfp/xssfp;

xf    = FindMax(ssfp,fto,0.25*BWn,0.75*BWn);
fmax  = (xf(2)-1)*dfto;

% Filter the signal with a band of 20 Hz.
ssff(1:Nto)=0;
for jj=1:Nto
    if (fto(jj) < BWn)
        ssff(jj) = ssf(jj);
    end
end

% Get the signal back to time-domain
sfc   = ifft(ssff);

fprintf('11 - Storing the tone signal for plotting later in 20 Hz band\n');
handles.fs20  = fto;
handles.spa20 = ssfp;

fprintf('13 -  Get amplitude and phase of the time domain signal\n');
Ampl  = abs(sfc);
Ph    = angle(sfc);
Phr   = DeWrap(Ph);
dPhr  = Phr - 2*pi*Ftarg.*tto;

fprintf('14 -  Check now the quality of the tone\n');
sfcc  = sfc.*exp(-1i.*dPhr); % -1 looks good
ssf   = fft(sfcc);
ssfp  = abs(ssf).^2;
xssfp = max(ssfp);
ssfp  = ssfp/xssfp;
 
rmsf  = GetRMS(ssfp,fto,Ftarg,0.4*BWn,0.1*BWn);
SNR   = (1-rmsf(1))/rmsf(2);
fprintf('    SNR     :  %f\n    dBSNR   :  %f\n',SNR,10*log10(SNR));
 
fprintf('15 -  Clean the residual phase from noise\n');
wto(1:Nto) = 1;
Nppf       = 10;
PhFit      = PolyfitW(tto,dPhr,wto,Nppf);
rdPhr      = dPhr-PhFit;

fprintf('16 - Remove the PFit from the tone signal\n');
sfcc       = sfc.*exp(-1i.*PhFit);
ssf        = fft(sfcc);
ssfp       = abs(ssf).^2;
xssfp      = max(ssfp);
ssfp       = ssfp/xssfp;

rmsf       = GetRMS(ssfp,fto,Ftarg,0.4*BWn,0.1*BWn);
SNR        = (1-rmsf(1))/rmsf(2);
fprintf('    SNR     :  %f\n    dBSNR   :  %f\n',SNR,10*log10(SNR));

fprintf('17 -  dPhr is the final estimated residual phase\n');
rdPhr     = rdPhr*-1;
bin       = find(tto==15);
bax       = find(tto==(Tspan-25)); % 1065
tps(1,:)  = tto(bin:bax);
tps(2,:)  = rdPhr(bin:bax);
Phase_fn  = strcat(handles.TonesPath,'Phases.vex20',handles.TonesInput(2:3),'.',handles.TonesInput(4:5),'.',handles.TonesInput(6:7),'.',handles.TonesInput(9:10),'.',handles.TonesInput(19:22),'.txt');
tps       = tps';
save(Phase_fn,'tps','-ASCII','-double');


fprintf('18 - Filtering again the data now to a band of 5 Hz\n');
BWn   = 5;
Ftarg = 0.5*BWn;
Frot  = fmax - Ftarg;
%Frot  = Ftarg;

sfc   = sfc.*exp(-2*pi*1i*Frot.*tto);
ssf   = fft(sfc);
ssfp  = abs(ssf).^2;
xssfp = max(ssfp);
ssfp  = ssfp/xssfp;

% Filter the signal with a band of 5 Hz.
ssff(1:Nto)=0;
for jj=1:Nto
    if (fto(jj) < BWn)
        ssff(jj) = ssf(jj);
    end
end

% Get the signal back to time-domain
sfc   = ifft(ssff);
 
fprintf('19 - Storing the tone signal for plotting later in 5 Hz band\n');
handles.spa5  = ssfp;
handles.fs5   = fto;
handles.rsfc5 = real(sfc);
handles.isfc5 = imag(sfc);
handles.tto5  = tto;

fprintf('20 - Analysing the phase and frequency noise of the signal in 5 Hz band\n');
Ampl  = abs(sfc);
Ph    = angle(sfc);
Phr   = DeWrap(Ph);
dPhr5 = Phr - 2*pi*Ftarg.*tto;

%fprintf('14 -  Check now the quality of the tone\n');
%sfcc  = sfc.*exp(-1i.*dPhr5); % -1 looks good
%ssf   = fft(sfcc);
%ssfp  = abs(ssf).^2;
%xssfp = max(ssfp);
%ssfp  = ssfp/xssfp;
 
%rmsf  = GetRMS(ssfp,fto,Ftarg,0.4*BWn,0.1*BWn);
%SNR   = (1-rmsf(1))/rmsf(2);
%fprintf('    SNR     :  %f\n    dBSNR   :  %f\n',SNR,10*log10(SNR));
 
%fprintf('15 -  Clean the residual phase from noise\n');
%wto(1:Nto) = 1;
%Nppf       = 10;
%PhFit      = PolyfitW(tto,dPhr5,wto,Nppf);
%rdPhr5     = dPhr-PhFit;

%fprintf('16 - Remove the PFit from the tone signal\n');
%sfcc       = sfc.*exp(-1i.*PhFit);
%ssf        = fft(sfcc);
%ssfp       = abs(ssf).^2;
%xssfp      = max(ssfp);
%ssfp       = ssfp/xssfp;

%rmsf  = GetRMS(ssfp,fto,Ftarg,0.4*BWn,0.1*BWn);
%SNR   = (1-rmsf(1))/rmsf(2);
%fprintf('    SNR     :  %f\n    dBSNR   :  %f\n',SNR,10*log10(SNR));

%fprintf('17 -  dPhr is the final estimated residual phase\n');
%rdPhr     = rdPhr*-1;
%bin       = find(tto==15);
%bax       = find(tto==(Tspan-25)); % 1065
%tps(1,:)  = tto(bin:bax);
%tps(2,:)  = rdPhr5(bin:bax);
%Phase_fn  = strcat(handles.TonesPath,'Phases.vex20',handles.TonesInput(2:3),'.',handles.TonesInput(4:5),'.',handles.TonesInput(6:7),'.',handles.TonesInput(9:10),'.',handles.TonesInput(19:22),'.txt');
%tps       = tps';

%save(Phase_fn,'tps','-ASCII','-double');
%fn_bw5 = strcat(handles.TonesPath,handles.TonesInput(1:45),'bw5.bin');
%fid    = fopen(fn_bw5,'wb');
%fwrite(fid,sfc,'float32');
%fclose(fid);



handles.PhFit  = PhFit;
handles.dPhr   = dPhr;
handles.rdPhr  = rdPhr;
handles.sf     = sf;
handles.tto    = tto;
handles.fto    = fto;
handles.ssfp   = ssfp;
handles.Cf0    = Cfs0;
handles.Cfs0   = Cfs0;
handles.Cpr0   = Cpr0;
handles.Cf1    = FitCoeffs;
handles.Cfs1   = Cfs1;
handles.Cpr1   = Cpr1;
handles.Spa    = Spa;
handles.Spax   = Spax;
handles.Fvideo = Fvideo;
handles.ToneSNR= ToneSNR;
handles.fs     = fs;
handles.fsx    = fsx;
handles.Fdet   = Fdet;
handles.Ffit   = Ffit;
handles.rFdet  = rFdet;
handles.tspec  = tspec;
end