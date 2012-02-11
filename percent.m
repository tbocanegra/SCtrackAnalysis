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
 tk = floor(kk*100/ns);
 if (tk == 10)
     fprintf('Scan reading process is now about 10\n');
 elseif (tk == 20)
     fprintf('Scan reading process is now about 20\n');
 elseif (tk == 30)
     fprintf('Scan reading process is now about 30\n');
 elseif (tk == 40)
     fprintf('Scan reading process is now about 40\n');
 elseif (tk == 50)
     fprintf('Scan reading process is now about 50\n');
 elseif (tk == 60)
     fprintf('Scan reading process is now about 60\n');
 elseif (tk == 70)
     fprintf('Scan reading process is now about 70\n');
 elseif (tk == 80)
     fprintf('Scan reading process is now about 80\n');
 elseif (tk == 90)
     fprintf('Scan reading process is now about 90\n');
 elseif (tk == 100)
     fprintf('Scan reading process is now about 100\n');
 end
 out = 1;
end