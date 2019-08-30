function H = bsp_shan_en(signal,c,base)
%% Function name....: bsp_shan_en
% Date.............: May 15, 2013
% Author...........: Nicolai Diniz Linhares adapted from PETR KLÁN
% (pklan@cs.cas.cz)
% Description......:
%                    This function computes the Shannon entropy of a
%                    signal, based on probability function estimated using
%                    normpdf
% Parameters.......: 
%                    signal .....-> input series
%                    c ..-> positive constant
%                    base(optional) ..-> the log base, default is e
% Return...........:
%                    H .... -> Shannon entropy in the suited base
% Usage............:
%                    t = (0:500)*0.001; 
%                    y1 = sin(2*pi*60*t) + 0.8*sin(2*pi*80*t);
%                    H1 = bsp_ap_en(y1,1);
%                    H2 = bsp_ap_en(y1,0.69,2);
    if(c < 0)
        error('c constant must be positive');
    end
    if(nargin < 3)
        base = exp(1);
    end
    u_q = length(unique(signal)) + 1;
    [f, x] = hist(signal, u_q);
    f = f/sum(f);
    Err=1e-6;
    if abs(1-sum(f))>Err
        error('Input vector must be a probability mass function');
    end;
    [m n] = size(f);
    if(m > n)
        f = f';
    end
    h1=(-1)*ones(size(f));
    %change the 0 ocurrence to 1, to avoid the computation of log(0)
    h2=((sign(f)+h1).*h1)+f;
    H=h2*log(h2)'*(-c);
    trans = log10(exp(1))/log10(base);
    H = H * trans;