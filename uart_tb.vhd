library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_TB is
end UART_TB;

architecture behavioral of UART_TB is
    constant c_clk_period :time := 10 ns;
    constant c_clk_per_bit : integer := 10416;
    constant c_bit_period : time := 104167 ns;

    signal r_clock : std_logic := '0';
    signal r_tx_dv: std_logic;
    signal r_tx_byte : std_logic_vector(7 downto 0);
    signal w_tx_serial : std_logic;
    signal w_tx_done : std_logic;
    signal w_rx_dv : std_logic;
    signal w_rx_byte : std_logic_vector(7 downto 0);
    signal r_rx_serial : std_logic := '1';
    signal w_tx_active : std_logic;
    signal w_uart_data : std_logic;
begin

        UART_TX_INST : entity work.UART_TX
        generic map(
            g_CLKS_PER_BIT => c_clk_per_bit
        )
        port map(
            i_clk => r_clock,
            i_tx_dv => r_tx_dv,
            i_tx_byte => r_tx_byte,
            o_tx_active => w_tx_active,
            o_tx_serial => w_tx_serial,
            o_tx_done => w_tx_done
        );

        UART_RX_INST: entity work.UART_RX
        generic map (
            g_CLKS_PER_BIT => c_clk_per_bit
        )
        port map (
            i_clk => r_clock,
            i_rx_serial => w_UART_data,
            o_rx_dv => w_rx_dv,
            o_rx_byte => w_rx_byte
        );

    w_UART_data <= w_tx_serial  when w_tx_active = '1' else '1';

    r_clock <= not r_clock after c_clk_period/2;

    process
    begin
        Report "Starting Test";
        wait until rising_edge(r_clock);
        wait until rising_edge(r_clock);
        Report "Setting byte to transmit to 0x37 and tx_dv to high";
        r_tx_byte <= X"37";
        r_tx_dv <= '1';
        wait until rising_edge(r_clock);
        r_tx_dv <= '0';

        wait until rising_edge(w_rx_dv);

        Report "Test Result = " & to_string(w_rx_byte);
        if w_rx_byte = X"37" then
            Report "Test Passed" severity note;
        else
            Report "Test Failed" severity note;
        end if;

        -- Report "Starting Second Test";
        -- wait until rising_edge(r_clock);
        -- UART_WRITE_BYTE(X"A3", r_rx_serial);
        -- wait until rising_edge(r_clock);

        -- Report "Test Result = " & to_string(w_rx_byte);
        -- if w_rx_byte = X"A3" then
        --     Report "Test Passed" severity note;
        -- else
        --     Report "Test Failed" severity note;
        -- end if;


        assert false report "Tests Completed" severity failure;
    end process;
end behavioral;