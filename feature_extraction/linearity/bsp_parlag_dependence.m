function pldf = bsp_parlag_dependence(signal,nLags)
%% Function name....: bsp_parlag_dependence
% Date.............: July 29, 2013
% Author...........: Nicolai Diniz Linhares
% Description......:
%                    This function computes estimate of the partial lag dependence
%                    used in linearity analysis
% Parameters.......: 
%                    signal .....-> input series
%                    nLags ..-> the number of lags
%                   
% Return...........:
%                    pldf .... -> an array with nLags coefficient values
% Usage............:
%                    t = (0:500)*0.001; 
%                    y1 = sin(2*pi*60*t) + 0.8*sin(2*pi*80*t);
%                    y2 = sin(2*pi*120*t) + 0.7*sin(2*pi*140*t);
%                    ldf = bsp_parlag_dependence(y1,2);
%                    ldf2 = bsp_parlag_dependence(y2,2);
    pldf = zeros(1,nLags);
    for k = 1:nLags
        yt0 = bsp_lag_series(signal,k-1);
        coef0 = polyfit(yt0,signal,1);
        yres0 = polyval(coef0,yt0);
        ss0 = sum((signal-yres0).^2);
        ytk = bsp_lag_series(signal,k);
        coef = polyfit(ytk,signal,1);
        yres = polyval(coef,ytk);
        ssk = sum((signal-yres).^2);
        r2 = (ss0 - ssk)/ss0;
        [maxi ind_max] = max(signal);
        [mini ind_min] = min(signal);
        pldf(k) = sign(yres(ind_max) - yres(ind_min))*sqrt(r2);
    end