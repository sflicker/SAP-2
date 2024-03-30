library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity proc_controller_tb is
end proc_controller_tb;

architecture behavior of proc_controller_tb is
    signal clk_tb_sig : STD_LOGIC;
    signal clk_sys_sig : STD_LOGIC;
    signal step_sig : STD_LOGIC;
    signal auto_sig : STD_LOGIC;
    signal hltbar_sig : STD_LOGIC;
    signal clrbar_sig : STD_LOGIC;
    signal clkbar_out_sig : STD_LOGIC;
    signal opcode_sig : STD_LOGIC_VECTOR(3 downto 0);
    signal wbus_sel_sig : STD_LOGIC_VECTOR(2 downto 0);
    signal Cp_sig : STD_LOGIC;
    signal LMBar_sig : STD_LOGIC;
    signal LIBar_sig : STD_LOGIC;
    signal LABar_sig : STD_LOGIC;
    signal Su_sig : STD_LOGIC;
    signal LBBar_sig : STD_LOGIC;
    signal LOBar_sig : STD_LOGIC;
begin



    CLOCK : entity work.clock
    port map (
        clk => clk_tb_sig
    );

    CLOCK_CONTROLLER : entity work.clock_controller
    port map(
        clk_in => clk_tb_sig,
        step => step_sig,
        auto => auto_sig,
        hltbar => hltbar_sig,
        clrbar => clrbar_sig,
        clk_out => clk_sys_sig,
        clkbar_out => clkbar_out_sig
    );

    UUT: entity work.proc_controller 
        port map (
            clk => clkbar_out_sig,
            clrbar => clrbar_sig,
            opcode => opcode_sig,
            wbus_sel => wbus_sel_sig,
            Cp => Cp_sig,
            LMBar => LMBar_sig,
            LIBar => LIBar_sig,
            LABar => LABar_sig,
            Su => Su_sig,
            LBBar => LBBar_sig,
            LOBar => LOBar_sig,
            HLTBar => HLTBar_sig
        );

    TB: process
    begin
        auto_sig <= '1';
        step_sig <= '0';
        clrbar_sig <= '1';
        opcode_sig <= "0000";

        wait for 600 ns;
        opcode_sig <= "0001";
        wait for 600 ns;

        opcode_sig <= "0010";
        wait for 600 ns;

        opcode_sig <= "1110";
        wait for 600 ns;

        opcode_sig <= "1111";
        wait;
    end process;

end behavior;
