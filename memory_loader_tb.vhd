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
  --  signal r_tx_data : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    --signal r_tx_data_dv : STD_LOGIC := '0';
    signal r_tx_active : STD_LOGIC := '0';
    signal w_response_data : STD_LOGIC_VECTOR(7 downto 0);
    signal w_response_dv : STD_LOGIC;
    signal r_response_data : STD_LOGIC_VECTOR(7 downto 0);
    signal w_wrt_mem_addr : STD_LOGIC_VECTOR(15 downto 0);
    signal w_wrt_mem_data : STD_LOGIC_VECTOR(7 downto 0);
    signal w_wrt_mem_we : STD_LOGIC;
    signal w_to_loader_rx_byte : STD_LOGIC_VECTOR(7 downto 0);
    signal w_to_loader_rx_dv : STD_LOGIC;
    signal w_loader_tx_active : STD_LOGIC;
    signal r_tb_tx_dv :STD_LOGIC;
    signal r_tb_tx_byte : STD_LOGIC_VECTOR(7 downto 0);
    signal w_tb_tx_serial : STD_LOGIC;
    signal w_tb_tx_done : STD_LOGIC;
    signal w_loader_to_tb_serial : STD_LOGIC;
    signal w_tb_tx_active : STD_LOGIC;
    signal w_to_tb_rx_dv : STD_LOGIC;
    signal w_to_tb_rx_byte : STD_LOGIC_VECTOR(7 downto 0);
    signal r_success : STD_LOGIC;
    signal w_tx_response_done : STD_LOGIC;

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
        signal tx_data_dv : out std_logic;
        signal tx_active : in STD_LOGIC) is
    begin
        for i in 0 to c_load_str'length-1 loop
            Report "Sending byte: " & to_string(c_load_str(i));
            tx_data <= c_load_str(i);
            tx_data_dv <= '1';
            wait until tx_active = '1';
            Report "Transmitter is reporting Active";
  --          wait_cycles(clk, 1);
  --          tx_data_dv <= '0';
            wait until tx_active = '0';
            Report "Transmitter is report not Active";
            tx_data_dv <= '0';
            wait_cycles(clk, 1);
--            wait_cycles(clk, 16);
        end loop;
    end;

    procedure receive_load_command_response_str(
        signal clk : in std_logic;
        signal response_data : in std_logic_vector(7 downto 0);
        signal response_dv : in std_logic;
        signal success : out STD_LOGIC
    ) is
    begin
        for i in 0 to c_ready_str'length -1 loop
            if rising_edge(clk) and response_dv = '1' then
                if response_data = c_ready_str(i) then
                    Report "Successfully matched reply byte " & to_string(i) & " - " & to_string(c_ready_str(i));
                    success <= '1';
                else
                    Report "Failed to match reply byte " & to_string(i) & ", " & to_string(c_ready_str(i));
                    success <= '0';
                end if;
                wait until response_dv = '0';
            end if;
            Report "Finished trying to match reply bytes";
        end loop;
    end;

begin

    clock : entity work.clock
    generic map(g_CLK_PERIOD => 10 ns)
    port map(
        o_clk => w_clk
    );

    loader : entity work.memory_loader
    port map (
        i_clk => w_clk,
        i_reset => r_reset,
        i_prog_run_mode => '0',
        i_rx_data => w_to_loader_rx_byte,
        i_rx_data_dv => w_to_loader_rx_dv,
        i_tx_response_active => w_loader_tx_active,
        i_tx_response_done => w_tx_response_done,
        o_tx_response_data => w_response_data,
        o_tx_response_dv => w_response_dv,
        o_wrt_mem_addr => w_wrt_mem_addr,
        o_wrt_mem_data => w_wrt_mem_data,
        o_wrt_mem_we => w_wrt_mem_we
    );

    tb_uart_tx : entity work.UART_TX
    generic map (
        ID => "TB-UART-TX"
    )
    port map(
        i_clk => w_clk,
        i_tx_dv => r_tb_tx_dv,
        i_tx_byte => r_tb_tx_byte,
        o_tx_active => w_tb_tx_active,
        o_tx_serial => w_tb_tx_serial,
        o_tx_done => w_tb_tx_done
    );

    loader_uart_rx : entity work.UART_RX
    generic map (
        ID => "Loader-UART-RX"
    )
    port map (
        i_clk => w_clk,
        i_rx_serial => w_tb_tx_serial,
        o_rx_dv => w_to_loader_rx_dv,
        o_rx_byte => w_to_loader_rx_byte
    );

    loader_uart_tx : entity work.UART_TX
    generic map (
        ID => "Loader-UART-TX"
    )
    port map (
        i_clk => w_clk,
        i_tx_dv => w_response_dv,
        i_tx_byte => w_response_data,
        o_tx_active => w_loader_tx_active,
        o_tx_serial => w_loader_to_tb_serial,
        o_tx_done => w_tx_response_done
    );

    tb_uart_rx : entity work.UART_RX
    generic map (
        ID => "TB-UART-RX"
    )
    port map (
        i_clk => w_clk,
        i_rx_serial => w_loader_to_tb_serial,
        o_rx_dv => w_to_tb_rx_dv,
        o_rx_byte => w_to_tb_rx_byte
    );            

    uut : process
    begin
        Report "Starting Memory Loader Test";
        wait until rising_edge(w_clk);
        send_load_command_str(w_clk, r_tb_tx_byte, r_tb_tx_dv, w_tb_tx_active);

        receive_load_command_response_str(w_clk, w_to_tb_rx_byte, w_to_tb_rx_dv, r_success);
        -- wait on w_response_dv = '1';
        -- r_response_data <= w_response;
        -- r_tx_active <= '1';
        -- wait for 0 ns;

        -- assert r_response_data = x"52" report "Incorrect Value" severity error;
        -- wait_cycles(w_clk, 16);
        -- r_tx_active <= '0';
        -- wait for 0 ns;
        -- wait on w_response_dv = '1';

        -- r_response_data <= w_response;
        -- r_tx_active <= '1';
        -- wait for 0 ns;
        -- assert r_response_data = x"45" report "Incorrect Value" severity error;


        wait;

    end process;
end behavioral;

