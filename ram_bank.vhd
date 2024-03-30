----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2024 06:57:56 PM
-- Design Name: 
-- Module Name: ram_bank - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram_bank is
    Port ( clk : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR(3 downto 0);  -- 4 bit addr
           ram_data_in : in STD_LOGIC_VECTOR(7 downto 0);   -- 8 bit data
           LBar : in STD_LOGIC;                     -- load data to addr - active low
           ram_data_out : out STD_LOGIC_VECTOR(7 downto 0)               -- data out from addr
           ); 
end ram_bank;

architecture Behavioral of ram_bank is
    type RAM_TYPE is array(0 to 15) of STD_LOGIC_VECTOR(7 downto 0);
    constant RAM : RAM_TYPE := (
        0 => "00001001",         -- OH   LDA 9H
        1 => "00011010",         -- 1H   ADD AH
        2 => "00011011",         -- 2H   ADD BH
        3 => "00101100",         -- 3H   SUB CH
        4 => "11100000",         -- 4H   OUT
        5 => "11110000",         -- 5H   HLT
        6 => "00000000",         -- 6H
        7 => "00000000",         -- 7H
        8 => "00000000",         -- 8H
        9 => "00010000",         -- 9H   10H
        10 => "00010100",         -- AH   14H
        11 => "00011000",         -- BH   18H
        12 => "00100000",         -- CH   20H
        others => (others => '0'));
begin
    -- dont use clock for ram

    process(addr)
    begin
        ram_data_out <= RAM(to_integer(unsigned(addr)));
    end process;
--     process(clk) 
--     begin    
--         if rising_edge(clk) then
--         -- current version is read only memory
-- --            if LBar = '0' then
-- --                RAM(to_integer(unsigned(addr))) <= data_in;
-- --            end if;
--             ram_data_out <= RAM(to_integer(unsigned(addr)));
--         end if;
--     end process;
end Behavioral;
