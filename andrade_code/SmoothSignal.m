function XdtFiltered = SmoothSignal(xdt,n,fs)
% xdt = sinal de entrada
% n = ordem do filtro
    xdt = detrend(xdt);
    [XdtFiltered] = HighPassFilt(xdt,n,0.01,fs);
    XdtFiltered = detrend(XdtFiltered);

    [XdtFiltered] = LowPassFilt(XdtFiltered,n,5,fs);
    XdtFiltered = smooth(XdtFiltered,'moving',n);
    XdtFiltered = detrend(XdtFiltered);
    opol = 20;
    [p,s,mu] = polyfit([0:1:length(XdtFiltered)-1]'/fs,XdtFiltered,opol);
    fy = polyval(p,[0:1:length(XdtFiltered)-1]'/fs,[],mu);
    XdtFiltered  = XdtFiltered - fy;

    [XdtFiltered]= convScale(min(XdtFiltered),max(XdtFiltered),XdtFiltered,min(xdt),max(xdt));
    XdtFiltered = detrend(XdtFiltered);
end