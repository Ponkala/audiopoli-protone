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
        num=1;
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
    xlabel('frequency [Hz]')
    
    figure(num) % create figure
    if position == "_hor_"
        subplot(2,1,1);
        title("horizontal response");
    else
        subplot(2,1,2);
        title("vertical response");
    end
    
    %% colorbar
    cb=colorbar;
    cb.Ticks=linspace(0,1,19);
    cb.TickLabels = num2cell(0:10:180);
    cb.Direction = 'reverse';
    cb.Label.String = "degrees";
    ylabel('SPL [dB]')
    ax = gca;
    ax.ColorOrder = ccolormap;
    ax.CLimMode = "auto";
    
    ymag_tweeter = P_FT(Iv)*2;
    ymag_woofer = P2_FT(Iv)*2;
    ymag_sum = P3_FT(Iv)*2;
    
    %% set which response to plot
    ydb = mag2db(abs(ymag_sum)); 
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
    
    %% create frd objects
    frd_obj  = frd(ymag_tweeter(1:L/2+1),Fv);
    frd_obj2 = frd(ymag_woofer(1:L/2+1), Fv);
    frd_obj3 = frd(ymag_sum(1:L/2+1), Fv);

%     subplot(2,1,2);
%     xlim([19 21000 ]);
%     ylabel('Phases')
% 
%     ccolormap = ccolormap(end:-floor(length(ccolormap)/19):1,:);
%     ax = gca;
%     ax.ColorOrder = ccolormap;

    %% extract all the phase responses from the frd data
    [response,freq] = frdata(frd_obj);
    [response2,freq2] = frdata(frd_obj2);
    [response3,freq3] = frdata(frd_obj3);

    absresponse_T= abs(response);
    absresponse_T=absresponse_T(1,:);
    absresponse_W= abs(response2);
    absresponse_W=absresponse_W(1,:);
    absresponse_sum= abs(response3);
    absresponse_sum=absresponse_sum(1,:);
    
    phase=angle(response(1,:));
    phase=phase(1,:);
    phase2=angle(response2(1,:));
    phase2=phase2(1,:);
    phase3=angle(response3(1,:));
    phase3=phase3(1,:);
%     dp3=diff(phase3);
%     dp3(dp3>5.5)=NaN;
%     semilogx(Fv(1:length(phase3)), phase3);
    grid on
    hold on

    %% save to file
    fileID = fopen(outputfilename,'w');
    data=[freq'; mag2db(absresponse_T)+166;rad2deg(phase)];
    % FRD file format
    fprintf(fileID,"%.3f %.3f %.3f\n",data);
    fclose(fileID);
end
