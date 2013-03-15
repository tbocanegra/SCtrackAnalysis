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
 fftpoints= handles.fftpoints;
 t0       = 0;               % t1 not used (2012.08.20)
 b0       = t0/handles.dts+1;
 b1       = handles.Nspec;
 Npf      = Npol-1;
 SR       = 2*BW;
 df       = SR/fftpoints;
 bfs      = handles.Fsmin/df+1;
 bfe      = handles.Fsmax/df+1;
 Nfft     = fftpoints/2+1;
 jf       = 0:1:Nfft-1;
 ff       = df.*jf;
 tsp      = dts.*(0.5+(0:1:Nspec-1));      %(1:Nspec)
 ffs      = ff(bfs:bfe-1);
 Sps      = zeros(Nspec,bfe-bfs);
 AverSpec(1:Nfft) = 0;
 Vexade   = 0;
 
 % Opening the spectra file
 fid  = fopen(fileName);
 if (fid > 0)
	fprintf ('opening the file: %s \n',fileName);
 end
 
 % The each accumulated spectra is extracted from the file
 for jj=1:Nspec
	data     = fread(fid,[Nfft 1],'float32');
    if (jj==1) 
       handles.Spec(1,:) = data; 
    end
    if (jj==Nspec)
        handles.Spec(2,:) = data;
    end
    Sps(jj,:)= han(data(bfs:bfe-1));
    AverSpec = transpose(data) + AverSpec;
    percent(jj,Nspec);
 end
 
 fclose(fid);
 
 AverSpec = AverSpec/Nspec;
 mSp      = max(max(Sps));
 Sps      = Sps./mSp;
 
 % Find the max and min the spacecraft Doppler and calculate the SNR
 FsearchMinC = min(ffs); % Min freq
 FsearchMaxC = max(ffs); % Max freq
 Hwin  = 1e3;
 Avoid = 100;
 
 xfc(Nspec,3)  = 0;
 RMS(Nspec,3)  = 0;
 SNR(Nspec)    = 0;
 Fdet(Nspec)   = 0;

 for jj=1:Nspec
	xfc(jj,:) = FindMax(Sps(jj,:),ffs,FsearchMinC,FsearchMaxC);
    Smax(jj)  = xfc(jj,3);
	Fdet(jj)  = df*(xfc(jj,2)-1) + ffs(1); 
	RMS(jj,:) = GetRMS(Sps(jj,:),ffs,Fdet(jj),Hwin,Avoid);
	SNR(jj)   = (xfc(jj,3)-RMS(jj,1))/RMS(jj,2);
 end
 
 mSNR = mean(SNR);
 
 fprintf('\n');
 fprintf(2,'Min frequency for the SC detected is     : %s\n',min(Fdet));
 fprintf(2,'Max frequency for the SC detected is     : %s\n',max(Fdet));
 fprintf(2,'Difference max frequency is              : %s\n',max(Fdet)-min(Fdet));
 fprintf(2,'Average of the SNRC through the spectras : %s\n',mSNR);

 %% Calculating the centre of the gravity correction
 Weight(1:Nspec) = 1;
 %Weight = (SNR./mSNR).^2;
 dxc(1:Nspec)=0;
 
 for jj=1:Nspec
	dxc(jj) = PowCenter(Sps(jj,:),xfc(jj,2),3);
 end
  
 dxc    = dxc*df;
 FdetC  = Fdet + dxc;
 
 if ( Vexade == 1)
    mFdet     = mean(FdetC);            % VEXADE
    FdetC     = FdetC - mFdet;          % VEXADE
 end
 
 % Calculate the n-order polynomial fit and the coefficients
 Ffit         = PolyfitW1(tsp,FdetC,Weight,Npf);
 Cf           = PolyfitW1C(tsp,FdetC,Weight,Npf);
 RMSF         = wstdev(FdetC-Ffit,Weight);
 
 if ( Vexade == 1)
    Cf(1)        = Cf(1) + mFdet;       % VEXADE
    Ffit         = Ffit  + mFdet;       % VEXADE
    FdetC        = FdetC + mFdet;       % VEXADE
 end
 
 fprintf(2,'Goodness of the polynomial fit: %s\n',RMSF);
 
 %% We transform the values to readable for sctracker
 % Re-normallize the coefficients for a time scale in seconds.
 % Cf  = Poly coefficients in frequency.
 % Cfs = Poly coefficients in Hz per second
 % Cps = Poly coefficients in radians per second
 % Cpr = Poly coefficients in radians per sample
 Cfs(1,1:Npol)=0;
 Cps(1,1:Npol+1)=0;
 Cpr(1,1:Npol+1)=0;

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

%% Verifying the polyifit that we just created.
 %Ntm = 1000;
 %Tm  = 1140;
 %dtm = Tm/(Ntm-1);
 %jtm = 0:1:Ntm-1;
 %ttm = jtm*dtm;
 %Fm(1:Ntm) = 0;
 %for jpfit=1:Npol
 %	for jj=1:Ntm
 %        Fm(jj) = Fm(jj) + Cfs(jpfit)*ttm(jj)^(jpfit-1);
 %   end
 %end

 % Storing the temporal results to be read in the GUI interface 
 handles.AverSpec = AverSpec/mSNR;
 handles.mSNR  = mSNR;
 handles.rFit  = FdetC - Ffit;
 handles.ff    = ff;
 handles.Ffit  = Ffit;
 handles.Fdet  = Fdet;
 handles.FdetC = FdetC;
 handles.SNR   = SNR;
 handles.Smax  = Smax;
 handles.tsp   = tsp;
 handles.Cpr0  = Cpr;
 handles.Cf0   = Cf;
 handles.Cfs0  = Cfs;
 fprintf('\nPolynomial fit created correctly\n\n');
end