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
 file_lng  = 39;
 fprintf('1- Initialize the digital Phase-Locked-Loop\n');
 tonebin   = strcat(handles.TonesPath,handles.TonesInput(1:file_lng),'_tonebinning.txt');
 timebin   = strcat(handles.TonesPath,handles.TonesInput(1:file_lng),'_starttiming.txt');
 Nfft      = handles.tfft;          % Number of FFT
 Tspan     = handles.ts;            % Time duration of the scan in [s]
 BW        = handles.tonebw;        % Tone BW input
 BWo       = handles.tonebw_out;    % Tone BW output
 BWi       = handles.tonebw_if;     % Intermediate filtering
 Npol1     = handles.Npol1;         % Order of the 1st Polynomials
 Npol2     = handles.Npol2;         % Order of the 2nd Polynomials
 Tskip     = handles.skip;          % Skip seconds added in the SCtracker
 
 fid = fopen(tonebin,'r');
  fgetl(fid);
  Tbinfo = textscan(fid,'%f %f %f %f %f');
 fclose(fid);
 
 StartF = Tbinfo{1,4}; % Frequency start

 if (handles.TonesInput(1) == 'v')
     spacecraft = 'vex';
 elseif (handles.TonesInput(1) == 'r')
     spacecraft = 'ras';
 elseif (handles.TonesInput(1) == 'g')
     spacecraft = 'gns';
 elseif (handles.TonesInput(1) == 'm')
     spacecraft = 'mex';
 elseif (handles.TonesInput(1) == 'h')
     spacecraft = 'her';
 end
 
 fid     = fopen(timebin,'r');
  fgetl(fid);
  Tcinfo  = textscan(fid,'%f %f %f');
 fclose(fid);
 
 StarT   = Tcinfo{1,2};       % Start should read the starttiming file from the SWspec
 Sr      = 2*BW;        % Sampling rate
 Nt      = Tspan*Sr;    % Number of samples in the input file
 Ovlp    = 2;           % Overlap factor to calculate spectra
 Nav     = 2;           % Number of spectra to average
 Padd    = 2;           % Padding value  
 dt      = 1/Sr;        % Time resolution
 
 jt      = 0:1:Nt-1;
 tw      = dt*Nfft;
 df      = 1/tw;
 tt      = jt.*dt;
 ff      = 0:Sr/Nfft:Sr-1/Nfft;
 skip    = Tskip/df+1;  % Skip n scans at the beginning
 
 fprintf('2- Read the the first polynomials coefficients\n');
 
 fn  = strcat(handles.TonesPath,handles.TonesInput(1:file_lng),'.poly',int2str(Npol1),'.txt');
% fn  = strcat(handles.TonesPath,handles.TonesInput(1:23),'0320000pt_1s_ch1.poly',int2str(Npol1),'.txt');
 fid = fopen(fn);
 if (fid < 0)
     fprintf('Failed opening: %s',fn);
 end
 
 Cell = textscan(fid,'%f');
 Cpp1 = Cell{1};
 Npp1 = Npol1;
 fclose(fid);

 fn  = strcat(handles.TonesPath,handles.TonesInput(1:file_lng),'.X',int2str(Npol1-1),'cfs.txt'); 
