%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% read_fdets.m - G. Molera                       %
% This function read from a fdets file and       %
% plots the results. The function works with     %
% scresults GUI interface                        %
% The Frequency detections file contain 5 column %
% with the UTC time since 00:00, SNR, Spectral   %
% Max, Freq. dets in Hz and Residual Freq. dets. %
% The first 4 lines contain the headers with the %
% obesrvation set-up metadata.                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [handles] = read_fdets (handles)
 filename = strcat(handles.fdets_path,handles.fdets_file);
 fprintf('\n READ_PHASE.m (reading the phase text file)\n');
 fprintf('- Opening %s\n',filename);
 
 fid  = fopen(filename,'r');
 if (fid < 0)
    fprintf(1,'Error reading the Fdets file\n');
 end
 data = textscan(fid,'%f %f %f %f %f','HeaderLines',4);
 fclose(fid);
 
 datamat = cell2mat(data);
 
 handles.tts    = datamat(:,1);
 handles.SNR    = datamat(:,2);
 handles.Smax   = datamat(:,3);
 handles.fdets  = datamat(:,4);
 handles.rfdets = datamat(:,5);
 handles.sfdets = length(handles.tts);

 fprintf('- data is stored in memory to the GUI interface\n');
end