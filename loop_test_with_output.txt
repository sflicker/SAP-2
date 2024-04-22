00001110        00H       MVI C, 10H        0EH     -- store 10H in C
00010000        01H                         10H
01111001        02H       MOV A, C          79H        -- move c to a
11010011        03H       OUT 3             D3H        -- OUT 3        
00000011        04H                         03H
00001101        05H       DCR C             0DH     -- C = C - 1
11001010        06H       JZ 000CH          CAH     -- jump to end if c=0 (zero flag high)
00001100        07H                         09H 
00000000        08H                         00H 
11000011        09H       JMP 0002H         C3H     -- other wise jump to beginning of loop
00000010        0AH                         02H
00000000        0BH                         00H
01111001        0CH       MOV A, C          79H        -- move c to a
11010011        0DH       OUT 3             D3H        -- OUT 3        
00000011        OEH                         03H
01110110        0FH       HLT               76H      -- stop program execution