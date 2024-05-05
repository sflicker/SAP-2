library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--UART RECEIVER
-- settings
-- 9600 baud
-- 8 data bits
-- no parity
-- 1 stop bit
-- no flow control

-- UART protocol
-- serial line is high while idol
-- line goes low for one start bit
-- each bit is transmitted separately as either high or low.
-- after 8 databits serial line will be high for one stop bit.
entity UART_RX is 
    generic (
        ID : string := "UART_RX";
        g_CLKS_PER_BIT : integer := 10416         -- (for basys3 100mhz / 9600)
    );
    port(
        i_clk : in STD_LOGIC;                           -- input clock
        i_rx_serial : in STD_LOGIC;                     -- input serial bit
        o_rx_dv : out STD_LOGIC := '0';                        -- output data valid bit. high after succcessfully byte for one clock cycle
        o_rx_byte : out STD_LOGIC_VECTOR(7 downto 0) := (others => '0')    -- output received byte
    );
end  UART_RX;

architecture rtl of uart_rx is
    type t_state is (s_idol, s_start, s_rx_byte_bits, s_stop, s_cleanup);
    signal r_state : t_state := s_idol;
    signal r_clk_count : integer range 0 to g_CLKS_PER_BIT - 1 := 0;
    signal r_bit_index : integer range 0 to 7 := 0;
    signal r_rx_byte : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal r_rx_dv : STD_LOGIC := '0';
begin
    p_UART_RX : process(i_clk)
    begin
        if rising_edge(i_clk) then
            case r_state is
                when s_idol =>
                    r_rx_dv <= '0';
                    r_clk_count <= 0;
                    r_bit_index <= 0;

                    if i_rx_serial = '0' then           -- low for start 
                        Report "ID: " & ID & " - Start bit detected entering start state";
                        r_state <= s_start;
                    else 
                        r_state <= s_idol;
                    end if;

                when s_start =>
                    if r_clk_count = (g_CLKS_PER_BIT)/2 then   -- if half period is reached sample the line to verify start
                        if i_rx_serial = '0' then               -- transistion to rx_byte_bits state
                            Report "ID: " & ID & " - Verified Start Bit Moving to Receive byte";
                            r_clk_count <= 0;
                            r_state <= s_rx_byte_bits;
                        else 
                            Report "ID: " & ID & " - False start moving back to idol";
                            r_state <= s_idol;                  -- if sample is high this was a false start so go back to idol
                        end if;
                    else                                        -- if not at sample point increment counter and stay in state
                        r_clk_count <= r_clk_count + 1;
                        r_state <= s_start;
                    end if;

                when s_rx_byte_bits =>
                    if r_clk_count < g_CLKS_PER_BIT-1 then
                        r_clk_count <= r_clk_count + 1;
                        r_state <= s_rx_byte_bits;
                    else 
                        r_clk_count <= 0;
                        r_rx_byte(r_bit_index) <= i_rx_serial;  -- save bit at bit index position
                        Report "ID: " & ID & " - Received Bit - " & to_string(i_rx_serial);
                        if r_bit_index < 7 then                 -- if not at end of byte increment the bit_index and continue
                            r_bit_index <= r_bit_index + 1;
                            r_state <= s_rx_byte_bits;
                        else 
                            Report "ID: " & ID & " - Finished receiving bits moving to stop";
                            r_bit_index <= 0;                   -- assembled a full byte move to the stop state
                            r_state <= s_stop;
                        end if;
                    end if;

                when s_stop => 
                    if r_clk_count < g_CLKS_PER_BIT - 1 then
                        r_clk_count <= r_clk_count + 1;
                        r_state <= s_stop;
                    else 
                        Report "ID: " & ID & " - Finished Stop state moving to cleanup";
                        r_rx_dv <= '1';
                        r_clk_count <= 0;
                        r_state <= s_cleanup;
                    end if;

                when s_cleanup =>                       -- cleanup for 1 cycle
                    Report "ID: " & ID & " - Finished Receiving byte: " & to_string(r_rx_byte) & ". Cleaning up then move back to idol";
                    r_rx_dv <= '0';
                    r_state <= s_idol;

                when others =>
                    r_state <= s_idol;
            end case;
        end if;
    end process;
    o_rx_byte <= r_rx_byte;
    o_rx_dv <= r_rx_dv;
end architecture rtl;
