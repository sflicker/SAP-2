library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity clock_controller is

    Port(
        clk_in : IN STD_LOGIC;
        prog_run_switch : IN STD_LOGIC;  -- prog / run switch (prog=0, run=1)
        step_toggle : IN STD_LOGIC;        -- single step  when high
        manual_auto_switch : IN STD_LOGIC;        -- manual/auto mode. 0 manual, 1 auto
        hltbar : in STD_LOGIC;      -- 
        clrbar : in STD_LOGIC;
        clk_out : OUT STD_LOGIC;
        clkbar_out : OUT STD_LOGIC
    );
end clock_controller;

architecture behavioral of clock_controller is
    signal or_out : STD_LOGIC;
    signal and1_out : STD_LOGIC;
    signal and2_out : STD_LOGIC;
begin

    -- single_pulse_generator : entity work.single_pulse_generator
    --     port map(
    --         clk => clk_out_1HZ,
    --         start => pulse,
    --         pulse_out => clock_pulse
    --     );
    
    clk_out <= or_out and hltbar and prog_run_switch;
    clkbar_out <= not clk_out;
    or_out <= and1_out or and2_out;
    and2_out <= not manual_auto_switch and step_toggle and hltbar;
    and1_out <= clk_in and manual_auto_switch and hltbar and clrbar;
    
    
end architecture behavioral;