% fn  = strcat(handles.TonesPath,handles.TonesInput(1:23),'0320000pt_1s_ch1.X',int2str(Npol1-1),'cfs.txt');
 fid = fopen(fn);
 if (fid < 0)
     printf('Failed opening: %s',fn);
 end
 
 Cell = textscan(fid,'%f');
 Cfs1 = Cell{1};
 Npf1 = Npp1-1;
 fclose(fid);

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

 fprintf('3- Get the Tone file and calculate the averaged spectra\n');
 fileName   = strcat(handles.TonesPath,handles.TonesInput);
 Sp         = MakeSpec(fileName,Nspec,Nfft,Nspav,Ovlp,Win,Padd,dpadd);
 
 xSp   = mean(mean(Sp));
 Sp    = Sp./xSp;
 Spa   = sum(Sp)./Nspec;
 
 fprintf('4- Detect the frequency of the spacecraft tone\n');
 FsearchMin    = 800;
 FsearchMax    = 1200;
 HalfWindow    = 40;
 LineAvoidance = 10;
 
 xf            = zeros(Nspec,3);
 rmsd          = zeros(Nspec,3);

 dxc(1:Nspec)  = 0;
 SNR(1:Nspec)  = 0;
 Smax(1:Nspec) = 0;
 
 for jj=skip:Nspec
    xf(jj,:)   = FindMax(Sp(jj,:),fs,FsearchMin,FsearchMax);
    Smax(jj)   = xf(jj,3);
    dxc(jj)    = PowCenter(Sp(jj,:),xf(jj,2),3);
 end

 dxc           = dxc.*dfs;
 Fdet          = dfs.*(xf(:,2)-1);
 Fdet          = Fdet + dxc';
 
 for jj=skip:Nspec
   rmsd(jj,:)  = GetRMS(Sp(jj,:),fs,Fdet(jj),HalfWindow,LineAvoidance);
   SNR(jj)     = (xf(jj,3) - rmsd(jj,1))/rmsd(jj,2);
 end
 
 fprintf('5- Create the second phase polynomials model\n');
 Weight(1:Nspec) = 1;
 Npp2            = Npol2;
 Npf2            = Npol2-1;
 Cpp2(1:Npp2+1,1)= 0;
 Cfs2(1:Npp2,1)  = 0;
 Cf1(1:Npp1,1)   = 0;
 Ffirst(1:Nspec) = 0;
 
 % Small correction added for VEXaDE experiments
 mFdet     = mean(Fdet);
 Fdet      = Fdet - mFdet;
 
 Ffit      = PolyfitW1(tspec,Fdet,Weight,Npf2);
 rFdet     = Fdet' - Ffit;
 fprintf('    Std deviation: %f\n    SNR mean     : %f\n',std(rFdet),mean(SNR));
 
 Cf2 = PolyfitW1C(tspec,Fdet,Weight,Npf2);
 
 Cf2(1) = Cf2(1) + mFdet;
 
 for jpf=1:Npol1
    Cf1(jpf) = Cfs1(jpf)*Tspan^(jpf-1);
 end
 
 for jpf=1:Npol2
	Cfs2(jpf) = Cf2(jpf)*Tspan^-(jpf-1);
 end
 
 for jpf=2:Npol2+1
    Cpp2(jpf) = 2*pi*Cf2(jpf-1)/(jpf);
 end
 
 %Generate the polynomials
 Cpp(1:Npp2+1)      = 0;
 Cf1(Npf1+2:Npf2+1) = 0;
 Cf                 = Cf1 + Cf2;
 Cf(1)              = Cf2(1);
 Npf                = Npf2;

 for jpf=2:Npol2+1
    Cpp(jpf) = 2*pi*Cf(jpf-1)/(jpf);
 end
 
 fprintf('6- Store the frequency detections, residuals and SNR\n');
 ToneSNR   = SNR;                   % Store the SNR values to plot the results later
 tts       = tspec + StarT + Tskip; % Time of the spectra + Beg of scan
 Cfs1      = Cfs1';

for jspec=1:Nspec
    for jj=2:Npf1+1
        Ffirst(jspec) = Ffirst(jspec) + Cfs1(jj)*tspec(jspec)^(jj-1);
    end
end

% Fvideo includes the 1st polynomials the FdetZ only the second approach
Fvideo = StartF(1) + Ffirst + Fdet' + mFdet;

fprintf('7- Store the coefficients of the second polynomials\n');

fdets     = zeros(Nspec,5);
fdets(:,1)= tts;                % fdets store spectra time
fdets(:,2)= SNR;                % SNR
fdets(:,3)= Smax;               % Spectral MAX
fdets(:,4)= Fvideo;             % Frequency detections
fdets(:,5)= rFdet;              % Residual frequency

day = strcat('20',handles.TonesInput(2:3),'.',handles.TonesInput(4:5),'.',handles.TonesInput(6:7));
fdets_fn = strcat(handles.TonesPath,'Fdets.',spacecraft,day,'.',handles.TonesInput(9:10),'.',handles.TonesInput(19:22),'.r2i.txt');

fid = fopen(fdets_fn,'w+');
fprintf(fid,'// Observation conducted on %s at %s rev. 2 \n',day,handles.TonesInput(9:10));
    if (handles.TonesInput(1)=='v')
        fprintf(fid,'// Base frequency: 8415.99 MHz \n');
    elseif (handles.TonesInput(1)=='r')
        fprintf(fid,'// Base frequency: 8396.59 MHz \n');
    elseif (handles.TonesInput(1)=='m')
        fprintf(fid,'// Base frequency: 8xxx.xx MHz \n');
    elseif (handles.TonesInput(1)=='g')
        fprintf(fid,'// Base frequency: 2xxx.xx MHz \n');
    elseif (handles.TonesInput(1) == 'h')
        fprintf(fid,'// Base frequency: 8468.50 MHz \n');
    end
    fprintf(fid,'// Format : Time(UTC) [s]  | Signal-to-Noise ratio  |       Spectral max     |  Freq. detection [Hz]  |  Doppler noise [Hz] \n');
    fprintf(fid,'// \n');
