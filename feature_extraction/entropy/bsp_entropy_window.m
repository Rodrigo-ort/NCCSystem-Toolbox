function en_arr = bsp_entropy_window(signal, T, Fs, func, param1, param2)
%% Function name....: bsp_stat_sd
% Date.............: May 21, 2013
% Author...........: Nicolai Diniz Linhares
% Description......:
%                    This function computes the entropy for the windows
%                    within T seconds of the input series
% Parameters.......: 
%                    signal .....-> input series
%                    T ..-> the period of time of each calculation
%                    Fs ..-> the sampling frequeny of the signal
%                    func ..-> the reference to the entropy function
%                    param1 ..-> first parameter to be passed for the referenced
%                    function
%                    param1 ..-> second parameter to be passed for the referenced
%                    function
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
    en_arr = zeros(L,1);
    h = waitbar(0,'Processing');
    matlabpool open
    for i = 1:L
        en_arr(i) = func(split{i},param1,param2);
        waitbar(i/L,h,'Processing');
    end
    matlabpool close
    close(h);
    if nargout == 0
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
        plot(xes,en_arr,'ro');
        line([x_pos;x_pos],[min_v; max_v],'Color','magenta');
    end