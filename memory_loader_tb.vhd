library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory_loader_tb is
end memory_loader_tb;

architecture behavioral of memory_loader_tb is
    signal w_clk : STD_LOGIC;
    signal r_reset : STD_LOGIC := '0';
    signal r_data : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal r_rx_data_dv : STD_LOGIC := '0';
    signal r_tx_active : STD_LOGIC := '0';
    signal w_response : STD_LOGIC_VECTOR(7 downto 0);
    signal w_wrt_mem_addr : STD_LOGIC_VECTOR(15 downto 0);
    signal w_wrt_mem_data : STD_LOGIC_VECTOR(7 downto 0);
    signal w_wrt_mem_we : STD_LOGIC;

    procedure wait_cycles(signal clk : in std_logic; cycles : in natural) is
    begin
        for i in 1 to cycles loop
            wait until rising_edge(clk);
        end loop;
    end procedure wait_cycles;

begin

    clock : entity work.clock
    port map(
        o_clk => w_clk
    );

    loader : entity work.memory_loader
    port map (
        i_clk => w_clk,
        i_reset => r_reset,
        i_prog_run_mode => '0',
        i_rx_data => r_rx_data,
        i_rx_data_dv => r_rx_data_dv,
        i_tx_active => r_tx_active,
        o_response => w_response,
        o_wrt_mem_addr => w_wrt_mem_addr,
        o_wrt_mem_data => w_wrt_mem_data,
        o_wrt_mem_we => w_wrt_mem_we
    );

    process
    begin
        Report "Starting Memory Loader Test";
        wait until rising_edge(w_clk);
        r_rx_data <= x"4C"; -- ascii L
        wait_cycles(w_clk, 16);
        r_rx_data <= x"4F";   --ascii O
        wait_cycles(w_clk, 16);
        r_rx_data <= x"41";      -- ascii A
        wait_cycles(w_clk, 16);
        r_rx_data <= x"4D";      -- ascii D

        wait on w_response;
        r_response_data <= w_response;
        r_tx_active <= '1';
        wait for 0 ns;

        assert r_response_data = x"52" report "Incorrect Value" severity error;
        wait_cycles(w_clk, 16);
        r_tx_active <= '0';
        wait for 0 ns;
        wait on w_response;

        r_response_data <= w_response;
        r_tx_active <= '1';
        wait for 0 ns;
        assert r_response_data = x"45" report "Incorrect Value" severity error;

    

