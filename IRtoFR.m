%% Read data from incomplete anechoic chamber measurements. 
%  The data needs to be imported beforehand!
% Oskari Ponkala
% 14.4.2023
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

position = "_ver_";
filename="AP_excel_sum";
anglestr="0";
outputfilename="frd_files"+filename+"/"+filename+position+anglestr+"g.frd";

resp = m_in_hor(:,1);
L = length(resp);


%% regular fft routine
Ts = 1/48000;
Fs = 1/Ts;
Fn = Fs/2;
P=resp;
P_FT=fft(P)/L;                  
Fv = linspace(0, 1, fix(L/2)+1)*Fn; 
Iv = 1:length(Fv);                  
% figure(1)                                     
% plot(t*1E+6, P); % plot impulse response if desired
grid on 
xlabel('time[\mus]')
ylabel('amplitude[a.u]')
figure(1)
ymag=P_FT(Iv)*2;
ydb = mag2db(abs(ymag)'.*sqrt(Fv));
semilogx(Fv,ydb+95);
ylim([40 105 ]);
xlim([19 21000 ]);
frd_obj = frd(ymag(1:L/2+1), Fv);
grid on
[response,freq] = frdata(frd_obj);

%% transform arrays to proper shape and scale
absresponse= abs(response);
absresponse=absresponse(1,:).*sqrt(Fv);
phase=angle(response(1,:));
phase=phase(1,:);

%% output file
fileID = fopen(outputfilename,'w');
data=[freq'; mag2db(absresponse)+95;rad2deg(phase)];
fprintf(fileID,"%.3f %.3f %.3f\n",data);
fclose(fileID);