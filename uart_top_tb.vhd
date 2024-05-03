library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_top_tb is
end UART_top_tb;

architecture rtl of uart_top_tb is
    constant c_clk_period :time := 10 ns;
    constant c_clk_per_bit : integer := 10416;
    constant c_bit_period : time := 104167 ns;
    signal r_clock : std_logic := '0';
    signal r_reset : std_logic := '0';
    signal w_rx_byte : std_logic_vector(7 downto 0);
    signal r_rx_serial : std_logic := '1';
    signal r_rx_dv : std_logic;
    signal w_anodes : STD_LOGIC_VECTOR(3 downto 0);
    signal w_cathodes : STD_LOGIC_VECTOR(6 downto 0);

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
    r_clock <= not r_clock after c_clk_period/2;

        UART_TOP_INST: entity work.UART_TOP
        port map (
            i_clk => r_clock,
            i_reset => r_reset,
            i_rx_serial => r_rx_serial,
            o_rx_dv => r_rx_dv,
            o_rx_byte => w_rx_byte,
            o_anodes => w_anodes,
            o_cathodes => w_cathodes
        );
    
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


end architecture rtl;