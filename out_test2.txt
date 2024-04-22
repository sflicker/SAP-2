    00111110         -- 00H   MVI A, 48H        3EH        -- load 48H into accumulator
    01001000         -- 01H                     48H
    11010011         -- 03H   OUT 3             D3H        -- output accumulator to port 3
    00000011         -- 04H                     03H
    00111110         -- 05H   MVI A, 62H        3EH        -- load 62H into accumulator  
    01100010         -- 06H                     62H
    11010011         -- 07H   OUT 4             D3H         -- output accumulator to port 4
    00000100         -- 08H                     04H     
    01110110         -- 0AH   HLT               76H        -- stop program execution