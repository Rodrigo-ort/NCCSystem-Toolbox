% xdt -> signal
% fl  -> low cutoff hz
% fh  -> high cutoff hz
% fs  -> sample frequency 
function [filtSig] = FiltrarSinal(xdt,fl,fh,fs)

n = 4;
Wn = [fl]/fs;
ftype = 'high';

[z,p,kh] = butter(n,Wn,ftype);
sosh = zp2sos(z,p,kh);

XdtFiltered = filtfilt(sosh,kh,xdt);
[XdtFiltered]= convScale(min(XdtFiltered),max(XdtFiltered),XdtFiltered,-1,1);
XdtFiltered = XdtFiltered - mean(XdtFiltered);

%Passo 2
n = 4;
%Wn = [0.01 fs/2]/fs;
Wn = [fl fs/2]/fs;
% Wn = [fl fh]/fs;
ftype = 'bandpass';

[z,p,k] = butter(n,Wn,ftype);
sos = zp2sos(z,p,k);

XdtFiltered = filtfilt(sos,k,XdtFiltered);
[XdtFiltered]= convScale(min(XdtFiltered),max(XdtFiltered),XdtFiltered,-1,1);
XdtFiltered = XdtFiltered - mean(XdtFiltered);

filtSig = XdtFiltered;

end