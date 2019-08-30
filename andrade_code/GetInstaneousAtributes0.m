
function [filteredSignal, instantFreq, instantAmpl] = GetInstaneousAtributes(xdt,fs)
   %filtragem do sinal
    %Passo 1:
    n = 4;
    Wn = [0.5]/fs;
    ftype = 'high';

    [z,p,kh] = butter(n,Wn,ftype);
    sosh = zp2sos(z,p,kh);

    XdtFiltered = filtfilt(sosh,kh,xdt);
    [XdtFiltered]= convScale(min(XdtFiltered),max(XdtFiltered),XdtFiltered,-1,1);
    XdtFiltered = XdtFiltered - mean(XdtFiltered); 

    %Passo 2
    n = 4;
    Wn = [0.01 fs/2]/fs;
    ftype = 'bandpass';

    [z,p,k] = butter(n,Wn,ftype);
    sos = zp2sos(z,p,k);

    XdtFiltered = filtfilt(sos,k,XdtFiltered);
    [XdtFiltered]= convScale(min(XdtFiltered),max(XdtFiltered),XdtFiltered,-1,1);
    XdtFiltered = XdtFiltered - mean(XdtFiltered); 

    [amp,~,~]= instantAtrib(XdtFiltered',fs);

    iFreq = dnf_hilbert_instfreq(XdtFiltered, fs);

    filteredSignal = XdtFiltered;

    instantFreq = iFreq.f_smooth;
    
    instantAmpl = amp;
end


