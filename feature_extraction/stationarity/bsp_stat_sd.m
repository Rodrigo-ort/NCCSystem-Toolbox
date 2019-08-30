function [me,sd,ds] = bsp_stat_sd(signal, T, Fs)
%% Function name....: bsp_stat_sd
% Date.............: February 20, 2013
% Author...........: Nicolai Diniz Linhares
% Description......:
%                    This function computes the sd of the mean and sd of
%                    the signal and the degree of the stationarity as the
%                    time goes
% Parameters.......: 
%                    signal .....-> input series
%                    T ..-> the period of time of each calculation
%                    Fs ..-> the sampling frequeny of the signal
% Return...........:
%                    me .... -> the standard deviation of the mean
%                    sd .... -> the standard deviation of the standard
%                    deviation
%                    ds ... -> the median of the degrees of stationarity of
%                    each window
% Usage............:
%                    t = (0:500)*0.001; 
%                    y1 = sin(2*pi*60*t);
%                    [me,sd,ds] = bsp_stat_sd(y1, 2, 1000);
    n = T*Fs;
    LSI = numel(signal);
    if n < 1 || n > LSI
        throw(MException('InvalidParameter'));
    end     
    split = bsp_vector_split(signal, n);
    if iscell(split) ~= 1
        throw(MException('InvalidParameter'));
    end
    L = max(size(split));
    s_info = zeros(L,2);
    for i = 1:L
        s_info(i,1) = mean(split{i});
        s_info(i,2) = std(split{i});
        if i ~= L
            [ds_info(i,:),f] = bsp_ds(split{i}, Fs);
        end
    end
    if nargout == 0
        subplot(2,1,1);
        plot(0:1/Fs:(LSI-1)*(1/Fs),signal);
        hold on;
        min_s = min(signal);
        max_s = max(signal);
        xes = zeros(1,L);
        for i = 1:L
            x_pos(i) = i*n*(1/Fs); 
            xes(i) = ((i-1)*n + n/2)*1/Fs;
            min_v(i) = min_s;
            max_v(i) = max_s;
        end
        plot(xes,s_info(:,1),'ro');
        plot(xes,s_info(:,2),'greeno');
        legend('Signal','Window mean', 'Window sd');
        line([x_pos;x_pos],[min_v; max_v],'Color','magenta');
        for i = 1:numel(f)
            ci(:,i) = bootci(250,@median,ds_info(:,i));
        end
        subplot(2,1,2);
        hold on;
        plot(f,median(ds_info),'x');
        plot(f,ci(1,:),'rv','MarkerSize',5);
        plot(f,ci(2,:),'r^','MarkerSize',5);
        plot(f,smooth(median(ds_info),'lowess',5),'g');
        legend('DS median', 'CI low limit', 'CI up limit', 'DS trend');
    else
    me = s_info(:,1);
    sd = s_info(:,2);
    ds = ds_info;
    end