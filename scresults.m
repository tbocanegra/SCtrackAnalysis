%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MATLAB tools for the post-processing     %
%       of the spacecraft main carrier line      %
%                                                %
% scresults.m - G. Molera                        %
% GUI interface to plot SC results:              %
% Reads Fdets and Phase files                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = scresults(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @scresults_OpeningFcn, ...
                   'gui_OutputFcn',  @scresults_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end
% --- Executes just before scresults is made visible.
function scresults_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
end
% --- Outputs from this function are returned to the command line.
function varargout = scresults_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;
end

% --- Executes on button press in pb_fdets_if.
function pb_fdets_if_Callback(hObject, eventdata, handles)
 [handles.fdets_file,handles.fdets_path] = uigetfile('*.txt','Select the Fdets text file');
 set(handles.fdets_if,'String',handles.fdets_file);
 handles = read_fdets(handles);
 guidata(hObject, handles);
end

% --- Executes on button press in pb_phase_if.
function pb_phase_if_Callback(hObject, eventdata, handles)
 [handles.phase_file,handles.phase_path] = uigetfile('*.txt','Select the Phases text file');
 set(handles.phase_if,'String',handles.phase_file);
 handles = read_phase(handles);
 guidata(hObject, handles);
end

% --- Executes on button press in cb_plot.
function cb_plot_Callback(hObject, eventdata, handles)
    if (get(handles.cb_plot,'Value') == 1)
        handles.plot = 1 ;
    else
        handles.plot = 0;
    end
   guidata(hObject, handles);
end

% --- Executes on selection change in pm_graph.
function pm_graph_Callback(hObject, eventdata, handles)
 Value = get(handles.pm_graph, 'Value');
    handles.exp = 0;
    if (get(handles.cb_plot,'Value') == 1)
      figure('Position',[150 600 425 220], 'Units', 'centimeters');
   %   set(gca,'Position',[0.11 0.18 0.84 0.72],'Units','normalized','fontsize',10,'fontname','Times New Roman');
    end
    timebin = strcat(handles.fdets_path,handles.fdets_file(7),handles.fdets_file(12:13),handles.fdets_file(15:16),handles.fdets_file(18:19),'_',handles.fdets_file(21:22),'_MkIV_No0001_3200000pt_5s_ch1_starttiming.txt');
    %fprintf('%s\n',timebin);
    if(handles.fdets_file(7)=='r')
       satellite='RadioAstron';
    elseif(handles.fdets_file(7)=='s')
       satellite='Stereo A/B';
    elseif(handles.fdets_file(7)=='v')
       satellite='Venus Express';
    elseif(handles.fdets_file(7)=='m')
       satellite='Mars Express';
    elseif(handles.fdets_file(7)=='g')
       satellite='Glonass';
    end   
    if isequal(Value, 1)
        fprintf('Option 1: Plotting Frequency detections\n');
        plot(handles.tts,handles.fdets,'bo'); 
        grid on;
    elseif isequal(Value,2)
        fprintf('Option 2: Plotting Frequency residuals\n');
        plot(handles.tts,handles.rfdets,'bx');
        fprintf('Frequency residuals: %s \n',sqrt(mean(handles.rfdets.^2)));
        xlim auto; ylim auto;
        grid on;
    elseif isequal(Value,3)
        fprintf('Option 3: Plotting the Spectrum peak\n');
        plot(handles.tts,handles.Smax,'bx');
        xlim auto; ylim auto;
        grid on;
    elseif isequal(Value,4)
        fprintf('Option 4: Plotting the Signal-to-Noise ratio\n');
        plot(handles.tts,handles.SNR,'bx');
        fprintf('SNR: %s \n',mean(handles.SNR));
        xlim auto; ylim([0 max(handles.SNR)*1.2]); 
    elseif isequal(Value,5)
        fprintf('Option 4: Plotting all 3 Fdets data\n');
        f1 = figure;
        subplot(3,1,1); plot(handles.tts,handles.fdets,'bx','MarkerSize',3);grid on;
        Ta='Frequency detections, Stochastic Doppler noise and SNR of';
        Ti=strcat(satellite,'{ observed with }',handles.fdets_file(21:22),'{ on }',handles.fdets_file(18:19),'.',handles.fdets_file(15:16),'.',handles.fdets_file(10:13));
        title({Ta;Ti},'FontSize',13,'fontname','TimesNewRoman');
        ylim([min(handles.fdets)-250 max(handles.fdets)+250]); ylabel('Topoc. Freq. (Hz)','fontname','TimesNewRoman','FontSize',12);
        xlim([min(handles.tts)-100 max(handles.tts)+100]);
        subplot(3,1,2); plot(handles.tts,handles.rfdets,'rx','MarkerSize',3);grid on;
        ylim auto; ylabel('Doppler Noise (Hz)','fontname','TimesNewRoman','FontSize',12);
        xlim([min(handles.tts)-100 max(handles.tts)+100]);
        subplot(3,1,3); plot(handles.tts,handles.SNR,'kx','MarkerSize',3);
        grid on;
        ylim([0 max(handles.SNR)*1.2]); ylabel('SNR','fontname','TimesNewRoman','FontSize',12);
        xlim([min(handles.tts)-100 max(handles.tts)+100]);
        xlabel('Time from 00:00 UTC (s)','fontname','TimesNewRoman','FontSize',12);
        fprintf('Frequency residuals: %s \n',sqrt(mean(handles.rfdets.^2)));
        fprintf('SNR: %s \n',mean(handles.SNR));
        deltaF  = strcat('Freq range:',mat2str((max(handles.fdets)-min(handles.fdets)),1), ' Hz');
        rdF     = strcat('RMS: ',mat2str((std(handles.rfdets)*1000),1),'mHz in 5s');
        snr     = strcat('mean: ',mat2str(mean(handles.SNR),1),' in 5s');
        uicontrol('Parent', f1, 'Style','text','units','normalized','Position',[0.65 0.85 0.25 0.03],'BackgroundColor','w','fontname','Arial','FontSize',11,'String',deltaF);
        uicontrol('Parent', f1, 'Style','text','units','normalized','Position',[0.65 0.55 0.25 0.03],'BackgroundColor','w','fontname','Arial','FontSize',11,'String',rdF);
        uicontrol('Parent', f1, 'Style','text','units','normalized','Position',[0.65 0.25 0.25 0.03],'BackgroundColor','w','fontname','Arial','FontSize',11,'String',snr);
        %filename = strcat('Fdets_',handles.fdets_file(18:19),handles.fdets_file(15:16),handles.fdets_file(10:13),'_',handles.fdets_file(21:22),'.pdf');
    elseif isequal(Value,6)
        fprintf('Option 5: Plotting the phase from one scan\n');
        plot(handles.ts,handles.Ph);
        xlim auto; ylim auto;
    end
end

% --- Executes during object creation, after setting all properties.
function pm_graph_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in pb_merge_fdets.
function pb_merge_fdets_Callback(hObject, eventdata, handles)
    fprintf('\n Merge the frequency detections from an observation\n');
    nfiles = str2double(get(handles.nfiles,'String'));
    kk     = 0;
    tlines = 0;
    for ii=1:nfiles
        if (ii < 10)
            FdetsFile = strcat(handles.fdets_file(1:22),'.000',int2str(ii),handles.fdets_file(28:35));
        elseif (ii < 100)
            FdetsFile = strcat(handles.fdets_file(1:22),'.00',int2str(ii),handles.fdets_file(28:35));
        else
            FdetsFile = strcat(handles.fdets_file(1:22),'.0',int2str(ii),handles.fdets_file(28:35));
        end
        fprintf('%s',FdetsFile);
        FdetsName = strcat(handles.fdets_path,FdetsFile);
        if ( exist(FdetsName,'file') > 0 )
            fid    = fopen(FdetsFile,'r');
            txt_file = textscan(fid,'%f %f %f %f %f','Headerlines',4);
            mat_file = cell2mat(txt_file);
            Fdets(tlines+1:tlines+length(mat_file),1:5) = mat_file;
            tlines = length(mat_file) + tlines;
            clear txt_file;
            fclose(fid);
            fprintf(' OK \n');
        else
            fprintf(2,' Not Found\n');
        end
        clear txt_file;
    end
    fprintf('\n');
    FdetsFile = strcat(handles.fdets_path,handles.fdets_file(1:22),handles.fdets_file(28:35));
    
    fid = fopen(FdetsFile,'w+');
    fprintf(fid,'* Observation conducted on %s at %s rev. %s\n',handles.fdets_file(10:19),handles.fdets_file(21:22),handles.fdets_file(30));
    fprintf(fid,'* Base frequency: 8415.99 MHz \n');
    fprintf(fid,'* Format : Time(UTC) [s]  | Signal-to-Noise ratio  |       Spectral max     |  Freq. detection [Hz]  |  Doppler noise [Hz] \n',handles.fdets_file(10:19));
    fprintf(fid,'* \n');
    fclose(fid);
    
    save(FdetsFile,'Fdets','-ASCII','-double','-append');
    fprintf(strcat(handles.fdets_file(1:22),handles.fdets_file(28:35)));
    fprintf('\n');
end

% --- Executes on button press in pb_merge_phase.
function pb_merge_phase_Callback(hObject, eventdata, handles)
    fprintf('\n Merge the phases results from an observation\n\n');
    nfiles = str2double(get(handles.nfiles,'String'));
    kk = 0;
    for ii=1:nfiles
        if (ii < 10)
            PhaseFile = strcat(handles.phase_file(1:23),'.000',int2str(ii),'.txt');
        elseif (ii < 100)
            PhaseFile = strcat(handles.phase_file(1:23),'.00',int2str(ii),'.txt');
        else
            PhaseFile = strcat(handles.phase_file(1:23),'.0',int2str(ii),'.txt');
        end
        fprintf('  %s',PhaseFile);
        PhaseName = strcat(handles.phase_path,PhaseFile);
        if ( exist(PhaseName,'file') > 0 )
            txt_file = textread(PhaseName);
            Phase(1:length(txt_file),1)    = txt_file(:,1);
            Phase(1:length(txt_file),2+kk) = txt_file(:,2);
            kk = kk + 1;
            fprintf('     OK \n');
        else
            fprintf(2,' Not Found\n');
        end
        clear txt_file;
    end
    fprintf('\nTotal number of files found: %d\n',kk);
    save(strcat(handles.phase_path,handles.phase_file(1:24),'txt'),'Phase','-ASCII','-double');
    fprintf('File saved as: ');
    fprintf(strcat(handles.phase_file(1:24),'txt'));
    fprintf('\n');
end


function nfiles_Callback(hObject, eventdata, handles)
 nfiles = str2double(get(handles.nfiles,'String'));
 guidata(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function nfiles_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
