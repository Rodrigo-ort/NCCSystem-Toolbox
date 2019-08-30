
function [imnf_out2,T] = IMNFest(y,t,fs,isToPlot)
%isToPlot = 0 (sim), isToPlot = -1(nao)

[IMFs,residue]= sig_to_imf(y',1e-5,2);


LFreq=0;
UFreq=fs/2;
%UFreq=20;
n_bins= 400;
%[m_a_p,minFreq,maxFreq, hs_dt] = plotHS1(y,t,fs,n_bins,[LFreq UFreq],0);
[m_a_p,minFreq,maxFreq, hs_dt] = plotHS1(IMFs,t,fs,n_bins,[LFreq UFreq],isToPlot);

%Generating auxiliary time and frequency vectors
f = 1:1:n_bins;
f = convScale(1,n_bins,f,minFreq,maxFreq);
%Performing energy normalization (between 0 and 1)
[m_a_p]= convScale(min(min(m_a_p)),max(max(m_a_p)),m_a_p,0,1);


T=(0:1:n_bins-1)*hs_dt;
B=m_a_p;
F = f;

if(isToPlot>0)
    imagesc(T,f,m_a_p); axis xy; colormap('hot');drawnow;
end

[imnf_out2] = IMNF(y,B,F);

if(isToPlot>0)
 hold on; plot(T,imnf_out2,'g');ylabel('HS (Hz)'); xlabel('time (s)');
end

