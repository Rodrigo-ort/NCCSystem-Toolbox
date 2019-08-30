function [filtSig] = LowPassFilt(xdt,n,fc,fs)
   
    Wn = fc/fs;
    ftype = 'low';

    [z,p,kh] = butter(n,Wn,ftype);
    sosh = zp2sos(z,p,kh);

    XdtFiltered = filtfilt(sosh,kh,xdt);
    filtSig = XdtFiltered;
end