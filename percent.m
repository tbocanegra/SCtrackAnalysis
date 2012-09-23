%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% Percent.m - G. Molera                          %
% Calculates the conducted percentage made       %
% input: vector, weight vector, Num. Polys       %
% output: vector approximation                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out] = percent(kk,ns)
 tk = (kk*100/ns);
 if tk > 9.9 && tk < 10.1
     fprintf('Job process  10%%\n');
 elseif tk > 19.9 && tk < 20.1
     fprintf('Job process  20%%\n');
 elseif tk > 29.9 && tk < 30.1
     fprintf('Job process  30%%\n');
 elseif tk > 39.9 && tk < 40.1
     fprintf('Job process  40%%\n');
 elseif tk > 49.9 && tk < 50.1
     fprintf('Job process  50%%\n');
 elseif tk > 59.9 && tk < 60.1
     fprintf('Job process  60%%\n');
 elseif tk > 69.9 && tk < 70.1
     fprintf('Job process  70%%\n');
 elseif tk > 79.9 && tk < 80.1
     fprintf('Job process  80%%\n');
 elseif tk > 89.9 && tk < 90.1
     fprintf('Job process  90%%\n');
 elseif tk > 99.9
     fprintf('Job process 100%%\n');
 end
 out = 1;
end