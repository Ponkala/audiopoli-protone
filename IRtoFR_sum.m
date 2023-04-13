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

filename  = "AP_tweeter_ir"; 
filename2 = "AP_woofer_ir";
fil  = csvread(filename);
fil2 = csvread(filename2);

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
    resp2= fil2(:,i);
    L = length(resp);
    Ts = 1/48000;
    Fs = 1/Ts;
    Fn = Fs/2;
    P=resp;
    P2=resp2;
    P_FT=fft(P)/L; 
    P2_FT=fft(P2)/L;
    P3_FT=P_FT+P2_FT;
    Fv = linspace(0, 1, fix(L/2)+1)*Fn; 
    Iv = 1:length(Fv);                  
    % figure(1)                                     
    % plot(t*1E+6, P); % plot impulse if required
    ccolormap = colormap(jet);
    ccolormap = ccolormap(end:-floor(length(ccolormap)/19):1,:);
    xlabel('frequency[Hz]')
    
    figure(num) % create figure
    subplot(2,1,1);
    ylabel('SPL')
    ax = gca;
    ax.ColorOrder = ccolormap;
    ax.CLimMode = "auto";
    ymag = P3_FT(Iv)*2;
    ydb = mag2db(abs(ymag));
    if position == "_hor_"
        title("horizontal response");
    else
        title("vertical response");
    end
    semilogx(Fv,ydb+166);
    ylim([40 105 ]);
    xlim([19 21000 ]);
    grid on
    hold on
    
    frd_obj = frd(ymag(1:L/2+1), Fv);
    subplot(2,1,2);
    xlim([19 21000 ]);
    ylabel('Phase')

    ccolormap = ccolormap(end:-floor(length(ccolormap)/19):1,:);
    ax = gca;
    ax.ColorOrder = ccolormap;
    [response,freq] = frdata(frd_obj);
    absresponse= abs(response);
    absresponse=absresponse(1,:);
    
    phase=angle(response(1,:));
    phase=phase(1,:);
    semilogx(Fv, rad2deg(phase));
    grid on
    hold on

    %% save to file
    fileID = fopen(outputfilename,'w');
    data=[freq'; mag2db(absresponse)+166;rad2deg(phase)];
    % FRD file format
    fprintf(fileID,"%.3f %.3f %.3f\n",data);
    fclose(fileID);
end
