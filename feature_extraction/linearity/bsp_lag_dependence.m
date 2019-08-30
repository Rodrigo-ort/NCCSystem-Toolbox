function ldf = bsp_lag_dependence(signal,nLags)
%% Function name....: bsp_lag_dependence
% Date.............: June 23, 2013
% Author...........: Nicolai Diniz Linhares
% Description......:
%                    This function computes estimate of the lag dependence
%                    used in linearity analysis
% Parameters.......: 
%                    signal .....-> input series
%                    nLags ..-> the number of lags
%                   
% Return...........:
%                    ldf .... -> an array with nLags coefficient values
% Usage............:
%                    t = (0:500)*0.001; 
%                    y1 = sin(2*pi*60*t) + 0.8*sin(2*pi*80*t);
%                    y2 = sin(2*pi*120*t) + 0.7*sin(2*pi*140*t);
%                    ldf = bsp_lag_dependence(y1,2);
%                    ldf2 = bsp_lag_dependence(y2,2);
    ldf = zeros(1,nLags);
    for k = 1:nLags
        ytk = bsp_lag_series(signal,k);
        coef = polyfit(ytk,signal,1);
        yres = polyval(coef,ytk);
        ssk = sum((signal-yres).^2);
        ss0 = sum((signal - mean(signal)).^2);
        r2 = (ss0 - ssk)/ss0;
        [maxi ind_max] = max(signal);
        [mini ind_min] = min(signal);
        ldf(k) = sign(yres(ind_max) - yres(ind_min))*sqrt(r2);
    end