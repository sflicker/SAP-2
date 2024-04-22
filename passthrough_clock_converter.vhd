library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity passthrough_clock_converter is
    Port ( clk_in : in STD_LOGIC;
           clrbar : in STD_LOGIC;
           clk_out : out STD_LOGIC);
end passthrough_clock_converter;

architecture Behavioral of passthrough_clock_converter is

begin
    clk_out <= clk_in when clrbar = '1' else '0';
end Behavioral;
