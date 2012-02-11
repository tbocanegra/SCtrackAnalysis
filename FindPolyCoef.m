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

function [out] = FindPolyCoef(fileName)
 Nspec    = 59;
 BW       = 16e6;
 Npol     = 6;    % Polynomials grade
 dts      = 5;     % Integrational time
 Nfft     = 3.2e6;
 SR       = 2*BW;
 df       = SR/Nfft;
 bfs      = 7.4e6/df+1;
 bfe      = 7.5e6/df+1;
 jf       = 1:(Nfft/2+1);
 ff       = df.*(jf-1);
 tsp      = dts.*(0.5+(0:1:Nspec-1));      %(1:Nspec)
 ffs      = ff(bfs:bfe-1);
 Sps      = zeros(Nspec,bfe-bfs);
 mSp      = 0;

 fid  = fopen(fileName);
 if (fid > 0)
	fprintf ('opening the file: %s \n',fileName);
 end

 %data is extracted from the spectra but we only use certain bins
 for j=1:Nspec
	data = fread(fid,[Nfft/2+1 1],'float32');
	Sps(j,:) = data(bfs:bfe-1);
	tmp = max(Sps(j,:));
	if( tmp > mSp)  
		mSp = tmp; 
	end
 end

% and also normalise the spectra to max=1
 for j=1:Nspec
	Sps(j,:) = Sps(j,:)./mSp;
 end

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
	xfc(jj,:)  = FindMax(Sps(jj,:),ffs,FsearchMinC,FsearchMaxC);
	Fdet(jj)   = df*(xfc(jj,2)-1) + ffs(1); 
	fdet(jj)   = xfc(jj,2);
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
 dxc = dxc*df;

 % Adding the power spectra correction to our polynomial fit
 FdetC = Fdet + dxc;

 % Statistical weight proportional to SNR square
 Weight=(SNR./mSNR).^2;

 % Calculate the n-order polynomial fit and the coefficients
 Ffit         = PolyfitW1(tsp,FdetC,Weight,Npol-1);
 Cf           = PolyfitW1C(tsp,FdetC,Weight,Npol-1);
 RMSF         = wstdev(FdetC-Ffit,Weight);    

 fprintf(2,'Goodness of the polynomial fit           : %s\n',RMSF);

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
 max(ttm);
 Fm(1:Ntm) = 0;

 for jpfit=1:Npol
    for jj=1:Ntm
        Fm(jj) = Fm(jj) + Cfs(jpfit)*ttm(jj)^(jpfit-1);
    end
 end

 format long e;

 for jpf=1:Npol+2
	fprintf('%1.16e\n',Cpr(jpf));
 end
 out = Cpr;

 fprintf('Polynomial fit created correctly\n\n');
end