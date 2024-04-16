    00111110         -- 00H     MVI A, 01H      3EH  -- move value 01H into accumulator
    00000001         -- 01H                     01H
    00110010         -- 02H     STA 0840H       32H  -- store at address 0840H (2112 in dec)
    01000000         -- 03H                     40H
    00001000         -- 04H                     08H
    00111100         -- 05H     INC A           3CH  -- ACC shoudld 02H now
    00111010         -- 06H     LDA 0840H       3AH  -- ACC should be back to 01H
    01000000         -- 07H                     40H
    00001000         -- 08H                     08H  
    01110110         -- 05H     HLT             76H  -- stop