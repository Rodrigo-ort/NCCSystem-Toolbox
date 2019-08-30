function H = bsp_spec_en(signal,c,Fs,nfft,p,base)
%% Function name....: bsp_spec_en
% Date.............: May 15, 2013
% Author...........: Nicolai Diniz Linhares 
% Description......:
%                    This function computes the Spectral entropy of a
%                    signal, which is the shannon entropy of the signal
%                    spectral info
% Parameters.......: 
%                    signal .....-> input series
%                    c ..-> positive constant
%                    Fs ..-> sampling frequency
%                    nfft(optional) ..-> number of point in the fft
%                    p(optional) ..-> autoregressive model degree
%                    base(optional) ..-> the log base, default is e
% Return...........:
%                    H .... -> Shannon entropy in the suited base
% Usage............:
%                    t = (0:500)*0.001; 
%                    y1 = sin(2*pi*60*t) + 0.8*sin(2*pi*80*t);
%                    H1 = bsp_ap_en(y1,1);
%                    H2 = bsp_ap_en(y1,0.69,2);

if nargin == 3
    nfft = 1024;
    p = 4;
    base = exp(1);
elseif nargin == 4
    p = 4;
    base = exp(1);
elseif nargin == 5
    base = exp(1);
end

[Px, x] = pburg(signal, p, nfft, Fs);
P = Px/sum(Px);
[m n] = size(P);
if(m > n)
    P = P';
end
h1=(-1)*ones(size(P));
%change the 0 ocurrence to 1, to avoid the computation of log(0)
h2=((sign(P)+h1).*h1)+P;
H=h2*log(h2)'*(-c);
trans = log10(exp(1))/log10(base);
H = H * trans;
if isnan(H)
    H = 0;
end