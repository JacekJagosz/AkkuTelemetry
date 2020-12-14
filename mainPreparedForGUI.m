clear
clc
filenamesToRead = ["_TEL_HVBMS_CURR.txt", "_TEL_HVBMS_MAXCVOLT.txt", "_TEL_HVBMS_MINCVOLT.txt"];
sFolderPath='/home/jacek/Dokumenty/Matlab/Testy LEM MotoPark/lem_logi_motopark_30102020/20201030_100139001723_decoded';
[oTimestamps, times, val] = readSensorsInFolder(filenamesToRead, sFolderPath);
plot(times, val(:,1))