
function [filteredSignal, instantFreq, instantAmpl] = GetInstaneousAtributes(xdt,fs)
   %filtragem do sinal
    %Passo 1:
    n = 4;
    Wn = [0.5]/fs; 
    ftype = 'high';

    [z,p,kh] = butter(n,Wn,ftype);
    sosh = zp2sos(z,p,kh);

    XdtFiltered = filtfilt(sosh,kh,xdt);
    %[XdtFiltered]= convScale(min(XdtFiltered),max(XdtFiltered),XdtFiltered,-1,1);
    XdtFiltered = XdtFiltered - mean(XdtFiltered); 

    %Passo 2
    n = 4;
    Wn = [0.01 fs/2]/fs; 
    ftype = 'bandpass';

    [z,p,k] = butter(n,Wn,ftype);
    sos = zp2sos(z,p,k);

    XdtFiltered = filtfilt(sos,k,XdtFiltered);
    %[XdtFiltered]= convScale(min(XdtFiltered),max(XdtFiltered),XdtFiltered,-1,1);
    XdtFiltered = XdtFiltered - mean(XdtFiltered); 
    
    
    opol = 20;
    [p,s,mu] = polyfit([0:1:length(XdtFiltered)-1]'/fs,XdtFiltered,opol);
    fy = polyval(p,[0:1:length(XdtFiltered)-1]'/fs,[],mu);
    XdtFiltered  = XdtFiltered - fy;
    

    [amp,~,~]= instantAtrib(XdtFiltered',fs);
    
    

    iFreq = dnf_hilbert_instfreq(XdtFiltered, fs);

    filteredSignal = XdtFiltered;

    instantFreq = iFreq.f_smooth;
    
    instantAmpl = amp;
    
    t = [0:1:length(XdtFiltered-1)]/fs;
    [imnf_out2,T] = IMNFest(20*log10(XdtFiltered.^2),t,fs,-1);
    
    instantFreq = spline(T,imnf_out2,t);
    instantFreq = instantFreq(1:length(XdtFiltered))';
end


