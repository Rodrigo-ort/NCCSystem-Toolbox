function ap_en = bsp_ap_en(signal,dim,r,down)
%% Function name....: bsp_ap_en
% Date.............: May 01, 2013
% Author...........: Nicolai Diniz Linhares adapted from Kijoon Lee
% Description......:
%                    This function computes the aproximated entropy of a
%                    signal
% Parameters.......: 
%                    signal .....-> input series
%                    dimm ..-> size of the sequency to be compared
%                    r ..-> similarity tolerance (0.1*SD < r < 0.25*SD)
%                    down(optional) ..-> ratio of downsampling of the
%                    signal
% Return...........:
%                    ap_en .... -> aproximated entropy estimation
% Usage............:
%                    t = (0:500)*0.001; 
%                    y1 = sin(2*pi*60*t) + 0.8*sin(2*pi*80*t);
%                    y2 = sin(2*pi*120*t) + 0.7*sin(2*pi*140*t);
%                    ap_en = bsp_ap_en(y1,2,0.15*std(y1));
%                    ap_en = bsp_ap_en(y2,2,0.15*std(y2),2);

if nargin == 4
    signal = downsample(signal,down);
end

N = length(signal);
result = zeros(1,2);

for j = 1:2
    m = dim+j-1;
    q = N-m+1;
    phi = zeros(1,q);
    dataMat = zeros(m,q);
    
    % creating columns with groups of m elements of the signal
    for i = 1:m
        dataMat(i,:) = signal(i:N-m+i);
    end
    
    % comparing the result of the subtraction of every group with r
    for i = 1:q
        tempMat = abs(dataMat - repmat(dataMat(:,i),1,q));
        boolMat = any( (tempMat > r),1);
        phi(i) = sum(~boolMat)/q;
    end
    
    % summing over the counts
    result(j) = sum(log(phi))/q;
end

ap_en = result(1)-result(2);

end