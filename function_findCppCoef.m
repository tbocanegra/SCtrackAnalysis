%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% Given a the spectra looks through all the specs%
% cuts x number of bins, calculate SNR, finds the%
% max ybin, correct with the power spectra and   %
% finally calculates the Cpp coefficients .      %
% Input: filename, Nspec, BW                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [handles] = function_findCppCoef(handles)
 format long g;
 fileName = strcat(handles.SpectraPath,handles.SpectraInput);
 Nspec    = handles.Nspec;
 BW       = handles.BW;
 Npol     = handles.Npol;    % Polynomials grade
 dts      = handles.dts;     % Integrational time
 Nfft     = handles.fftpoints;
 SR       = 2*BW;
 df       = SR/Nfft;
 bfs      = handles.Fsmin/df+1;
 bfe      = handles.Fsmax/df+1;
 jf       = 0:1:Nfft/2;
 ff       = df.*jf;
 tsp      = dts.*(0.5+(0:1:Nspec-1));      %(1:Nspec)
 ffs      = ff(bfs:bfe-1);
 Sps      = zeros(Nspec,bfe-bfs);
 mSp      = 0;

 fid  = fopen(fileName);
 if (fid > 0)
	fprintf ('opening the file: %s \n',fileName);
 end

 %data is extracted from the spectra but we only use certain bins
 for jj=1:Nspec
	data     = fread(fid,[Nfft/2+1 1],'float');
    Sps(jj,:) = han(data(bfs:bfe-1));
 end
 
 fclose(fid);
 
 mSp = max(max(Sps));
 Sps = Sps./mSp;

 % we find the maximum values of the SC and calculate the SNR
 FsearchMinC = min(ffs); % Min freq
 FsearchMaxC = max(ffs); % Max freq
 Hwin  = 1e3;
 Avoid = 100;
 
 xfc(Nspec,3)  = 0;
 RMS(Nspec,3) = 0;
 SNR(Nspec)   = 0;
 Fdet(Nspec)   = 0;

 for jj=1:Nspec
	xfc(jj,:) = FindMax(Sps(jj,:),ffs,FsearchMinC,FsearchMaxC);
	Fdet(jj)  = df*(xfc(jj,2)-1) + ffs(1); 
	fdet(jj)  = xfc(jj,2);
	RMS(jj,:) = GetRMS(Sps(jj,:),ffs,Fdet(jj),Hwin,Avoid);
	SNR(jj)   = (xfc(jj,3)-RMS(jj,1))/RMS(jj,2);
 end

 mSNR = mean(SNR);

 fprintf(2,'Min frequency for the SC detected is     : %s\n',min(Fdet));
 fprintf(2,'Max frequency for the SC detected is     : %s\n',max(Fdet));
 fprintf(2,'Difference max frequency is              : %s\n',max(Fdet)-min(Fdet));
 fprintf(2,'Average of the SNRC through the spectras : %s\n',mSNR);

 %% Calculating the centre of the gravity correction
 dxc(1:Nspec)=0;
 for jj=1:Nspec
	dxc(jj) = PowCenter(Sps(jj,:),xfc(jj,2),3);
 end
 dxc    = dxc*df;

 % Adding the power spectra correction to our polynomial fit
 FdetC  = Fdet + dxc;

 % Statistical weight proportional to SNR square
 Weight = (SNR./mSNR).^2;

 % Calculate the n-order polynomial fit and the coefficients
 Ffit         = PolyfitW1(tsp,FdetC,Weight,Npol-1);
 Cf           = PolyfitW1C(tsp,FdetC,Weight,Npol-1);
 RMSF         = wstdev(FdetC-Ffit,Weight);    

 fprintf(2,'Goodness of the polynomial fit           : %s\n',RMSF);

 % Saving the fdets to a file.
 fdets      = zeros(Nspec,4);
 fdets(:,1) = tsp;
 fdets(:,2) = SNR;
 fdets(:,3) = FdetC;
 fdets(:,4) = FdetC-Ffit;
 
 %save(strcat(handles.SpectraPath,'Fdets.vex20',handles.SpectraInput(2:7),'.',handles.SpectraInput(9:10),'.',handles.SpectraInput(19:22),'.r0i.txt'),'fdets','-ASCII','-double');

 %% We transform the values to readable for sctracker
 % Re-normallize the coefficients for a time scale in seconds.
 % Cf  = Poly coefficients in frequency.
 % Cfs = Poly coefficients in Hz per second
 % Cps = Poly coefficients in radians per second
 % Cpr = Poly coefficients in radians per sample
 Cfs(1:Npol)=0;
 Cps(1:Npol+1)=0;
 Cpr(1:Npol+1)=0;

 dtsampling = 1/SR;
 Tspan      = max(tsp);
 Npph       = Npol+1;

 for jpf=1:Npol
	Cfs(jpf) = Cf(jpf)*Tspan^-(jpf-1);
 end
 for jpf=2:Npph
	Cps(jpf)= 2*pi*Cfs(jpf-1)/(jpf-1);
	Cpr(jpf)= Cps(jpf)*dtsampling^(jpf-1);   
 end

 % Verifying the polyifit that we just created.
 Ntm = 1000;
 Tm  = 1140;
 dtm = Tm/(Ntm-1);
 jtm = 0:1:Ntm-1;
 ttm = jtm*dtm;
 Fm(1:Ntm) = 0;
 for jpfit=1:Npol
	for jj=1:Ntm
        Fm(jj) = Fm(jj) + Cfs(jpfit)*ttm(jj)^(jpfit-1);
    end
 end

 handles.Fm    = Fm;
 handles.ttm   = ttm;
 handles.rFit  = FdetC - Ffit;
 handles.Ffit  = Ffit;
 handles.Fdet  = Fdet;
 handles.FdetC = FdetC;
 handles.tsp   = tsp;
 handles.Cpr0  = Cpr';
 handles.Cf0   = Cf';
 handles.Cfs0  = Cfs';
 fprintf('Polynomial fit created correctly\n\n');
 % PREVIOUS ERRORS: First I did not smooth the data with a Han window. 
 % It was optional and I did not thing it was important. 
 % automatically the errors in calculating the Fdet and the SNR were solved.
 % Results matched. 
 % Secondly. There was another error in calculating the frequencial polynomials. 
 % Somehow the results were for polynomial of grade 5, so i had to downgrade it to le5.
 % Fixed that and the results were almost (almost by decimals to the ones showedby 
 % Sergei.\n\n');

end