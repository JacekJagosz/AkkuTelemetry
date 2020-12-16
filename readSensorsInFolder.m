function [oTimestamp, times, v]=readSensorsInFolder(filenamesToRead, sFolderPath)
    %filenamesToRead = ["_TEL_HVBMS_CURR.txt", "_TEL_HVBMS_MAXCVOLT.txt", "_TEL_HVBMS_MINCVOLT.txt"];
    %sFolderPath='/home/jacek/Dokumenty/Matlab/Testy LEM MotoPark/lem_logi_motopark_30102020/20201030_092123662678_decoded';
    %sFolderPath='/home/jacek/Dokumenty/Matlab/Testy LEM MotoPark/lem_logi_motopark_30102020/20201030_100139001723_decoded';
    firstFileName = erase(sFolderPath, '_decoded')
    %get first part of folder name
    firstFileName = reverse(extractBetween(reverse(firstFileName), 1, '/'))
    %filenamesToRead %check if it was passed correctly
    %strcat(sFolderPath, '/', firstFileName, filenamesToRead(1)) %check if file path was stripped correctly
    for i=1:length(filenamesToRead)
        fid_1 = fopen(strcat(sFolderPath, '/', firstFileName, filenamesToRead(i)), 'r');
        c=fscanf(fid_1, '%c');
        w=splitlines(c);
        w=split(w(1:(length(w)-1)));
        v(:,i) = str2double((strrep(w(:, 2), ',','.')));
        fclose(fid_1);
    end
    times=zeros(1, length(w));
    for i=1:length(w)
        times(i) = cellfun(@(x)str2double(x),regexp(char(w(i,1)),':','split'))*[3600000;60000;1000;1;0.001];
    end
    
    oTimestamp=w(:, 1);
end