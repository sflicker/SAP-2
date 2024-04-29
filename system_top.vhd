library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity system_top is
    port(
        i_clk : STD_LOGIC;
        i_reset : STD_LOGIC;
    );
end system_top;

architecture rtl of system_top is
    signal w_clk_display_refresh_1kHZ : STD_LOGIC;
    signal w_processor_clock_1MHZ : STD_LOGIC;

begin
    display_clock_divider : entity work.clock_divider
        generic map(g_DIV_FACTOR => 100000)
        port map(
            i_clk => i_clk,
            i_reset => i_reset,
            o_clk => w_clk_display_refresh_1kHZ;
        );

    processor_clock_divider : entity work.clock_divider
        generic map(g_DIV_FACTOR => 100)
        port map(
            i_clk => i_clk,
            i_reset => i_reset,
            o_clk => w_processor_clock_1MHZ;
        );  

    processor_clock_controller : entity work.clock_controller
        port map (
            clk_in => w_processor_clock_1MHZ,
            prog_run_switch => S2_prog_run_switch,
            step_toggle => S6_step_toggle,
            manual_auto_switch => S7_manual_auto_switch,
            hltbar => hltbar_sig,
            clrbar => clrbar_sig,
            clk_out => clk_sys_sig,
            clkbar_out => clkbar_sys_sig
        );