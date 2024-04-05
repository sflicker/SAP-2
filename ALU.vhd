----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2024 11:00:19 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
    Port ( Op : in STD_LOGIC;
           input_1 : in STD_LOGIC_VECTOR(7 downto 0);
           input_2 : in STD_LOGIC_VECTOR(7 downto 0);
           alu_out : out STD_LOGIC_VECTOR(7 downto 0);
           minus_flag : out STD_LOGIC;
           equal_flag : out STD_LOGIC;
    );
end ALU;

architecture Behavioral of ALU is
begin
    alu_out <= std_logic_vector(unsigned(a) + unsigned(b)) when Su = '0' else
              std_logic_vector(unsigned(a) - unsigned(b)) when Su = '1' else
              (others => '0');
end Behavioral;
