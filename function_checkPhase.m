%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% function_CheckPhases.m - G. Molera             %
% Check Phase of S/C tone after SCtracker        %
% To use with sctracking MENU GUI                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [handles] = function_checkPhase(handles)

 filename   = strcat(handles.PhasesPath,handles.PhasesInput);
 fprintf('Opening the Phases file: \n%s\n',filename);
 
 %Need to read each of the column: Data is organized in 2-column

 fid = fopen(filename,'r');
 if ( fid < 1)
    fprintf('The file cannot be opened');
 end

 nrsamples = handles.Nspec/2;
 % Discard the first line
 fgetl(fid);
 % Add all values in a cell.
 C = textscan(fid,'%d %d',nrsamples);
 ntime  = C{1,1};
 nphase = C{1,2};
 np = length(nphase);
 for jj=1:np
    while (nphase(jj) > 360)
        nphase(jj) = nphase(jj) - 360;
    end
 end
 
 fclose(fid);
 handles.Ph = nphase.*(pi/180);
 handles.nt = ntime;

end

