library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory_input_multiplexer is
    Port (
        prog_run_select : IN STD_LOGIC;
        prog_data_in : IN STD_LOGIC_VECTOR(7 downto 0);
        run_data_in : IN STD_LOGIC_VECTOR(7 downto 0);
        prog_addr_in : IN STD_LOGIC_VECTOR(15 downto 0);
        run_addr_in : IN STD_LOGIC_VECTOR(15 downto 0);
        prog_clk_in : IN STD_LOGIC;
        run_clk_in : IN STD_LOGIC;
        prog_write_enable : IN STD_LOGIC;
        run_write_enable : IN STD_LOGIC;
        select_data_in : OUT STD_LOGIC_VECTOR(7 downto 0);
        select_addr_in : OUT STD_LOGIC_VECTOR(15 downto 0);
        select_clk_in : OUT STD_LOGIC;
        select_write_enable : OUT STD_LOGIC
    );
end memory_input_multiplexer;

architecture behavior of memory_input_multiplexer is
begin
    select_data_in <= prog_data_in when prog_run_select = '0' else run_data_in;
    select_addr_in <= prog_addr_in when prog_run_select = '0' else run_addr_in;
    select_clk_in <= prog_clk_in when prog_run_select = '0' else run_clk_in;
    select_write_enable <= prog_write_enable when prog_run_select = '0' else run_write_enable;
end behavior;