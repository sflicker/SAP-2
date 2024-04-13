library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 16 bit RAM
-- asynchronous
entity ram_bank is
    Port ( 
           clk : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR(15 downto 0);     -- 8 bit addr
           data_in : in STD_LOGIC_VECTOR(7 downto 0);   -- 8 bit data
           write_enable : in STD_LOGIC;                 -- load data at addr - active hit
           data_out : out STD_LOGIC_VECTOR(7 downto 0)  -- data out from addr
           ); 
end ram_bank;

architecture Behavioral of ram_bank is
    attribute ram_style : string;
    type RAM_TYPE is array(0 to 2**16-1) of STD_LOGIC_VECTOR(7 downto 0);
    signal RAM : RAM_TYPE := (
        0 => "00111110",         -- 0H MVI A, 01H
        1 => "00000001",            
        2 => "00000110",         -- 2H MVI B, 02H
        3 => "00000010",         -- 
        4 => "00001110",         -- 4H MVI C, 03H 
        5 => "00000011",         -- 
        6 => "10000000",         -- ADD B
        7 => "10000001",         -- ADD C
        8 => "00111100",         -- INR A
        9 => "00000100",         -- INR B
        10 => "00001100",         -- INR c
        11 => "00111101",         -- DEC A
        12 => "00000101",         -- DEC B
        13 => "00001101",         -- DEC C
        14 => "10100000",         -- ANA B
        15 => "10100001",         -- ANA C
        16 => "10010000",         -- SUB B
        17 => "10010001",         -- SUB C
        18 => "00111010",         -- LDA 0016
        19 => "00010110",             
        20 => "00000000",
        21 => "01110110",         -- HLT
        22 => "10111100",         -- VALUE BC
        others => (others => '0'));
        -- default program if necessary/desired
        -- 0 => "00001001",         -- OH   LDA 9H
        -- 1 => "00011010",         -- 1H   ADD AH
        -- 2 => "00011011",         -- 2H   ADD BH
        -- 3 => "00101100",         -- 3H   SUB CH
        -- 4 => "11100000",         -- 4H   OUT
        -- 5 => "11110000",         -- 5H   HLT
        -- 6 => "00000000",         -- 6H
        -- 7 => "00000000",         -- 7H
        -- 8 => "00000000",         -- 8H
        -- 9 => "00010000",         -- 9H   10H
        -- 10 => "00010100",         -- AH   14H
        -- 11 => "00011000",         -- BH   18H
        -- 12 => "00100000",         -- CH   20H
        --others => (others => '0'));
    attribute ram_style of RAM : signal is "block";
begin
    -- dont use clock for ram

    process(clk, addr, write_enable, data_in)
    begin
        if rising_edge(clk) then
            Report "Ram_Bank - write_enable: " & to_string(write_enable) &
                ", addr: " & to_string(addr);
            if write_enable = '1' then
                RAM(to_integer(unsigned(addr))) <= data_in;
--                data_out <= data_in;
            else 
                data_out <= RAM(to_integer(unsigned(addr)));
            end if;
            Report "Ram_Bank - data_out: " & to_string(data_out);
        end if;
    end process;
end Behavioral;
