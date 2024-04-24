library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;


entity proc_top_filebased_tb is
    Generic (
        file_name : String := "test_program_1.txt"
    );
end proc_top_filebased_tb;

architecture behavioral of proc_top_filebased_tb is
    signal clk_sig : STD_LOGIC;
    signal addr_in_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal data_in_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal prog_run_switch_switch_sig : STD_LOGIC;
    signal read_write_switch_sig : STD_LOGIC;
    signal clear_start_sig : STD_LOGIC;
    signal step_toggle_sig : STD_LOGIC;
    signal manual_auto_switch_sig : STD_LOGIC;
    signal memory_access_clk_sig : STD_LOGIC;
    signal s7_anodes_out : STD_LOGIC_VECTOR(3 downto 0);
    signal s7_cathodes_out : STD_LOGIC_VECTOR(6 downto 0);
    signal data_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal input_1_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal input_2_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal output_3_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal output_4_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal running_sig : STD_LOGIC;

begin
    
    input_1_sig <= (others => '0');
    input_2_sig <= (others => '0');

    proc_top : entity work.proc_top
    generic map (
        SIMULATION_MODE => true
    )
    port map(
        clk_ext => clk_sig,
        S1_addr_in => addr_in_sig,
        S2_prog_run_switch => prog_run_switch_switch_sig,
        S3_data_in => data_in_sig,
        S4_read_write_switch => read_write_switch_sig,
        S5_clear_start => clear_start_sig,
        S6_step_toggle => step_toggle_sig,
        S7_manual_auto_switch => manual_auto_switch_sig,
        memory_access_clk => memory_access_clk_sig,
        in_port_1 => input_1_sig,
        in_port_2 => input_2_sig,
        out_port_3 => output_3_sig,
        out_port_4 => output_4_sig,
        data_out => data_out_sig,
        running => running_sig,
        s7_anodes_out => s7_anodes_out,
        s7_cathodes_out => s7_cathodes_out
    );

-- generate a 1HZ clock

clock : entity work.clock
    port map(
        clk => clk_sig
    );
    
file_based_test : process
    FILE f : TEXT OPEN READ_MODE is file_name;
    variable l : LINE;
    variable data_in : STD_LOGIC_VECTOR(7 downto 0);
    variable counter : INTEGER := 0;
    variable address : STD_LOGIC_VECTOR(15 downto 0);
begin

    prog_run_switch_switch_sig <= '0';
    manual_auto_switch_sig <= '0';
    memory_access_clk_sig <= '0';

    REPORT "Reading Program File " & file_name & " into Memory starting at address 0";
    -- load program from file starting at address 0
    WHILE NOT ENDFILE(f) loop
        READLINE(f, l);
        BREAD(l, data_in);
        address := std_logic_vector(to_unsigned(counter, addr_in_sig'length));
        REPORT "ADDR: " & to_string(address) & ", DATA_IN: " & to_string(data_in);
        addr_in_sig <= address;
        data_in_sig <= data_in;
        read_write_switch_sig <= '1';
        wait for 100 ns;
        memory_access_clk_sig <= '1';
        wait for 100 ns;
        memory_access_clk_sig <= '0';
        read_write_switch_sig <= '0';
        wait for 100 ns;
        memory_access_clk_sig <= '1';
        wait for 100 ns;
        memory_access_clk_sig <= '0';
        REPORT "DATA_OUT: " & to_string(data_out_sig);
        counter := counter + 1;
        wait for 100 ns;
    end loop;

    wait for 100 ns;

    Report "Finished Loading Test Program into memory";

    REPORT "Resetting system";
    -- reset/clear system
    clear_start_sig <= '1';
    read_write_switch_sig <= '0';
    prog_run_switch_switch_sig <= '0';
    manual_auto_switch_sig <= '0';
    step_toggle_sig <= '0';

    wait for 200 ns;
    clear_start_sig <= '0';

    REPORT "Starting program execution";
    -- begin program execution

    wait for 100 ns;
    prog_run_switch_switch_sig <= '1';
    wait for 100 ns;
    manual_auto_switch_sig <= '1';

    wait;

end process file_based_test;
end architecture behavioral;