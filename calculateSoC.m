function [calculatedTimes, soc] = calculateSoC(times, volt, curr, parallelResistance)
%CALCULATESOC Summary of this function goes here
%   Detailed explanation goes here
step = 250; %multiply by 20ms to get how often the value will get returned
len = length(times);
calculatedTimes = times(1:step:(len-step));
stabilisedVoltages = volt(1:len) + curr(1:len)*parallelResistance;  
fix(len/step)
soc = zeros(1, length(calculatedTimes));
for i=1:step:(len-step)
    medianSVolt = median(stabilisedVoltages(i:i+step));
    soc(fix(i/step)+1) = medianSVolt;
end
length(calculatedTimes)
length(soc)
end