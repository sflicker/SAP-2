----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2024 09:02:13 AM
-- Design Name: 
-- Module Name: passthrough_clock_converter - Behavioral
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

entity passthrough_clock_converter is
    Port ( clk_in : in STD_LOGIC;
           clrbar : in STD_LOGIC;
           clk_out : out STD_LOGIC);
end passthrough_clock_converter;

architecture Behavioral of passthrough_clock_converter is

begin
    clk_out <= clk_in when clrbar = '1' else '0';
end Behavioral;
