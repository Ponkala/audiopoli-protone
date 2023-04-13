%% Matlab script for reading data from Aalto anechoic chamber IR measurements
% Oskari Ponkala
% 12.4.2023
%
% make sure you make a folder for the output files in the following format:
%       frd_files<filename>
%
% The resulting frd file can be read using VituixCad
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename="AP_woofer_ir"; 
fil = csvread(filename);

%% main
for i = 38:-1:1 % goes through all the angle steps
    if i<=19
        position="_hor_";
        num=1;
    else
        position="_ver_";
        num=2;
    end
    angleout=mod(i-1,19)*10;
    anglestr=int2str(angleout);
    outputfilename="frd_files"+filename+"/"+filename+position+anglestr+".frd";
    
    %% regular fft routine
    resp = fil(:,i);
    L = length(resp);
    Ts = 1/48000;
    Fs = 1/Ts;
    Fn = Fs/2;
    P=resp;
    P_FT=fft(P)/L;                     
    Fv = linspace(0, 1, fix(L/2)+1)*Fn; 
    Iv = 1:length(Fv);                  
    % figure(1)                                     
    % plot(t*1E+6, P); % plot impulse if required
    ccolormap = colormap(jet);
    ccolormap = ccolormap(end:-floor(length(ccolormap)/19):1,:);
    grid on
    xlabel('time[\mus]')
    ylabel('amplitude[a.u]')
    figure(num)
    ax = gca;
    ax.ColorOrder = ccolormap;
    ax.CLimMode = "auto";
    ymag=P_FT(Iv)*2;
    ydb = mag2db(abs(ymag));
    if position == "_hor_"
        title("horizontal response");
    else
        title("vertical response");
    end
    semilogx(Fv,ydb+166);
    ylim([40 105 ]);
    xlim([19 21000 ]);
    hold on
    frd_obj = frd(ymag(1:L/2+1), Fv);
    grid on
    [response,freq] = frdata(frd_obj);
    absresponse= abs(response);
    absresponse=absresponse(1,:);
    phase=angle(response(1,:));
    phase=phase(1,:);
    
    %% save to file
    fileID = fopen(outputfilename,'w');
    data=[freq'; mag2db(absresponse)+166;rad2deg(phase)];
    % FRD file format
    fprintf(fileID,"%.3f %.3f %.3f\n",data);
    fclose(fileID);
end
