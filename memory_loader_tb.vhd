library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory_loader_tb is
end memory_loader_tb;

architecture behavioral of memory_loader_tb is
    constant c_clk_period :time := 10 ns;
    constant c_clk_per_bit : integer := 10416;
    constant c_bit_period : time := 104167 ns;

    signal w_clk : STD_LOGIC;
    signal r_reset : STD_LOGIC := '0';
    signal r_tx_data : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal r_tx_data_dv : STD_LOGIC := '0';
    signal r_tx_active : STD_LOGIC := '0';
    signal w_response : STD_LOGIC_VECTOR(7 downto 0);
    signal w_response_dv : STD_LOGIC;
    signal r_response_data : STD_LOGIC_VECTOR(7 downto 0);
    signal w_wrt_mem_addr : STD_LOGIC_VECTOR(15 downto 0);
    signal w_wrt_mem_data : STD_LOGIC_VECTOR(7 downto 0);
    signal w_wrt_mem_we : STD_LOGIC;

    type t_byte_array is array (natural range <>) of std_logic_vector(7 downto 0);

    constant c_load_str : t_byte_array := (x"4C", x"4F", x"41", x"4D");
    constant c_ready_str : t_byte_array := (x"52", x"45", x"41", x"44", x"59");

    procedure wait_cycles(signal clk : in std_logic; cycles : in natural) is
    begin
        for i in 1 to cycles loop
            wait until rising_edge(clk);
        end loop;
    end procedure wait_cycles;

    procedure send_load_command_str(
        signal clk : in std_logic; 
        signal tx_data : out std_logic_vector(7 downto 0);
        signal tx_data_dv : out std_logic) is
    begin
        for i in 0 to c_load_str'length-1 loop
            tx_data <= c_load_str(i);
            wait_cycles(clk, 1);
            tx_data_dv <= '1';
            wait_cycles(clk, 1);
            tx_data_dv <= '0';
            wait_cycles(clk, 16);
        end loop;
    end;

    fucntion receive_load_command_response_str(
        signal clk : in std_logic;
        signal response : in std_logic_vector(7 downto 0);
        signal response_dv : in std_logic
    ) is
    begin
        if rising_edge(clk) and response_dv = '1' then
            r_response_data <= response;
    end;

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
        i_rx_data => r_tx_data,
        i_rx_data_dv => r_tx_data_dv,
        i_tx_active => r_tx_active,
        o_response => w_response,
        o_response_dv => w_response_dv,
        o_wrt_mem_addr => w_wrt_mem_addr,
        o_wrt_mem_data => w_wrt_mem_data,
        o_wrt_mem_we => w_wrt_mem_we
    );

    sim_uart_from_UUT : process(w_clk)
        variable active_state : integer := 0;
        counter := 0;
    begin
        if rising_edge(w_clk) then
            if w_response_dv = '1' and active_state = '0' then
                active_state := '1';
                r_response_data <= w_response;
                counter := 0;
            elsif active_state = '1' then
                if counter = 10*c_clk_per_bit - 1 then
                    active_state := '0';
                else 
                    counter := counter + 1;
                end if;
            end if;
        end if;
        r_tx_active <= active_state;
    end process;

            


    uut : process
    begin
        Report "Starting Memory Loader Test";
        wait until rising_edge(w_clk);
        send_load_command_str(w_clk, r_tx_data, r_tx_data_dv);

        receive_load_command_response_str;
        wait on w_response_dv = '1';
        r_response_data <= w_response;
        r_tx_active <= '1';
        wait for 0 ns;

        assert r_response_data = x"52" report "Incorrect Value" severity error;
        wait_cycles(w_clk, 16);
        r_tx_active <= '0';
        wait for 0 ns;
        wait on w_response_dv = '1';

        r_response_data <= w_response;
        r_tx_active <= '1';
        wait for 0 ns;
        assert r_response_data = x"45" report "Incorrect Value" severity error;

    end process;
end behavioral;

