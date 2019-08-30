% Function name....: SplitSignal
% Date.............: March 29, 2016
% Author...........: Fabio Henrique, (oliveirafhm@gmail.com)
% Description......:
%                    --
% Parameters.......: 
%                    inputSignal -> 
%                    time -> 
%                    cutMethod -> it should be: By index or By time
%                    cutValues -> it should be a vector with two elements
% Return...........:
%                    slicedSignal
%                    slicedTime
% Remarks..........:

function [ slicedSignal, slicedTime ] = SplitSignal(inputSignal, time, cutMethod, cutValues)
slicedSignal = [];
slicedTime = [];
switch cutMethod
    case 'index'
        for i=1:2:length(cutValues)
            slicedSignal = vertcat(slicedSignal, inputSignal(cutValues(i):cutValues(i+1)));
            slicedTime = vertcat(slicedTime, time(cutValues(i):cutValues(i+1)));
        end
    case 'time'
        for i=1:length(cutValues)
            if(isempty(find(time>=cutValues(i) & time<=cutValues(i)+0.1, 1)) == 0)%, 'last')) == 0)
                indexCutValues(i) =  find(time>=cutValues(i) & time<=cutValues(i)+0.1, 1);%, 'last');
            else
                error('Time find error');
            end
        end
        for i=1:2:length(indexCutValues)
            slicedSignal = vertcat(slicedSignal, inputSignal(indexCutValues(i):indexCutValues(i+1)));
            slicedTime = vertcat(slicedTime, time(indexCutValues(i):indexCutValues(i+1)));
        end
    otherwise
        warning('Unexpected cut method.');
end
end

