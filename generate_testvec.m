%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% generate_testvec.m - G. Molera                 %
% Generate test vector for SC tracking           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 c  = 299792.458;   % km/s
 kb = 1.38e-23;     % J/K
 BW = 250e3;        % define the BW
 Sr = 2*BW;         % Sampling rate
 dt = 1/Sr;         % Sampling interval
 Nt = 8*1024*1024;  % 
 Tspan = Nt*dt;
 jt = 0:1:Nt-1;
 tt = jt.*dt;
 
 % Generem a random carrier line and additional tones
 Fco  = 8400.1e6;        % 8.4 GHz
 Fso1 = Fco - 10e3;
 Fso2 = Fco + 20e3;
 Fso3 = Fco - 50e3;
 Flo  = 8400.1e6;
 Lam  = c/Fco;
 
 % Setting the amplitude of the tones
 Amplc = sqrt(0.1);    
 Ampls1 = Amplc*0.1;
 Ampls2 = Amplc*0.5;
 Ampls3 = Amplc*0.3;
 Anoise = 1.0;          % RMS of the additive termal noise
 
 Pnhz  = (Anoise^2)/BW;         % Noise power per Hz.
 SNRhz = (0.5*Amplc^2)/Pnhz;  % SNR per Hz.
 
 % Define a model motion
 Ro = 150e6 - 1.8e-6;            % Initial distance
 Vo = 2.5;              % Initial velocity
 Ao = 15e-3;               % Initial acceleration
 Bo = -2e-3;               % Initial third derivative
 
 % The power balance between carrier line and noise is about what
 % to expect for 2.5 W Tx power, 1.5m Tx antenna, 32 m Rx antenna with
 % Tsys 35 K at X-band and distance 1 AU.
 Rs = 150e6 ;
 Ta = 35;
 bw = 1;
 Dt = 1.5;
 Dr = 32;
 Aeff = 0.6;
 Pt = 2.5;
 Pr = Pt/(4*pi*Rs^2)*pi/4*((Dt/Lam)^2)*pi/4*Aeff*Dr^2;
 Pn = kb*Ta*bw;
 PN = kb*Ta*16e6;
 
 %fprintf('Power ratio in 1 Hz:\n',10*log(Pr/Pn));
 %fprintf('Power ratio in 16 MHz:\n',10*log(Pr/PN));
 
 % S/C spinning model with a period of 1.53s and Tx antenna offset of 2.5
 % cm.
 Aspin = 0;
 Wspin = 2*pi/1.53;
 fspin = Fco*(Wspin*Aspin)/c;   % spin is disabled (fspin=0)
 
 % Make reasonable phase noise of onboard LO.
 fprintf('1 - Phase noise of onboard LO, 1.0 radian sigma on a time scale ~1s\n')
 Npn = 15;
 jpn = 0:1:Npn-1;
 tpn = jpn;
 Phnoise = randn(Npn);
 Phnoise = han(Phnoise);
 rmsPhnoise = std(Phnoise);
 Phnoise = Phnoise/rmsPhnoise*0;
 Phnc = spline(tpn,Phnoise,tt);
 %plot(tpn,Phnoise,'r');title('Phase noise in rad');
 
 % Compute Doppler parameters of the motion
 dFco  = Fco*Vo/c;
 dFso1 = Fso1*Vo/c;
 dFso2 = Fso2*Vo/c;
 dFso3 = Fso3*Vo/c;
 vFc   = Fco+dFco-Flo;
 vFs1  = Fso1+dFso1-Flo;
 vFs2  = Fso2+dFso2-Flo;
 vFs3  = Fso3+dFso3-Flo;
 aFc   = Fco*Ao/c;
 aFs1  = Fso1*Ao/c;
 aFs2  = Fso2*Ao/c;
 aFs3  = Fso3*Ao/c;
 bFc   = Fco*Bo/c;
 bFs1  = Fso1*Bo/c;
 bFs2  = Fso2*Bo/c;
 bFs3  = Fso3*Bo/c;
 
 % Compute initial phases of S/C signal
 PLamco  = Ro*Fco/c;
 PLamso1 = Ro*Fso1/c;
 PLamso2 = Ro*Fso2/c;
 PLamso3 = Ro*Fso3/c;
 Phc0    = 2*pi*(PLamco - floor(PLamco));
 Phs01   = 2*pi*(PLamso1 - floor(PLamso1));
 Phs02   = 2*pi*(PLamso2 - floor(PLamso2));
 Phs03   = 2*pi*(PLamso3 - floor(PLamso3));
 
 % Compute carrier line phase-polynomial coefficients
 Cpp(1) = Phc0;
 Cpp(2) = 2*pi*vFc;
 Cpp(3) = 2*pi*1/2*aFc;
 Cpp(4) = 2*pi*1/6*bFc;
 %save('Test_model_Phase_Cpps.txt',Cpp);
 
 % Compute Phases
 fprintf('2 - Compute phases dispersion\n');
 Phc  = 2*pi.*(vFc.*tt + 1/2*aFc.*tt.^2 + 1/6*bFc.*tt.^3) + Phc0 + Phnc + 2*pi*Aspin*Fco/c.*cos(Wspin.*tt);
 Phs1 = 2*pi.*(vFs1.*tt + 1/2*aFs1.*tt.^2 + 1/6*bFs1.*tt.^3) + Phs01 + Fso1/Fco.*Phnc + 2*pi*Aspin*Fso1/c.*cos(Wspin.*tt);
 Phs2 = 2*pi.*(vFs2.*tt + 1/2*aFs2.*tt.^2 + 1/6*bFs2.*tt.^3) + Phs02 + Fso2/Fco.*Phnc + 2*pi*Aspin*Fso2/c.*cos(Wspin.*tt); 
 Phs3 = 2*pi.*(vFs3.*tt + 1/2*aFs3.*tt.^2 + 1/6*bFs3.*tt.^3) + Phs03 + Fso3/Fco.*Phnc + 2*pi*Aspin*Fso3/c.*cos(Wspin.*tt);

 signal = Amplc.*cos(Phc)+Ampls1.*cos(Phs1)+Ampls2.*cos(Phs2)+Ampls3.*cos(Phs3);
 
 fprintf('3 - Build the signal with 4 tones and the random noise\n');
 noise = Anoise*randn(Nt,1);
 data  = noise' + signal;
 rsd   = std(data);
  
 % Automatic Gain Control is set to  put +/- 4 sigma range into 256 levels
 % of 8 bit ADC.
 sigma = 128/4;
 agn   = sigma/rsd;
 data  = data.*agn;

 for jj=1:Nt
    if (data(jj)*sign(data(jj)) > 127)
        data(jj) = 127*sign(data(jj));
    end
    data(jj) = floor(data(jj)+127+0.5);
 end

 fprintf('   Min: %d\n   Max: %d\n   Mean: %d\n',min(data), max(data), mean(data));
 
 fprintf('4 - Saving the generated data vector into disk\n');
 save Test_model_NoPhaseNoise data
 
 Nd  = 1000;
 Ntd = floor(Nt/Nd);
 jtd = 0:1:Ntd-1;
 %ttd = tt