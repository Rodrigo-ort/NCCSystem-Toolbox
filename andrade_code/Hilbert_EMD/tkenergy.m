function tkresp = tkenergy(original_signal)
    tkresp = original_signal;
    for i=2:length(original_signal)-1
        tkresp(i) = original_signal(i)^2 - (original_signal(i-1) * original_signal(i+1));
    end
    tkresp(1) = tkresp(2);
    tkresp(end) = tkresp(end-1);
%     figure();
%     subplot(2,1,1); plot(original_signal);
%     subplot(2,1,2); plot(tkresp);
end