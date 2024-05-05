library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UART_TX is
    generic (
        ID : string := "UART_TX";
        g_CLKS_PER_BIT : integer := 10416         -- (for basys3 100mhz / 9600)
    );
    port (
        i_clk : in STD_LOGIC;
        i_tx_dv : in STD_LOGIC;
        i_tx_byte : in STD_LOGIC_VECTOR(7 downto 0);
        o_tx_active : out STD_LOGIC := '0';
        o_tx_serial : out STD_LOGIC := '1';
        o_tx_done : out STD_LOGIC := '0'
    );
end UART_TX;

architecture RTL of UART_TX is 
        type t_state is (s_idle, s_start, s_tx_data_byte,
            s_stop, s_cleanup);
        signal r_state : t_state := s_idle;
        signal r_clk_count : integer range 0 to g_CLKS_PER_BIT -1 := 0;
        signal r_bit_index : integer range 0 to 7 := 0;
        signal r_tx_data : std_logic_vector(7 downto 0);
        signal r_tx_done : std_logic := '0';
    begin
        o_tx_done <= r_tx_done;

        p_UART_TX : process(i_clk)
        begin
            if rising_edge(i_clk) then
                case r_state is
                    when s_idle =>
                        o_tx_active <= '0';
                        o_tx_serial <= '1';     -- idle state
                        r_tx_done <= '0';
                        r_bit_index <= 0;

                        if i_tx_dv = '1' then
                            Report "ID: " & ID & " - i_tx_dv is high so starting transmission";
                            Report "ID: " & ID & ", Starting sending byte " & to_string(i_tx_byte);
                            r_tx_data <= i_tx_byte; -- copy the data byte to send into register
                            r_state <= s_start;     -- goto start state next
                        end if;
                    when s_start =>
                        o_tx_active <= '1';
                        o_tx_serial <= '0';     -- start bit

                        if r_clk_count < g_CLKS_PER_BIT - 1 then
                            r_clk_count <= r_clk_count + 1; -- increment counter
                            r_state <= s_start;               -- remain in start
                        else 
                            Report "ID: " & ID & " - Finished Start Bit switching to transmit byte";
                            r_clk_count <= 0;               -- reset counter
                            r_state <= s_tx_data_byte;      -- goto transmit state next
                        end if;
                    
                    when s_tx_data_byte =>
                        o_tx_serial <= r_tx_data(r_bit_index);  -- transmit bit

                        if r_clk_count < g_CLKS_PER_BIT - 1 then
                            r_clk_count <= r_clk_count + 1;
                            r_state <= s_tx_data_byte;
                        else 
                            r_clk_count <= 0;       -- reset counter
                            if r_bit_index < 7 then     -- more bits to send inc index
                                Report "ID: " & ID & " - More bits to send incrementing bit index";
                                r_bit_index <= r_bit_index + 1;
                                r_state <= s_tx_data_byte;
                            else 
                                Report "ID: " & ID & " - Finished Sending byte switching to stop state";
                                r_bit_index <= 0;       -- all bits send
                                r_state <= s_stop;      -- reset bit index and goto
                            end if;                     -- to stop next
                        end if;

                    when s_stop =>
                        o_tx_serial <= '1';             -- stop bit

                        if r_clk_count < g_CLKS_PER_BIT - 1 then
                            r_clk_count <= r_clk_count + 1;
                            r_state <= s_stop;
                        else 
                            Report "ID: " & ID & " - Finished sending stop bit switching to cleanup";
                            r_clk_count <= 0;
                            r_tx_done <= '1';
                            r_state <= s_cleanup;
                        end if;

                    when s_cleanup =>
                        Report "ID: " & ID & " - doing cleanup state. switching to idle";
                        o_tx_active <= '0';
                        r_tx_done <= '0';
                        r_state <= s_idle;

                    when others =>
                        r_state <= s_idle;

                end case;
            end if;
        end process;
end RTL;

