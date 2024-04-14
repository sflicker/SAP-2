----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2024 10:12:11 PM
-- Design Name: 
-- Module Name: proc_top_tb - Behavioral
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

-- Tests
-- PowerOn    - just initiallize but don't run
-- Execute    - initialize then run

entity proc_top_tb is
    generic (
        Test_Name : String := "Execute"
    );
end proc_top_tb;

architecture Behavioral of proc_top_tb is
signal s7_anodes_out : STD_LOGIC_VECTOR(3 downto 0);
signal s7_cathodes_out : STD_LOGIC_VECTOR(6 downto 0);
signal rst : STD_LOGIC;
signal clk : STD_LOGIC;
signal run_mode : STD_LOGIC;
signal run_toggle : STD_LOGIC;
signal pulse : STD_LOGIC;
signal hltbar_sig : STD_LOGIC;
signal addr_sig : STD_LOGIC_VECTOR(15 downto 0);
signal data_sig : STD_LOGIC_VECTOR(7 downto 0);
signal S2_prog_run_switch_sig : STD_LOGIC;
signal S4_read_write_switch_sig : STD_LOGIC;
signal S5_clear_start_sig : STD_LOGIC;
signal S6_step_toggle_sig : STD_LOGIC;
signal S7_manual_auto_switch_sig : STD_LOGIC;
signal memory_write_toggle_sig : STD_LOGIC;
signal clrbar_sig : STD_LOGIC;
signal data_out_sig : STD_LOGIC_VECTOR(7 downto 0);

type mem_array_type is array (natural range <>) of std_logic_vector(7 downto 0);

-- procedure load_program (FILE identifier: TEXT, )
--     file program_file : text open read_mode is "test_program_1.txt";
--     variable row : line;
--     varaible row_counter : integer := 0;
-- begin
--     while not endfile(program_file) loop
--         readline(program_file,row);
--         bread(row,)
--     end while;
-- end procedure;

constant init_mem : mem_array_type := (
    b"00111110",         -- 0H MVI A, 01H
    b"00000001",            
    b"00000110",         -- 2H MVI B, 02H
    b"00000010",         -- 
    b"00001110",         -- 4H MVI C, 03H 
    b"00000011",         -- 
    b"10000000",         -- ADD B
    b"10000001",         -- ADD C
    b"00111100",         -- INR A
    b"00000100",         -- INR B
    b"00001100",         -- INR c
    b"00111101",         -- DEC A
    b"00000101",         -- DEC B
    b"00001101",         -- DEC C
    b"10100000",         -- ANA B
    b"10100001",         -- ANA C
    b"10010000",         -- SUB B
    b"10010001",         -- SUB C
    b"01110110"         -- HLT
);        
begin
    proc_top : entity work.proc_top
        generic map (
            SIMULATION_MODE => true
        )
        port map(
            clk_ext => clk,
            S1_addr_in => addr_sig,
            S3_data_in => data_sig,
            S2_prog_run_switch => S2_prog_run_switch_sig,
            S4_read_write_switch => S4_read_write_switch_sig,
            S5_clear_start => S5_clear_start_sig,
            S6_step_toggle => S6_step_toggle_sig,
            S7_manual_auto_switch => S7_manual_auto_switch_sig,
            memory_access_clk => memory_write_toggle_sig,
            data_out => data_out_sig,
            running => open,
            s7_anodes_out => s7_anodes_out,
            s7_cathodes_out => s7_cathodes_out
        );

    -- generate a 1HZ clock

    clock : entity work.clock
        port map(
            clk => clk
        );

    test: process

    begin

        if Test_Name = "PowerOn" then
            Report "Starting SAP-2 PowerOn Test";
            hltbar_sig <= '1';
            wait for 200 ns;
        elsif Test_Name = "Execute" then

            Report "Starting SAP-2 Execute Test";
            S5_clear_start_sig <= '1';
            S2_prog_run_switch_sig <= '0';
            S7_manual_auto_switch_sig <= '0';
            S6_step_toggle_sig <= '0';
            wait for 200 ns;
            S5_clear_start_sig <= '0';
            wait for 105 ns;
            S2_prog_run_switch_sig <= '1';
            S7_manual_auto_switch_sig <= '1';

            wait for 300 ns;
        elsif Test_Name = "LoadProgram" then
            Report "Starting SAP-2 Load Program Test";
            S2_prog_run_switch_sig <= '0';
            S7_manual_auto_switch_sig <= '0';
            S4_read_write_switch_sig <= '1';
            wait for 100 ns;

            for i in init_mem'range loop
                memory_write_toggle_sig <= '0';
                wait for 100 ns;
                addr_sig <= std_logic_vector(to_unsigned(i, addr_sig'length));
                wait for 100 ns;
                data_sig <= init_mem(i);
                wait for 100 ns;
                S4_read_write_switch_sig <= '1';
                Report "Writing value " & to_string(init_mem(i)) & " to addr " & to_string(addr_sig);
                memory_write_toggle_sig <= '1';
                wait for 100 ns;
                memory_write_toggle_sig <= '0';
                wait for 100 ns;

                -- read back in
                S4_read_write_switch_sig <= '0';
                wait for 100 ns;
                memory_write_toggle_sig <= '1';
                wait for 100 ns;
                memory_write_toggle_sig <= '0';
                Report "Value retrieved from addr " & to_string(addr_sig) & " is " & to_string(data_out_sig);

            end loop; 

            -- Report "Finished Loading Program";
            -- Report "Now Executing";
            -- wait for 200 ns;
            -- S5_clear_start_sig <= '0';
            -- wait for 105 ns;
            -- S2_prog_run_switch_sig <= '1';
            -- S7_manual_auto_switch_sig <= '1';


        end if; 
        wait;
    end process;

end Behavioral;
