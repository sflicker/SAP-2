library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clock is
    Generic (
        g_CLK_PERIOD : time := 100 ns
    );
    Port (
        o_clk : out STD_LOGIC := '0'
    );
end clock;

architecture behavioral of clock is
begin
    clk_process :
    process
    begin
        wait for g_CLK_PERIOD / 2;
        o_clk <= not o_clk;
    end process;
end behavioral;