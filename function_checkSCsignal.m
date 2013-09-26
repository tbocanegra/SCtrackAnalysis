%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% function_checkSCsignal.m - G. Molera           %
% Return the power level of the SC signal        %
% integration time								 %
% Input: filename                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [handles] = function_checkSCsignal(handles)
 fileName   = strcat(handles.SpectraPath,handles.SpectraInput);
 Nspec      = round(handles.Tend/handles.dts);
 Fmin       = handles.Fsmin;
 Fmax       = handles.Fsmax;
 BW         = handles.BW;
 fftpoints  = handles.fftpoints;
 FAvoid     = 1e2;				% Freq margin respect PCal 
 Fbw        = 1e3;				% noise bw to check SNR
 df         = 2*BW/fftpoints;
 Nfft       = fftpoints/2+1;
 jf         = 0:1:Nfft-1;
 ff         = df.*jf;
 handles.ff = ff;
 
 xfc      = zeros(Nspec,3);
 rmsd     = zeros(Nspec,3);
 
 SNR(1:Nspec) = 0;

 fprintf('File %s opened \n',fileName);
 AverSpec(1:Nfft) = 0;
 Fdet(1:Nspec)    = 0;
 handles.Spec     = zeros(2,Nfft);
 
 fid = fopen(fileName);
 for k=1:Nspec
    data         = fread(fid,[Nfft 1],'float32');
    if (k==1) 
       handles.Spec(1,:) = data; 
    end
    if (k==Nspec)
        handles.Spec(2,:) = data;
    end
    AverSpec     = data' + AverSpec;
    xfc(k,:)     = FindMax(data,ff,Fmin,Fmax);
    Fdet(k)      = df*(xfc(k,2)-1) + ff(1); 
    rmsd(k,:)    = GetRMS(data,ff,Fdet(k),Fbw,FAvoid);
    SNR(k)       = (xfc(k,3) - rmsd(k,1))/rmsd(k,2);
    percent(k,Nspec);
 end
 fclose(fid);
 
 handles.SNR  = SNR;
 handles.AverSpec = AverSpec/Nspec;
 fprintf ('SNR media: %d\n\n',mean(SNR));
 handles.mSNR = mean(SNR);
 handles.AverSpec = handles.AverSpec/handles.mSNR;
end