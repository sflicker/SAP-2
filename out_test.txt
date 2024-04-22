    00111110         -- 00H   MVI A, 48H        3EH        -- load 48H into accumulator
    01001000         -- 01H                     48H
    11010011         -- 03H   OUT 3             D3H        -- output accumulator to port 3
    00000011         -- 04H                     03H
    01110110         -- 05H   HLT               76H        -- stop program execution