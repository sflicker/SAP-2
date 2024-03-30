----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2024 01:07:03 AM
-- Design Name: 
-- Module Name: IR - Behavioral
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

entity IR is
    Port ( clk : in STD_LOGIC;
           clr : in STD_LOGIC;
           ir_in : in STD_LOGIC_VECTOR(7 downto 0);
           LIBar : in STD_LOGIC;
           opcode_out : out STD_LOGIC_VECTOR(3 downto 0);
           operand_out : out STD_LOGIC_VECTOR(3 downto 0)
           );
end IR;

architecture Behavioral of IR is
    
begin
    process(clk)
        variable internal_data : std_logic_vector(7 downto 0);
    begin
        if clr = '1' then
            opcode_out <= "0000";
        elsif rising_edge(clk) and LIBar = '0' then
            internal_data := ir_in;
            opcode_out <= internal_data(7 downto 4);
            operand_out <= internal_data(3 downto 0);
        end if;
    end process;
    
end Behavioral;
