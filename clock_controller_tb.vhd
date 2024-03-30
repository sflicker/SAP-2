library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity clock_controller_tb is
end clock_controller_tb;

architecture behavior of clock_controller_tb is
    signal clk : STD_LOGIC;
    signal step_sig : STD_LOGIC := '0';
    signal auto_sig : STD_LOGIC := '0';
    signal hltbar_sig : STD_LOGIC := '1';
    signal clrbar_sig : STD_LOGIC := '1';
    signal clk_out_sig : STD_LOGIC := '1';
    signal clkbar_out_sig : STD_LOGIC := '1'; 
begin

    CLOCK : entity work.clock
        port map (
            clk => clk
        );

    LUT : entity work.clock_controller
        port map(
            clk_in => clk,
            step => step_sig,
            auto => auto_sig,
            hltbar => hltbar_sig,
            clrbar => clrbar_sig,
            clk_out => clk_out_sig,
            clkbar_out => clkbar_out_sig
        );

    TC : process
    begin
        wait for 100 ns;
        auto_sig <= '1';

        wait for 200 ns;
        auto_sig <= '0';

        wait for 200 ns;
        step_sig <= '1';
        wait for 250 ns;
        step_sig <= '0';
        wait for 50 ns;

        auto_sig <= '1';
        wait for 200 ns;
        hltbar_sig <= '0';

        wait for 100 ns;
        hltbar_sig <= '1';

        wait for 100 ns;
        clrbar_sig <= '0';

        wait for 100 ns;
        clrbar_sig <= '1';

        wait;
    end process;
end behavior;
