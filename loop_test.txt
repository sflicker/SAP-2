00001110        00H       MVI C, 10H        0EH     -- store 10H in C
00010000        01H                         10H        
00001101        02H       DCR C             0DH     -- C = C - 1
11001010        03H       JZ 0009H          CAH     -- jump to end if c=0 (zero flag high)
00001001        04H                         09H 
00000000        05H                         00H 
11000011        06H       JMP 0002H         C3H     -- other wise jump to beginning of loop
00000010        07H                         02H
00000000        08H                         00H 
01110110        09H       HLT               76H      -- stop program execution