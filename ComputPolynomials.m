%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %          
% ComputPolynomials.m - G. Molera                %   
% Plot the polynomial fitting function given Cpp %
% Input: Cpp Input File                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out] = ComputPolynomials(filecpp)
 Nsp=113;
 Npoints = 5;

 fid=fopen(filecpp,'r');
 fgetl(fid);                 % gets the first 0
 for jp=1:Npoints
	Cpr(jp)=str2double(fgetl(fid));
 end
 fclose(fid);

 % Make a time scale, time in samples in 20 s intervals
 dts=10;
 BW=8e6;
 dtss=dts*BW;

 tss=dtss*(1:Nsp);
 tsp=dts*(1:Nsp);
 Ps1(Nsp)=0;
 Ps2(Nsp)=0;

 for jsp=1:Nsp
	for jj=2:5
		Ps1(jsp)=Cpr(jj)*(tss(jsp)^(jj))+Ps1(jsp);
	end
	Ps2(jsp)=((((Cpr(5)*tss(jsp))+Cpr(4))*tss(jsp)+Cpr(3))*tss(jsp)+Cpr(2))*tss(jsp)*tss(jsp);
 end

 % Plotting the results
 figure(1);
 title('Plot the phase');
 plot(tsp,Ps1,'r');
 Hold on;
 plot(tsp,Ps2,'b--');

 figure(2);
 title('And their difference');
 plot(tsp,Ps1-Ps2,'r');

 Ps=Ps1';
 out = Ps;
 %save('Cpp.txt','Ps','-ascii');
end