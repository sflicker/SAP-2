----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/10/2024 08:04:32 PM
-- Design Name: 
-- Module Name: digit_multiplexer - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity digit_multiplexer is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           digit_sel : out STD_LOGIC_VECTOR(3 downto 0)
           );
end digit_multiplexer;

architecture Behavioral of digit_multiplexer is

begin
    process(clk, rst)
    begin
        if rst = '1' then
            digit_sel <= "0001";
        elsif rising_edge(clk) then
            digit_sel <= digit_sel(2 downto 0) & digit_sel(3);  -- shift digits
        end if;
    end process;
end Behavioral;
