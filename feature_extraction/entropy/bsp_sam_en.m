function saen = bsp_sam_en(signal,dim,r,down)
%% Function name....: bsp_ap_en
% Date.............: May 01, 2013
% Author...........: Nicolai Diniz Linhares adapted from Kijoon Lee
% Description......:
%                    This function computes the sample entropy of a
%                    signal, different from approximate entropy 
%                    self-matchings are not counted.
% Parameters.......: 
%                    signal .....-> input series
%                    dim ..-> size of the sequency to be compared
%                    r ..-> similarity tolerance (0.1*SD < r < 0.25*SD)
%                    down(optional) ..-> ratio of downsampling of the
%                    signal
% Return...........:
%                    saen .... -> sample entropy estimation
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
correl = zeros(1,2);
dataMat = zeros(dim+1,N-dim);
for i = 1:dim+1
    dataMat(i,:) = signal(i:N-dim+i-1);
end

for m = dim:dim+1
    count = zeros(1,N-dim);
    tempMat = dataMat(1:m,:);
    
    for i = 1:N-m
        
        dist = max(abs(tempMat(:,i+1:N-dim) - repmat(tempMat(:,i),1,N-dim-i)));
        
        D = (dist < r);
        
        count(i) = sum(D)/(N-dim);
    end
    
    correl(m-dim+1) = sum(count)/(N-dim);
end

saen = log(correl(1)/correl(2));
if isnan(saen)
    saen = 0;
end
end

