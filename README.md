# AkkuTelemetry
The `CodeFromGui.m` doesn't serve any purpose apart from being able to see the code of the GUI and being able to track changes with Git, so if you want to see the bulk of the code, go there.
How latest version of my GUI looks like:
![image](https://user-images.githubusercontent.com/28653965/180667979-d10dc042-73b9-49c8-9be2-f0741da06945.png)
I wrote an instruction, only in Polish for now. The GUI will only be useful for my teammembers of AGH Racing anyways, and only for our type of writing telemetry:

## Instalacja
Wystarczy pobrać i uruchomić instalator. Jeżeli nie zainstalowało się wcześniej Matlab Runtime instalacja trochę potrwa.
Można też uruchomić plik `GUI1.mlapp`, co polecam jeżeli ma się zainstalowanego Matlaba.

## Użycie
Telemtrię można wziąć chociażby z postu Krzysia (na kanale `Raporty` Akumulatora), np. "Testy LEM MotoPark.7z".
Po uruchomieniu nakładki klikamy choose folder i wybieramy najgłębszy folder w telemetrii, jak np. lem_logi_motopark_30102020\20201030_100139001723_decoded. 
W trakcie odczytu z pliku przycisk będzie miał kolor czerwony. Po pojawieniu się wykresów możemy używać suwaków by wybierać początkowy i końcowy punkt, czyli "przybliżać" wykres. Trzeba zaznaczyć 1 okrążenie i upewnić że czas w lewym górnym rogu pokrywa się z rzeczywistym.
Gotowe!

## O GUI
Zrobiłem GUI w Matlabie do odczytu telemetrii, z zamysłem by było bardzo proste w użyciu. Wystarczy je uruchomić, wybrać folder i od razu pokazują się wykresy, a potem dostosować przedział za pomocą 2 suwaków. Celem nakładki było wyliczenie ile energii jest zużywane podczas jednego okrążenia, ale by dodać na wykres w tej nakładce dane z kolejnego czujnika wystarczą 3 linijki kodu. Można je łatwo przerobić by spełniało inne funkcje.
![image](https://user-images.githubusercontent.com/28653965/180668134-fe966653-bcc5-4a94-9859-f08007fcd6dd.png)
