
function [xhf] = HighPassFilt(xdt,n,fc,fs)

    Wn = fc/fs;
    ftype = 'high';

    [z,p,kh] = butter(n,Wn,ftype);
    sosh = zp2sos(z,p,kh);

    xhf = filtfilt(sosh,kh,xdt);

end
    
