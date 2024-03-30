----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2024 10:57:15 PM
-- Design Name: 
-- Module Name: B - Behavioral
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

entity B is
    Port ( clk : in STD_LOGIC;
           LBBar : in STD_LOGIC;
           b_in : in STD_LOGIC_VECTOR(7 downto 0);
           b_out : out STD_LOGIC_VECTOR(7 downto 0)
           );
end B;

architecture Behavioral of B is
    begin
    process(clk)
        variable internal_data : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
        begin
        if rising_edge(clk) and LBBar = '0' then
            internal_data := b_in;
        end if;
    b_out <= internal_data;
    end process;

end Behavioral;
