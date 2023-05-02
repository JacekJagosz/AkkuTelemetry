function [calculatedTimes, medianSVolt, ampLimit] = calculateSafePwrLimit(times, volt, curr, resistance, series, parallel)
%Function for stabilising voltages for voltage drop and calculating pwr
%limit so the minvolt won't trigger
step = 250; %multiply by 20ms to get how often the value will get returned
len = length(times);
minVolt = 2.2; %Voltage we don't want to reach at no point, even with worst possible voltage drop
worstResistance = 0.03;

calculatedTimes = times((1+step):step:len);
stabilisedVoltages = volt(1:len)/series + curr(1:len)*resistance/parallel;  
medianSVolt = zeros(1, length(calculatedTimes));
ampLimit = zeros(1, length(calculatedTimes));
for i=1:step:(len-step)
     temp = median(stabilisedVoltages(i:i+step));
     medianSVolt(fix(i/step)+1) = temp;
     if temp > minVolt + worstResistance/parallel*30*parallel
         ampLimit(fix(i/step)+1) = floor(30*parallel);
     elseif temp < 2.5
         ampLimit(fix(i/step)+1) = floor((2.5-minVolt) / (worstResistance/parallel));
     else
         ampLimit(fix(i/step)+1) = floor(floor((temp-minVolt)*10)/10 / (worstResistance/parallel));
     end
end
end