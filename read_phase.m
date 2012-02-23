%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% read_phase.m - G. Molera                       %
% This function read from a phase file and       %
% plots the results. The function works with     %
% scresults GUI interface                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [handles] = read_phase (handles)
 filename = strcat(handles.phase_path,handles.phase_file);
 fprintf('\n READ_PHASE.m (reading the phase text file)\n');
 fprintf('- Opening %s\n',handles.phase_file);
 fid= fopen(filename,'r');

 Cell           = textscan(fid,'%d %d');
 fclose(fid);
 handles.tts    = Cell{1,1};
 handles.Ph     = Cell{1,2};
 handles.nPh = length(handles.tts);
 fprintf('- Copying the variables to the GUI interface\n');
end