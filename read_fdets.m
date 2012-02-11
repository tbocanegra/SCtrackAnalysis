%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% read_fdets.m - G. Molera                       %
% This function read from a fdets file and       %
% plots the results. The function works with     %
% scresults GUI interface                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [handles] = read_fdets (handles)
 filename = strcat(handles.fdets_path,handles.fdets_file);
 fprintf('\n READ_PHASE.m (reading the phase text file)\n');
 fprintf('- Opening %s\n',filename);
 fid= fopen(filename,'r');

 Cell           = textscan(fid,'%f %f %f %f');
 handles.tts    = Cell{1,1};
 handles.SNR    = Cell{1,2};
 handles.fdets  = Cell{1,3};
 handles.rfdets = Cell{1,4};
 handles.sfdets = length(handles.tts);
 fprintf('- Copying the variables to the GUI interface\n');
end