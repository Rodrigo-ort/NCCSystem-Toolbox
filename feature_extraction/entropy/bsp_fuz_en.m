function fuz_en = bsp_fuz_en(signal, dim, r, ufunc)
%% Function name....: bsp_fuz_en
% Date.............: May 28, 2013
% Author...........: Nicolai Diniz Linhares
% Description......:
%                    This function computes the fuzzy entropy of a
%                    signal, like sample entropy 
%                    self-matchings are not considered.
% Parameters.......: 
%                    signal .....-> input series
%                    dim ..-> size of the sequency to be compared
%                    r ..-> similarity tolerance (0.1*SD < r < 0.25*SD)
%                    ufunc(optional) ..-> membership function
% Return...........:
%                    fuz_en .... -> fuzzy entropy estimation
% Usage............:
%                    t = (0:500)*0.001; 
%                    y1 = sin(2*pi*60*t) + 0.8*sin(2*pi*80*t);
%                    y2 = sin(2*pi*120*t) + 0.7*sin(2*pi*140*t);
%                    fuz_en = bsp_fuz_en(y1,2,0.15*std(y1));
%                    fuz_en2 = bsp_fuz_en(y2,2,0.15*std(y2));

if nargin < 4
    ufunc = @(d,r)exp(-(d./r).^2);
end

N = length(signal);
correl = zeros(1,2);
dataMat = zeros(dim+1,N-dim);
for i = 1:dim+1
    dataMat(i,:) = signal(i:N-dim+i-1) - mean(signal(i:N-dim+i-1));
end

for m = dim:dim+1
    count = zeros(1,N-dim);
    tempMat = dataMat(1:m,:);
    
    parfor i = 1:N-m
        
        dist = max(abs(tempMat(:,i+1:N-dim) - repmat(tempMat(:,i),1,N-dim-i)));
        
        D = ufunc(dist,r);
        
        count(i) = sum(D)/(N - dim - 1);
    end
    
    correl(m-dim+1) = sum(count)/(N-dim);
end

fuz_en = log(correl(1)/correl(2));
if isnan(fuz_en)
    fuz_en = 0;
end

