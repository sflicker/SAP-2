----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2024 12:43:35 AM
-- Design Name: 
-- Module Name: pc - Behavioral
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
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pc is
    Port ( 
        clkbar : in STD_LOGIC;
        clrbar : in STD_LOGIC;
        Cp : in STD_LOGIC;
        pc_out : out STD_LOGIC_VECTOR(3 downto 0)
        );
   
end pc;

architecture Behavioral of pc is
    -- signal internal_value : STD_LOGIC_VECTOR(3 downto 0) := "0000";
begin

    process(clkbar, clrbar)
        variable internal_value : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    begin
        if clrbar = '0' then
            internal_value := (others => '0');
        elsif falling_edge(clkbar) and Cp = '1' then
            internal_value := STD_LOGIC_VECTOR(unsigned(internal_value) + 1);
        end if;
        pc_out <= internal_value;
        
    end process;
end Behavioral;
