library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_RX_TB is
end UART_RX_TB;

architecture behavioral of UART_RX_TB is
    constant c_clk_period :time := 10 ns;
    constant c_clk_per_bit : integer := 10416;
    constant c_bit_period : time := 104167 ns;
    signal r_clock : std_logic := '0';
    signal w_rx_byte : std_logic_vector(7 downto 0);
    signal r_rx_serial : std_logic := '1';
    signal r_rx_dv : std_logic;

    procedure UART_WRITE_BYTE (
        i_data_in : in std_logic_vector(7 downto 0);
        signal o_serial :out std_logic) is
        begin
            Report "Writing Test Byte " & to_string(i_data_in);
            o_serial <= '0';        -- start bit
            wait for c_bit_period;

            for ii in 0 to 7 loop
                o_serial <= i_data_in(ii);
                wait for c_bit_period;
            end loop;

            o_serial <= '1';    -- stop bit
            wait for c_bit_period;
            Report "Finished Writing Test Byte";
        end procedure;
    
    begin
        UART_RX_INST: entity work.UART_RX
        generic map (
            g_CLKS_PER_BIT => c_clk_per_bit
        )
        port map (
            i_clk => r_clock,
            i_rx_serial => r_rx_serial,
            o_rx_dv => r_rx_dv,
            o_rx_byte => w_rx_byte
        );

    r_clock <= not r_clock after c_clk_period/2;

    process
    begin
        Report "Starting Test";
        wait until rising_edge(r_clock);
        UART_WRITE_BYTE(X"37", r_rx_serial);
        wait until rising_edge(r_clock);

        Report "Test Result = " & to_string(w_rx_byte);
        if w_rx_byte = X"37" then
            Report "Test Passed" severity note;
        else
            Report "Test Failed" severity note;
        end if;

        Report "Starting Second Test";
        wait until rising_edge(r_clock);
        UART_WRITE_BYTE(X"A3", r_rx_serial);
        wait until rising_edge(r_clock);

        Report "Test Result = " & to_string(w_rx_byte);
        if w_rx_byte = X"A3" then
            Report "Test Passed" severity note;
        else
            Report "Test Failed" severity note;
        end if;


        assert false report "Tests Completed" severity failure;
    end process;
end behavioral;