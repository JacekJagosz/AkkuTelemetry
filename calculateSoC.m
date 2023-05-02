function [calculatedTimes, soc] = calculateSoC(times, volt, curr, parallelResistance, series, parallel)
%Function for calculating SoC based on a lookup table and stabilised
%voltage (with offset for voltage drop on the battery resistance)
%   Detailed explanation goes here
step = 250; %multiply by 20ms to get how often the value will get returned
len = length(times);
soc_percent = [100, 98.05, 92.58, 79.27, 73.9, 69.25, 64.5, 59.6, 52, 46, 40.75, 35.9, 31.6, 28.2, 22.4, 18.75, 15.9, 13.55, 11.65, 10, 8.35, 6.65, 5.2, 4.05, 3.2, 2.5, 2, 1.55, 1.22, 0.95, 0.71, 0.5, 0.32, 0.15, 0];
soc_voltages = 4.2:-0.05:2.5;

calculatedTimes = times((1+step):step:len);
stabilisedVoltages = volt(1:len)/series + curr(1:len)*parallelResistance/parallel;  
soc = zeros(1, length(calculatedTimes));
for i=1:step:(len-step)
    medianSVolt = median(stabilisedVoltages(i:i+step));
    soc(fix(i/step)+1) = interp1(soc_voltages, soc_percent, medianSVolt);
end
end