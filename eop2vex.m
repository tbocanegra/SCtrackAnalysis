function [] = eop2vex(vexfile, cat_eop)

% vexfile = '_obs/h1121/h1121cor.vex';
% global cat_eop; % cat_eop = 'cats/eopc04.cat';

%%
fid = fopen(vexfile);
eop_exist = 0;
n_line = 0;
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end % EOF
    if length(tline)>7 && strcmp(tline,'$GLOBAL;')==1
       while 1
        tline = fgetl(fid);
        if length(tline)>1 && strcmp(tline(1),'*')==1
            break;
        end
        n_line = n_line + 1;
        if ~isempty(strfind(tline,'$EOP'))
            eop_exist = 1;
            break;
        end
       end
    end
end
fclose(fid);

%% if eop section doen't exist:
if ~(eop_exist)

    disp(horzcat('vex-file ',vexfile,' lacks EOP section needed for SFXC, adding this...'));
    
eops = zeros(3,16);

fid = fopen(vexfile);
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end % EOF
    if length(tline)>11 && ~isempty(strfind(tline,'scan No0001'))
       tline = fgetl(fid);
       eq=strfind(tline,'=');
       yy=str2double(tline(eq(1)+1:eq(1)+4));
       dd=str2double(tline(eq(1)+6:eq(1)+8));
       date = datevec(doy2date(dd,yy));
       mjd = mjuliandate(date);
       
       fid2 = fopen(cat_eop);
       while 1
           tline = fgetl(fid2);
           if ~ischar(tline), break, end % EOF
           if length(tline)>1 && (strcmp(tline(1),' ')~=1 && strcmp(tline(1),'*')~=1)
               current_line = sscanf(tline,'%f');
               if current_line(4) == mjd-1
                   eops(1,:) = current_line;
                   eops(2,:) = sscanf(fgetl(fid2),'%f');
                   eops(3,:) = sscanf(fgetl(fid2),'%f');
                   break;
               end
           end
       end
       fclose(fid2);
       
    end
end
fclose(fid);

% >> now, insert the EOP section into the vex-file
eop_name = horzcat('     ref $EOP = EOP',num2str(dd-1,'%03d'),';');

fid2=fopen('tmp.vex','w');
fid=fopen(vexfile);

while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        fprintf(fid2,'%s\n',...
            '*-------------------------------------------------------------------------------');
        fprintf(fid2,'%s\n','$EOP;  * here delta_psi and delta_eps = dX and dY');
        fprintf(fid2,'%s\n',...
            '*-------------------------------------------------------------------------------');
        fprintf(fid2,'%s\n','*');
        fprintf(fid2,'%s\n',horzcat('  def EOP',num2str(dd-1,'%03d'),';'));
        fprintf(fid2,'%s\n',horzcat('    TAI-UTC = ',num2str(nsec(mjd),'%02d'),' sec;'));
        fprintf(fid2,'%s\n',horzcat('    eop_ref_epoch = ',...
                num2str(yy,'%04d'),'y',num2str(dd,'%03d'),'d00h00m00s;'));
        fprintf(fid2,'%s\n','    num_eop_points = 3;');
        fprintf(fid2,'%s\n','    eop_interval = 24 hr;');
        fprintf(fid2,'%s\n',horzcat('    ut1-utc = ',...
                num2str(eops(1,7),'%-10.7f'),' sec : ',...
                num2str(eops(2,7),'%-10.7f'),' sec : ',...
                num2str(eops(3,7),'%-10.7f'),' sec;'));
        fprintf(fid2,'%s\n',horzcat('    x_wobble = ',...
                num2str(eops(1,5),'%-9.6f'),' asec : ',...
                num2str(eops(2,5),'%-9.6f'),' asec : ',...
                num2str(eops(3,5),'%-9.6f'),' asec;'));
        fprintf(fid2,'%s\n',horzcat('    y_wobble = ',...
                num2str(eops(1,6),'%-9.6f'),' asec : ',...
                num2str(eops(2,6),'%-9.6f'),' asec : ',...
                num2str(eops(3,6),'%-9.6f'),' asec;'));    
        fprintf(fid2,'%s\n',horzcat('    delta_psi = ',...
                num2str(eops(1,9),'%-9.6f'),' asec : ',...
                num2str(eops(2,9),'%-9.6f'),' asec : ',...
                num2str(eops(3,9),'%-9.6f'),' asec;'));
        fprintf(fid2,'%s\n',horzcat('    delta_eps = ',...
                num2str(eops(1,10),'%-9.6f'),' asec : ',...
                num2str(eops(2,10),'%-9.6f'),' asec : ',...
                num2str(eops(3,10),'%-9.6f'),' asec;'));   
        fprintf(fid2,'%s\n','  enddef;');
        fprintf(fid2,'%s\n','*');
        fprintf(fid2,'%s\n',...
            '*-------------------------------------------------------------------------------');
        break;
    end % end of vex-file
    fprintf(fid2,'%s\n',tline);
    if length(tline)>7 && strcmp(tline,'$GLOBAL;')==1
       for jj=1:n_line
           tline = fgetl(fid);
           fprintf(fid2,'%s\n',tline);
       end
       fprintf(fid2,'%s\n',eop_name);
    end
end

fclose(fid);
fclose(fid2);

% now move tmp.vex into the vexfile (mv tmp.vex vexfile)
fid=fopen('tmp.vex');
fid2=fopen(vexfile,'w');

while 1
    tline = fgetl(fid);
    if ~ischar(tline), break; end % end of vex-file
    fprintf(fid2,'%s\n',tline);
end

fclose(fid2);
fclose(fid);

% and delete the temp file:
!rm -f tmp.vex
end

end