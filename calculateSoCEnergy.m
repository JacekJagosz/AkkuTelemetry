function [calculatedTimes, soc] = calculateSoCEnergy(times, volt, curr, parallelResistance, series, parallel)
%Function for calculating SoC based on initial voltage, power draw and heat
%losses
len = length(times);
soc_percent = [100, 98.05, 92.58, 79.27, 73.9, 69.25, 64.5, 59.6, 52, 46, 40.75, 35.9, 31.6, 28.2, 22.4, 18.75, 15.9, 13.55, 11.65, 10, 8.35, 6.65, 5.2, 4.05, 3.2, 2.5, 2, 1.55, 1.22, 0.95, 0.71, 0.5, 0.32, 0.15, 0];
soc_voltages = 4.2:-0.05:2.5;
pack_energy = 10.8 * 612; %Wh
remaining_energy = zeros(1, len);
remaining_energy(1) = interp1(soc_voltages, soc_percent, volt(1)/series) /100.0 * pack_energy;

%stabilisedVoltages = volt(1:len) + curr(1:len)*parallelResistance;  
%soc = zeros(1, length(calculatedTimes));
for i=2:len
    remaining_energy(i) = remaining_energy(i-1) - (volt(i)*curr(i) + curr(i)*curr(i)*(parallelResistance*series/parallel))*(times(i)-times(i-1))/1000/3600;
    %medianSVolt = stabilisedVoltages(i:i+step);
    %soc(fix(i/step)+1) = interp1(soc_voltages, soc_percent, medianSVolt);
end
%calculatedTimes = times(1:step:(len-step));
calculatedTimes = times;
soc = remaining_energy./pack_energy.*100;
end