function varargout = sctracking(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sctracking_OpeningFcn, ...
                   'gui_OutputFcn',  @sctracking_OutputFcn, ...
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

% --- Executes just before sctracking is made visible.
function sctracking_OpeningFcn(hObject, eventdata, handles, varargin)
 handles.output = hObject;
 guidata(hObject, handles);
 initialize_gui(hObject, handles, false);
end

% --- Outputs from this function are returned to the command line.
function varargout = sctracking_OutputFcn(hObject, eventdata, handles) 
 varargout{1} = handles.output;
 initialize_gui(gcbf, handles, true);
end

function initialize_gui(fig_handle, handles, isreset)
if isfield(handles, 'metricdata') && ~isreset
    return;
end
% Update handles structure
guidata(handles.figure1, handles);
end


% --- Executes on selection change in swmenu.
function swmenu_Callback(hObject, eventdata, handles)
 value = get(handles.swmenu, 'Value');
 handles.exp = 0;
  if (get(handles.ext_plot,'Value') == 1)
   figure('Position',[150 600 425 220], 'Units', 'centimeters');
   set(gca,'Position',[0.12 0.18 0.85 0.72],'Units','normalized','fontsize',10,'fontname','Times New Roman');
  else
    %  figure(handles.axes1);
  end
  if isequal(value, 1)
      hold off;
      semilogy(handles.ff,handles.Spec(1,:),'-b');
      grid off; axis auto;xlim([0 handles.BW]);ylim([10^6 10^11]);
      title('Time-integrated spectra','fontsize',11,'fontname','Times New Roman');
      xlabel('VideoBand frequency [Hz]','fontsize',11,'fontname','Times New Roman');
      ylabel('Power spectra','fontsize',11,'fontname','Times New Roman');
  elseif isequal(value, 2)
      hold off;
      semilogy(handles.ff,handles.Spec(2,:),'-b');
      grid on; axis auto;xlim([0 handles.BW]);%ylim([10^7 10^12]);
      title('Power Spectra','fontsize',11,'fontname','Times New Roman');
      xlabel('VideoBand frequency','fontsize',11,'fontname','Times New Roman');
      ylabel('Power','fontsize',11,'fontname','Times New Roman');     
  elseif isequal(value, 3)
      hold off;
      semilogy(handles.ff,handles.AverSpec,'b');
      grid on; axis auto;xlim([0 handles.BW]);%ylim([10^8 10^11]);
      xlabel('VideoBand frequency','fontsize',11,'fontname','Times New Roman');ylabel('Power','fontsize',11,'fontname','Times New Roman');
      title('Average spectral power','fontsize',11,'fontname','Times New Roman');
  elseif isequal(value, 4)
      %set(gca,'Position',[0.13 0.18 0.85 0.72],'Units','normalized','fontsize',10,'fontname','Times New Roman');
      hold off;
      mAverSpec = mean(handles.AverSpec);
      AverSpec = handles.AverSpec/mAverSpec;
      semilogy(handles.ff,AverSpec,'b');
      axis auto;grid on;
      xlim([handles.Fsmin handles.Fsmax]);
      title('Spacecraft spectra observed after phase stopping','fontsize',11,'fontname','Times New Roman');
      xlabel('VideoBand frequency [Hz]','FontSize',11,'FontName','Times New Roman');
      ylabel('Power spectra','FontSize',11,'FontName','Times New Roman');
  elseif isequal(value, 5)
      hold off;
      plot(handles.tsp,handles.Fdet,'ro');hold on;plot(handles.tsp,handles.Ffit,'-b','LineWidth',1.5);
      axis auto;grid on;xlim([0 max(handles.tsp)]);legend('Fdet','Pfit');
      xlabel('Scan time [s]','Fontsize',11,'fontname','Times New Roman');
      ylabel('Frequency [Hz]','fontsize',11,'fontname','Times New Roman');
      title('Frequency detections and polyfit function','fontsize',11,'fontname','Times New Roman');
  elseif isequal(value, 6)
      hold off;
      plot(handles.tsp,handles.rFit,'r+');
      axis auto; grid on;
      xlabel('Scan Time [s]','fontsize',11,'fontname','Times New Roman');
      ylabel('Frequency [Hz]','fontsize',11,'fontname','Times New Roman','Position',[-100 0]);
      title('Post-fit residuals','fontsize',11,'fontname','Times New Roman');
  elseif isequal(value, 7)
      hold off;
      %set(gca,'Position',[0.13 0.18 0.8 0.72],'Units','normalized','fontsize',10,'fontname','Times New Roman');
      axis auto;
      plot(0:5:(handles.Nspec-1)*5,handles.SNR,'r');
      ylim([-10 max(handles.SNR)+100]);xlim([0 handles.Nspec*5]);
      title('SNR detection of the tone at 5 Hz','fontsize',11,'fontname','Times New Roman');
      xlabel('Scan time [s]','fontsize',11,'fontname','Times New Roman');
      ylabel('SNR','fontsize',11,'fontname','Times New Roman','Position',[-110 1500]);
      label = strcat('mSNR : ',num2str(handles.mSNR,5));
      text(20,300,label,'fontsize',10);grid on;
  end
end

% --- Executes on selection change in scmenu.
function scmenu_Callback(hObject, eventdata, handles)
  Value = get(handles.scmenu, 'Value');
   handles.exp = 0;
  if (get(handles.ext_plot,'Value') == 1)
    figure('Position',[150 600 425 220], 'Units', 'centimeters');
    set(gca,'Position',[0.11 0.18 0.84 0.72],'Units','normalized','fontsize',10,'fontname','Times New Roman');
  end
  if isequal(Value, 1)
      hold off;
      semilogy(handles.fs,handles.Spa,'b');
	  grid on; axis auto;
	  title('Detection of the spacecraft tone in narrow band','FontSize',11,'FontName','Times New Roman');
	  xlabel('Bandwidth [Hz]','FontSize',11,'FontName','Times New Roman');
      ylabel('Relative power','FontSize',11,'FontName','Times New Roman');
  elseif isequal(Value, 2)
      hold off;
      semilogy(handles.fs,handles.Spa,'bx');
      axis auto;
      xlim([1000.75-5 1000.75+5]);
      title('Tone zoom of the narrow band','fontsize',11,'fontname','Times New Roman');
      xlabel('Frequency [Hz]','fontsize',11,'fontname','Times New Roman');
      ylabel('Relative power','fontsize',11,'fontname','Times New Roman');
  elseif isequal(Value,3)
      hold off;
      % set(gca,'Position',[0.13 0.18 0.8 0.72],'Units','normalized','fontsize',10,'fontname','Times New Roman'); 
      plot(handles.tspec,handles.ToneSNR,'-bo','LineWidth',1,'MarkerSize',6); 
      grid on; xlim([0 max(handles.tspec)]);%ylim([0 10000]);
      t=handles.ToneSNR;
 %     save('SNRPu.txt','t','-ASCII','-double');
      title('SNR of the tone at 0.4 Hz resolution','FontSize',11,'FontName','Times New Roman');
      xlabel('Scan Time [s]','FontSize',11,'FontName','Times New Roman');
      ylabel('SNR','FontSize',11,'FontName','Times New Roman','Position',[-115 5000]);
  elseif isequal(Value, 4)
      hold off;
      %set(gca,'Position',[0.14 0.18 0.85 0.72],'Units','normalized','fontsize',10,'fontname','Times New Roman'); 
      plot(handles.tspec,handles.Fdet,'-ro');hold on;plot(handles.tspec,handles.Ffit,'b','LineWidth',1);
      grid on;xlim([0 max(handles.tspec)]);legend('Fdet','Pfit');
      title('Frequency detections at 0.4 Hz resolution','fontsize',11,'fontname','Times New Roman');
      xlabel('Scan Time [s]','fontsize',11,'fontname','Times New Roman');
      ylabel('Freq [Hz]','fontsize',11,'fontname','Times New Roman','Position',[-75 1000]);
  elseif isequal(Value,5)
      hold off;
      %set(gca,'Position',[0.13 0.18 0.85 0.72],'Units','normalized','fontsize',10,'fontname','Times New Roman'); 
      plot(handles.tspec,handles.rFdet,'-ro');
      grid on;xlim([0 max(handles.tspec)]);
      title('Residual frequency at 0.4 Hz resolution','fontsize',11,'fontname','Times New Roman');
      xlabel('Scan Time [s]','fontsize',11,'fontname','Times New Roman');
      ylabel('Freq [Hz]','fontsize',11,'fontname','Times New Roman','Position',[-75 0]);
  elseif isequal(Value,6) % Tone spectra at 20 Hz
      hold off;
      %set(gca,'Position',[0.12 0.18 0.85 0.72],'Units','normalized','fontsize',10,'fontname','Times New Roman'); 
      semilogy(handles.fs20,handles.spa20,'-b');
      xlim([0 20]);ylim([1e-10 max(handles.spa20)]);
 	  title('Spacecraft tone in 20 Hz bandwidth','fontsize',11,'fontname','Times New Roman');
	  xlabel('Frequency band [Hz]','fontsize',11,'fontname','Times New Roman');
      ylabel('Spectra power','fontsize',11,'fontname','Times New Roman'); 
  elseif isequal(Value,7) % Tone spectra at 5 Hz
      hold off;
      semilogy(handles.fs5,handles.spa5,'-b');
      xlim([0 5]);ylim([1e-10 max(handles.spa5)]);
 	  title('Spacecraft tone in 5 Hz bandwidth','fontsize',11,'fontname','Times New Roman');
	  xlabel('Frequency band [Hz]','fontsize',11,'fontname','Times New Roman');ylabel('Spectra power','fontsize',11,'fontname','Times New Roman'); 
      %label = strcat('std dev:',num2str(std(handles.SCrfit)));
      %%text(1,1,label,'fontsize',12);grid on;
  elseif isequal(Value,8) % Real and Imaginary part at 5 Hz
      hold off;grid on;
      plot(handles.tto,handles.rsfc5,'b');hold on;plot(handles.tto,handles.isfc5,'r');
      xlim([15 20]);
 	  title('Filtered 5 Hz time-domain signal','fontsize',11,'fontname','Times New Roman');
	  xlabel('Time [s]','fontsize',11,'fontname','Times New Roman');ylabel('Signal','fontsize',11,'fontname','Times New Roman');
      legend('Real','Imag');
  elseif isequal(Value,9) % Signal phase and polynomial fit
      hold off;
      plot(handles.tto,handles.dPhr,'-rx','MarkerSize',3);hold on;plot(handles.tto,handles.PhFit,'b','LineWidth',2);
      xlim([0 max(handles.tto)]);grid on;
 	  title('Signal phase and Polynomial fit','FontSize',11,'FontName','Times New Roman');
	  xlabel('Time [s]','FontSize',11,'FontName','Times New Roman');
      ylabel('Phase detection [rad]','FontSize',11,'FontName','Times New Roman');
      legend('Phase','Phase fit');
  elseif isequal(Value,10) % Residual phase
      hold off;std(handles.rdPhr);
      plot(handles.tto,handles.rdPhr,'b');xlim([15 1060]);grid on;
      title('Residual phase detected in 20 Hz band','fontsize',11,'fontname','Times New Roman');
	  xlabel('Time [s]','fontsize',11,'fontname','Times New Roman','Position',[500 -1.22]);
      ylabel('Phase [rad]','fontsize',11,'fontname','Times New Roman','Position',[-65 0]);
  elseif isequal(Value,11) % Spectral tone bins
      hold off;
      semilogy(handles.fto,handles.ssfp,'-bo');xlim([2.4 2.6]);grid on;
      title('SC signal after PLL','fontsize',11,'fontname','Times New Roman');
	  xlabel('Frequency [Hz]','fontsize',11,'fontname','Times New Roman');
      ylabel('Power spectra','fontsize',11,'fontname','Times New Roman');
  end
end

function cppmenu_Callback(hObject, eventdata, handles)
    Value = get(handles.cppmenu, 'Value');
    if isequal(Value, 1)
         set(handles.Cpr_values,'String',handles.Cf0');
    elseif isequal(Value, 2)
         set(handles.Cpr_values,'String',handles.Cfs0');
    elseif isequal(Value, 3)
         set(handles.Cpr_values,'String',handles.Cpr0');
    end
    guidata(hObject,handles);
end

function cppmenu_CreateFcn(hObject, eventdata, handles)
 if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
 end
end

% --- Executes during object creation, after setting all properties.
function swmenu_CreateFcn(hObject, eventdata, handles)
 if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
 end
end

% --- Executes during object creation, after setting all properties.
function scmenu_CreateFcn(hObject, eventdata, handles)
 if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
 end
end



function fsmin_Callback(hObject, eventdata, handles)
  handles.Fsmin = str2double(get(handles.fsmin,'String'));
  guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function fsmin_CreateFcn(hObject, eventdata, handles)
 if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
 end
end


function fsmax_Callback(hObject, eventdata, handles)
 handles.Fsmax = str2double(get(handles.fsmax,'String'));
 guidata(hObject, handles);
end

function fsmax_CreateFcn(hObject, eventdata, handles)
 if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
 end
end


function Nspectra_Callback(hObject, eventdata, handles)
 handles.Nspec = str2double(get(handles.Nspectra,'String'));
 guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function Nspectra_CreateFcn(hObject, eventdata, handles)
 if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
 end
end

function BandWidth_Callback(hObject, eventdata, handles)
 handles.BW = str2double(get(handles.BandWidth,'String'));
 guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function BandWidth_CreateFcn(hObject, eventdata, handles)
 if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
 end
end

function Cpr_values_Callback(hObject, eventdata, handles)
    set(handles.Cpr_values,'String',handles.Cpr0');
    guidata(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function Cpr_values_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%% GENERAL BOXES

function Nfft_box_Callback(hObject, eventdata, handles)
 handles.fftpoints = str2double(get(handles.Nfft_box,'String'));
 guidata(hObject, handles);
end

function Nfft_box_CreateFcn(hObject, eventdata, handles)
 if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
 end
end

function Npol_box_Callback(hObject, eventdata, handles)
    handles.Npol = str2double(get(handles.Npol_box,'String'));
    guidata(hObject, handles);
end

function Npol_box_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function Tint_Callback(hObject, eventdata, handles)
    handles.dts = str2double(get(handles.Tint,'String'));
    guidata(hObject, handles);
end
function Tint_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function SWInput_CreateFcn(hObject, eventdata, handles)
 if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white'); 
 end
end

function SCInputText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function TonesInputText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in SelectSWFile.
function SelectSWFile_Callback(hObject, eventdata, handles)
 [handles.SpectraInput,handles.SpectraPath] = uigetfile('*.bin','Select the Spectra binary file');
 set(handles.SWInput,'String',handles.SpectraInput);
 guidata(hObject, handles);
end

% --- Executes on button press in SelectSCFile.
function SelectSCFile_Callback(hObject, eventdata, handles)
 [handles.SCSpectraInput, handles.SCSpectraPath] = uigetfile('*.bin','Select the S/C binary file');
 set(handles.SCInputText,'String',handles.SpectraInput);
 guidata(hObject, handles);
end

% --- Executes on button press in SelectToneFile.
function SelectToneFile_Callback(hObject, eventdata, handles)
 [handles.TonesInput, handles.TonesPath] = uigetfile('*.bin','Select the Tone file');
 set(handles.TonesInputText, 'String',handles.TonesInput);
 guidata(hObject, handles);
end

% --- Executes on button press in SelectPhasesFile.
function SelectPhasesFile_Callback(hObject, eventdata, handles)
 [handles.PhasesInput,handles.PhasesPath] = uigetfile('*.txt','Select the Phases text file');
 set(handles.PhasesInputText,'String',handles.PhasesInput);
 guidata(hObject, handles);
end

%% BUTTON ACTIONS

function CheckSpectra_Callback(hObject, eventdata, handles)
    fsmin_Callback(hObject, 0, handles);
    fsmax_Callback(hObject, 0, handles);
    Nspectra_Callback(hObject, 0 , handles);
    BandWidth_Callback(hObject, 0, handles);
    Nfft_box_Callback(hObject, 0, handles);
    Tint_Callback(hObject, 0, handles);
    
    handles = function_checkSCsignal(handles);
    guidata(hObject,handles);
end

function CalcCpp_Callback(hObject, eventdata, handles)
    Npol_box_Callback(hObject, 0, handles);
    fsmin_Callback(hObject, 0, handles);
    fsmax_Callback(hObject, 0, handles);
    Nspectra_Callback(hObject, 0, handles);
    BandWidth_Callback(hObject, 0, handles);
    Tint_Callback(hObject, 0, handles);
    
    handles = function_findCppCoef(handles);
    set(handles.Cpr_values, 'String',handles.Cpr0');
    guidata(hObject,handles);
end

function SaveCpps_Callback(hObject, eventdata, handles)
    Cpr       = handles.Cpr0';
    Cfs       = handles.Cfs0';
    timebin   = strcat(handles.SpectraPath,handles.SpectraInput(1:39),'_starttiming.txt');
    fid       = fopen(timebin,'r');
    top       = fgetl(fid);
    Tcinfo    = textscan(fid,'%f %f %f');
    fclose(fid);
    Start     = Tcinfo{1,2};
    fdet      = zeros(handles.Nspec,4);
    fdet(:,1) = handles.tsp + Start;
    fdet(:,2) = handles.SNR;
    fdet(:,3) = handles.Fdet;
    fdet(:,4) = handles.rFit;
    handles.CppOutput = handles.SpectraInput(1:39);
    save(strcat(handles.SpectraPath,handles.SpectraInput(1:39),'.poly6.txt'),'Cpr','-ASCII','-double');
    save(strcat(handles.SpectraPath,handles.SpectraInput(1:39),'.X5cfs.txt'),'Cfs','-ASCII','-double');
    save(strcat(handles.SpectraPath,'Fdets.vex20',handles.SpectraInput(2:3),'.',handles.SpectraInput(4:5),'.',handles.SpectraInput(6:7),'.',handles.SpectraInput(9:10),'.',handles.SpectraInput(19:22),'.r0i.txt'),'fdet','-ASCII','-double'); 
    fprintf('saving the Cpp coefficients to %s \n',[handles.SpectraInput(1:39),'.poly6.txt']);
    guidata(hObject,handles);
end

function CheckPhases_Callback(hObject, eventdata, handles)
    handles = function_checkPhase(handles);
    fprintf('Checking the resultant phase of the signal\n');
    guidata(hObject,handles);
end

function checktones_Callback(hObject, eventdata, handles)
    handles = function_checkTones(handles);
    fprintf('Tones analysis finished\n');
    guidata(hObject, handles);
end

function runPLL_Callback(hObject, eventdata, handles)
    fprintf('Running the PLL with 20 Hz around the tone\n');
    handles = function_PLL(handles);
    %fprintf('Analysis finalized\n');
    guidata(hObject, handles);
end

%% CHECK BOX

% --- Executes on button press in ext_plot.
function ext_plot_Callback(hObject, eventdata, handles)
    if ( get(handles.ext_plot,'Value') == 1)
        handles.plot = 1 ;
    else
        handles.plot = 0;
    end
   guidata(hObject, handles);
end



function Tones_fft_Callback(hObject, eventdata, handles)
    handles.tfft = str2double(get(handles.Tones_fft,'String'));
    guidata(hObject, handles);   
end

% --- Executes during object creation, after setting all properties.
function Tones_fft_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
    end
end

function Time_scan_Callback(hObject, eventdata, handles)
    handles.ts = str2double(get(handles.Time_scan,'String'));
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function Time_scan_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


% --- Executes on selection change in cpp1menu.
function cpp1menu_Callback(hObject, eventdata, handles)
Value = get(handles.cpp1menu, 'Value');
    if isequal(Value, 1)
         set(handles.Cpr1_values,'String',handles.Cf1');
    elseif isequal(Value, 2)
         set(handles.Cpr1_values,'String',handles.Cfs1');
    elseif isequal(Value, 3)
         set(handles.Cpr1_values,'String',handles.Cpr1');
    end
    guidata(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function cpp1menu_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function number_files_Callback(hObject, eventdata, handles)
    handles.nfiles = str2double(get(handles.number_files,'String'));
    guidata(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function number_files_CreateFcn(hObject, eventdata, handles)
 if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
 end
end



function tonebw_value_Callback(hObject, eventdata, handles)
    handles.tonebw = str2double(get(handles.tonebw_value,'String'));
    guidata(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function tonebw_value_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function outputbw_value_Callback(hObject, eventdata, handles)
    handles.tonebw_out = str2double(get(handles.outputbw_value,'String'));
    guidata(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function outputbw_value_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
