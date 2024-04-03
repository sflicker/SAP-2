library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mem_test_top_tb is
end;

architecture rtl of mem_test_top_tb is
signal clk_sig : STD_LOGIC;
signal rst_sig : STD_LOGIC;
begin
    CLK : entity work.clock
        port map ( clk => clk_sig );

    MT : entity work.mem_test_top
        port map ( clk => clk_sig, rst => rst_sig );

end rtl;
