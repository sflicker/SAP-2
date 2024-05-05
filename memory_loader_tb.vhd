library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

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
    signal program_bytes : t_byte_array(0 to 4096);
    signal program_size : unsigned(15 downto 0);
    signal total_size : unsigned(15 downto 0);
    signal program_size_bytes : t_byte_array(0 to 1);
    signal program_addr : t_byte_array(0 to 1);
    signal r_checksum : unsigned(7 downto 0) := (others => '0');
    signal r_checksum_bytes : t_byte_array(0 to 0);

    procedure wait_cycles(signal clk : in std_logic; cycles : in natural) is
    begin
        for i in 1 to cycles loop
            wait until rising_edge(clk);
        end loop;
    end procedure wait_cycles;

    procedure load_program_bytes(constant file_name : String;
            signal data_size : out unsigned(15 downto 0);
            signal data_bytes : out t_byte_array
        ) is
        File f : TEXT OPEN READ_MODE is file_name;
        variable l : LINE;
        variable data_in : std_logic_vector(7 downto 0);
        variable pos : integer := 0;
        variable data : std_logic_vector(7 downto 0);
    begin 
        while not endfile(f) loop
            readline(f, l);
            bread(l, data_in);
            data_bytes(pos) <= data_in;
            pos := pos + 1;
        end loop;
        data_size <= unsigned(to_unsigned(pos, 16));
        wait for 0 ns;
    end; 

    procedure send_bytes_to_loader (
        signal clk : in std_logic;
        constant data_size : in integer;
        constant data : in t_byte_array; 
        signal tx_data : out std_logic_vector(7 downto 0);
        signal tx_data_dv : out std_logic;
        signal tx_active : in STD_LOGIC) is
    begin
        for i in 0 to data_size -1 loop
            Report "Sending byte: " & to_string(data(i));
            tx_data <= data(i);
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

    procedure receive_and_validate_bytes (
        signal clk : in std_logic;
        constant valid_data_size : in integer;
        constant valid_data : in t_byte_array; 
        signal response_data : in std_logic_vector(7 downto 0);
        signal response_dv : in std_logic
    ) is
    begin
        Report "Receiving and Validating " & to_string(valid_data_size) & " bytes.";
        for i in 0 to valid_data_size - 1 loop
            wait until response_dv = '1';
            Report "Receiving Bytes - response_dv: " & to_string(response_dv) & 
                ", " & to_string(response_data) & 
                ", i: " & to_string(i) & ", valid_data(i): " & to_string(valid_data(i));
            Assert response_data = valid_data(i) report "Incorrect Value" severity error;
            wait until response_dv = '0';
        end loop;
        Report "Finished matching reply bytes.";
    end;

    procedure checksum_bytes(
        constant data_size : in integer;
        constant data : in t_byte_array; 
        signal checksum : inout unsigned(7 downto 0)
    ) is
    begin
        Report "Checksum=" & to_string(checksum);
        for i in 0 to data_size - 1 loop
            Report "i=" & to_string(i) & ", Applying " & to_string(unsigned(data(i))) & " to checksum";
            checksum <= checksum xor unsigned(data(i));
            wait for 0 ns;
            Report "Checksum=" & to_string(checksum);
        end loop;
        Report "Checksum=" & to_string(checksum);
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
        load_program_bytes("test_program_1.txt", program_size, program_bytes);
        wait until rising_edge(w_clk);
        send_bytes_to_loader(w_clk, c_load_str'length, c_load_str, r_tb_tx_byte, r_tb_tx_dv, w_tb_tx_active);
        receive_and_validate_bytes(w_clk, c_ready_str'length, c_ready_str, w_to_tb_rx_byte, w_to_tb_rx_dv);
        
        total_size <= program_size + 4;
        wait for 0 ns;
        program_size_bytes(0) <= std_logic_vector(total_size(7 downto 0));
        program_size_bytes(1) <= std_logic_vector(total_size(15 downto 8));
        wait for 0 ns;
    
--        send_bytes_to_loader(w_clk, 2, program_size_bytes, r_tb_tx_byte, r_tb_tx_dv, w_tb_tx_active);
        
        program_addr(0) <= (others => '0');
        program_addr(1) <= "00100000";

        wait for 0 ns;
        -- send total size as byte array to loader
        send_bytes_to_loader(w_clk, 2, program_size_bytes, r_tb_tx_byte, r_tb_tx_dv, w_tb_tx_active);
        checksum_bytes(2, program_size_bytes, r_checksum);

        wait for 0 ns;
        -- send address to as byte array to loader
        send_bytes_to_loader(w_clk, 2, program_addr, r_tb_tx_byte, r_tb_tx_dv, w_tb_tx_active);
        checksum_bytes(2, program_addr, r_checksum);

        wait for 0 ns;
        -- send program as byte array to loader
        send_bytes_to_loader(w_clk, to_integer(program_size), program_bytes, r_tb_tx_byte, r_tb_tx_dv, w_tb_tx_active);
        checksum_bytes(to_integer(program_size), program_bytes, r_checksum);
        -- receive checksum
        wait for 0 ns;
        Report "Checksum calculated by Test Bench=" & to_string(r_checksum);

        r_checksum_bytes(0) <= std_logic_vector(r_checksum);
        wait for 0 ns;
        receive_and_validate_bytes(w_clk, r_checksum_bytes'length, r_checksum_bytes, w_to_tb_rx_byte, w_to_tb_rx_dv);

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

