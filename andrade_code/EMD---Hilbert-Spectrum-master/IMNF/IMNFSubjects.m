%Hilbert Spectrum
%generation of a chirp signal
%fs = 10040; %sampling frequency (Hz)
%%
% y = y2;
y = y';

fs = 60;
% fs = 50;
t = [0:1:length(y)-1]/fs;

%t = [0:1:fs-1]*1/fs;
%y = chirp(t,0,2,300);%signal for DEMO 1 - without noise
%y = EMGS1L1'; %uncomment for DEMO 2 - signal with noise
%y = E4_INT;


%% Estimating intrinsic mode functions
figure;
subplot(2,1,1);
plot(t,y); xlabel('time (s)'); ylabel('-');

subplot(2,1,2);
[IMFs,residue]= sig_to_imf(y,1e-5,2);
LFreq=0;
UFreq=fs/2;
% UFreq=500;
n_bins= 400;
%[m_a_p,minFreq,maxFreq, hs_dt] = plotHS1(y,t,fs,n_bins,[LFreq UFreq],0);
[m_a_p,minFreq,maxFreq, hs_dt] = plotHS1(IMFs,t,fs,n_bins,[LFreq UFreq],0);

%Generating auxiliary time and frequency vectors
f = 1:1:n_bins;
f = convScale(1,n_bins,f,minFreq,maxFreq);
%Performing energy normalization (between 0 and 1)
[m_a_p]= convScale(min(min(m_a_p)),max(max(m_a_p)),m_a_p,0,1);


T=(0:1:n_bins-1)*hs_dt;
B=m_a_p;
F = f;
imagesc(T,f,m_a_p); axis xy; colormap('hot');drawnow;

[imnf_out2] = IMNF(y,B,F);

hold on; plot(T,imnf_out2,'g');ylabel('HS (Hz)'); xlabel('time (s)');

figure; boxplot(imnf_out2,'orientation','vertical');ylim([0 fs/2]);ylabel('Instantaneous mean frequency (Hz)');set(gca,'XTickLabel','');