fclose(fid);

save(fdets_fn,'fdets','-ASCII','-double','-append');
save(strcat(handles.TonesPath,handles.TonesInput(1:file_lng),'.poly',int2str(Npol2),'.rev2.txt'),'Cpp2','-ASCII','-double');
save(strcat(handles.TonesPath,handles.TonesInput(1:file_lng),'.X',int2str(Npol2-1),'cfs.rev2.txt'),'Cfs2','-ASCII','-double');

fprintf('8- Integrate the phase and filter the signal using a decimation ratio of 1:100\n');
FO      = floor(BW/BWi);
Nffto   = floor(Nfft/FO);
Nsegm   = floor(Nt/Nfft)*Ovlp-(Ovlp-1);
jpso    = 0:1:(Nffto-1);
Npfo    = Nffto*0.5 + 1;
BWih    = 0.5*BWi;
Nto     = Nt/FO;
dto     = dt*FO;
jto     = 0:1:Nto-1;
tto     = jto.*dto;
Oshift  = Nfft/Ovlp;

%Oshifto = Nffto/Ovlp;
Wini    = cos(pi/Nfft.*(jps-0.5*Nfft+0.5));
Wino    = cos(pi/Nffto.*(jpso-0.5*Nffto+0.5));

Fcc          = Cf(1);
Tspanp       = Tspan;
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
Bsc     = floor((Fcc-BWih)/dfs);
Bec     = floor(Bsc+Npfo-1);
Fstartc = Bsc*dfs;
Pssc    = Fstartc*Oshift*dt - floor(Fstartc*Oshift*dt);
Esc     = -exp(1i*2*pi*Pssc);

fprintf('9- Running the MakeFiltX stops the spectra in the narrow band\n');
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

Fmin    = 0;
Fmax    = BWi;
xf      = FindMax(ssfp,fto,Fmin,Fmax);
fmax    = (xf(2)-1)*dfto;

spnoise = ssfp(Bsc-400:Bsc-100);
%spnoise = ssfp(Bsc-400:Bsc-100); Changed when analysing the VEXaDE 
SNR     = std(spnoise)^-1;
dBSNR   = 10*log10(SNR);

fprintf('     dBSNR   : %f\n    Fmax    : %f\n',dBSNR,fmax);

fprintf(2,'/**************************************************/\n');
fprintf(2,'/If we take a close look to the tone bine now the  /\n');
fprintf(2,'/power line is still split between several spectral/\n');
fprintf(2,'/bins. The phase correction was not error free.    /\n');
fprintf(2,'/In the narrow band with PLL we can improve it.    /\n');
fprintf(2,'/**************************************************/\n');

fprintf('10- Filter again the data to a band of 20 Hz\n');
Ftarg = 0.5*BWo;
%ftn   = fto(1:floor(BWo/dfto));
Frot  = fmax - Ftarg;

sfc   = sf.*exp(-2*pi*1i*Frot.*tto);
ssf   = fft(sfc);
ssfp  = abs(ssf).^2;
xssfp = max(ssfp);
ssfp  = ssfp/xssfp;

xf    = FindMax(ssfp,fto,0.25*BWo,0.75*BWo);
fmax  = (xf(2)-1)*dfto;

% Filter the signal with a band of 20 Hz.
ssff(1:Nto)=0;
for jj=1:Nto
    if (fto(jj) < BWo)
        ssff(jj) = ssf(jj);
    end
end

% Get the signal back to time-domain
sfc   = ifft(ssff);
handles.fs20  = fto;
handles.spa20 = ssfp;

fprintf('11- Get amplitude and phase of the time domain signal\n');
Ampl  = abs(sfc);
Ph    = angle(sfc);
Phr   = DeWrap(Ph);
dPhr  = Phr - 2*pi*Ftarg.*tto;

fprintf('12- Check now the quality of the tone\n');
sfcc  = sfc.*exp(-1i.*dPhr); % -1 looks good
ssf   = fft(sfcc);
ssfp  = abs(ssf).^2;
xssfp = max(ssfp);
ssfp  = ssfp/xssfp;
 
