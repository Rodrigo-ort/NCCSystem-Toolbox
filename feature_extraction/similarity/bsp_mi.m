function mi = bsp_mi(signal1, signal2)
%% Function name....: bsp_mi
% Date.............: July 28, 2013
% Author...........: Nicolai Diniz Linhares
% Description......:
%                    This function computes mutual information between two
%                    signals
% Parameters.......: 
%                    signal1 .....-> first input series
%                    signal2 .....-> second input series
% Return...........:
%                    mi .... -> the value of mutual information
% Usage............:
%                    t = (0:500)*0.001; 
%                    y1 = sin(2*pi*15*t) + 0.8*sin(2*pi*25*t);
%                    y1 = sin(2*pi*30*t) + 0.8*sin(2*pi*10*t);
%                    mi12 = bsp_mi(y1,y2);
%                    mi21 = bsp_mi(y2,y1);
%                    mi1 = bsp_mi(y1,y1);
%                    mi2 = bsp_mi(y2,y2);

    mi = 0;
    [join, map, p1, p2] = bsp_joint_pmass(signal1, signal2);
    for i = 1:length(join)
        ind = map(i,:);
        if join(i) ~= 0 && p1(ind(1))*p2(ind(2)) ~= 0
               mi = mi + join(i)*log2(join(i)/(p1(ind(1))*p2(ind(2))));
        end
    end
