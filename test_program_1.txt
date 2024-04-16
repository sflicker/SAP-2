    00111110         -- 00H     MVI A, 01H      3EH
    00000001         -- 01H                     01H
    00000110         -- 02H     MVI B, 02H      06H
    00000010         -- 03H                     02H
    00001110         -- 04H     MVI C, 03H      0EH
    00000011         -- 05H                     03H
    10000000         -- 06H     ADD B           80H
    10000001         -- 07H     ADD C           81H
    00111100         -- 08H     INR A           3CH
    00000100         -- 09H     INR B           04H
    00001100         -- 0AH     INR C           0CH
    00111101         -- 0BH     DCR A           3DH
    00000101         -- 0CH     DCR B           05H
    00001101         -- 0DH     DCR C           0DH
    10100000         -- 0EH     ANA B           A0H
    10100001         -- 0FH     ANA C           A1H
    10010000         -- 10H     SUB B           90H
    10010001         -- 11H     SUB C           91H
    01110110         -- 12H     HLT             76H