rmsf  = GetRMS(ssfp,fto,Ftarg,0.4*BWo,0.1*BWo);
SNR   = (1-rmsf(1))/rmsf(2);
fprintf('    SNR     :  %f\n    dBSNR   :  %f\n',SNR,10*log10(SNR));
 
fprintf('13- Clean the residual phase from noise\n');
wto(1:Nto) = 1;
Nppf       = 10;
PhFit      = PolyfitW(tto,dPhr,wto,Nppf);
rdPhr      = dPhr-PhFit;

fprintf('14- Remove the PFit from the tone signal\n');
sfcc       = sfc.*exp(-1i.*PhFit);
ssf        = fft(sfcc);
ssfp       = abs(ssf).^2;
xssfp      = max(ssfp);
ssfp       = ssfp/xssfp;

rmsf       = GetRMS(ssfp,fto,Ftarg,0.4*BWo,0.1*BWo);
SNR        = (1-rmsf(1))/rmsf(2);
fprintf('    SNR     :  %f\n    dBSNR   :  %f\n',SNR,10*log10(SNR));

fprintf('15- Store the estimated residual phase (dPhr)\n');
rdPhr     = rdPhr*-1;
bin       = find(tto==20);%40 and 15
bax       = find(tto==(Tspan-15)); % 1065
tps(1,:)  = tto(bin:bax);
tps(2,:)  = rdPhr(bin:bax);
Phase_fn  = strcat(handles.TonesPath,'Phases.',spacecraft,'20',handles.TonesInput(2:3),'.',handles.TonesInput(4:5),'.',handles.TonesInput(6:7),'.',handles.TonesInput(9:10),'.',handles.TonesInput(19:22),'.txt');
tps       = tps';
save(Phase_fn,'tps','-ASCII','-double');

handles.dPhr   = dPhr;
handles.rdPhr  = rdPhr;
handles.sf     = sf;
handles.rsfc   = real(sfc);
handles.isfc   = imag(sfc);

fprintf('17- Filter again the data to a band of 5 Hz\n');
BWo   = 5;
Ftarg = 0.5*BWo;
Frot  = fmax - Ftarg;
Frot  = Ftarg;

sfc   = sfc.*exp(-2*pi*1i*Frot.*tto);
ssf   = fft(sfc);
ssfp  = abs(ssf).^2;
xssfp = max(ssfp);
ssfp  = ssfp/xssfp;

% Filter the signal with a band of 5 Hz.
ssff(1:Nto)=0;
for jj=1:Nto
    if (fto(jj) < BWo)
        ssff(jj) = ssf(jj);
    end
end

% Get the signal back to time-domain
sfc   = ifft(ssff);
 
fprintf('18- Store the tone signal for plotting later in 5 Hz band\n');
handles.spa5  = ssfp;
handles.fs5   = fto;
handles.rsfc5 = real(sfc);
handles.isfc5 = imag(sfc);
handles.tto5  = tto;

%fprintf('20 - Analysing the phase and frequency noise of the signal in 5 Hz band\n');
%Ampl  = abs(sfc);
%Ph    = angle(sfc);
%Phr   = DeWrap(Ph);
%dPhr5 = Phr - 2*pi*Ftarg.*tto;

%fprintf('14 -  Check now the quality of the tone\n');
%sfcc  = sfc.*exp(-1i.*dPhr5); % -1 looks good
%ssf   = fft(sfcc);
%ssfp  = abs(ssf).^2;
%xssfp = max(ssfp);
%ssfp  = ssfp/xssfp;
 
%rmsf  = GetRMS(ssfp,fto,Ftarg,0.4*BWo,0.1*BWo);
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

%rmsf  = GetRMS(ssfp,fto,Ftarg,0.4*BWo,0.1*BWo);
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
handles.tto    = tto;
handles.fto    = fto;
handles.ssfp   = ssfp;
handles.Cfs1   = Cfs1;
handles.Cpr1   = Cpp1;
handles.Cfs2   = Cfs2;
handles.Cpr2   = Cpp2;
handles.Spa    = Spa;
handles.Fvideo = Fvideo;
handles.ToneSNR= ToneSNR;
handles.fs     = fs;
handles.Fdet   = Fdet;
handles.Ffit   = Ffit;
handles.rFdet  = rFdet;
handles.tspec  = tspec;
end