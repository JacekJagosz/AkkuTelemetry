function [oTimestamp, times, v]=readSensorsInFolder(filenamesToRead, sFolderPath)
    %filenamesToRead = ["_TEL_HVBMS_CURR.txt", "_TEL_HVBMS_MAXCVOLT.txt", "_TEL_HVBMS_MINCVOLT.txt"];
    %sFolderPath='/home/jacek/Dokumenty/Matlab/Testy LEM MotoPark/lem_logi_motopark_30102020/20201030_100139001723_decoded';
    firstFileName = erase(sFolderPath, '_decoded');
    %get first part of folder name
    firstFileName = reverse(extractBetween(reverse(firstFileName), 1, filesep)) %filesep returns '/' on Linux and '\' on Windows
    %filenamesToRead %check if it was passed correctly
    %strcat(sFolderPath, filesep, firstFileName, filenamesToRead(1)) %check if file path was stripped correctly
    for i=1:length(filenamesToRead)
        fid_1 = fopen(strcat(sFolderPath, filesep, firstFileName, filenamesToRead(i)), 'r');
        c=fscanf(fid_1, '%c');
        w=splitlines(c);
        w=split(w(1:(length(w)-1)));
        if i==1
            v = zeros(length(w), length(filenamesToRead));
        end
        v(:,i) = str2double((strrep(w(:, 2), ',','.'))); %replace , with . because in some logs , was used as a decimal separator
        fclose(fid_1);
    end
    oTimestamp=w(:, 1);
    times=zeros(1, length(oTimestamp));
    for i=1:length(oTimestamp)
        times(i) = cellfun(@(x)str2double(x),regexp(char(oTimestamp(i)),':','split'))*[3600000;60000;1000;1;0.001];
    end
    %our latest BMS master sometimes sends garbagge CURR data. So let's at
    %least delete clearly impossible data points
    %peaks only have certain values, we can filter out those specific ones
    for i=1:length(oTimestamp)
        if v(i,1) > 200 || v(i,1) == 65.5
            v(i,1) = v(i-1,1);
        end
    end
end