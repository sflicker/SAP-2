library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory_loader is
    port(
        i_clk : STD_LOGIC;
        i_reset : STD_LOGIC;
        i_prog_run_mode : STD_LOGIC;
        i_rx_data : STD_LOGIC_VECTOR(7 downto 0);
        i_rx_data_dv : STD_LOGIC_VECTOR(7 downto 0);
        i_tx_active : STD_LOGIC;
        o_response : STD_LOGIC_VECTOR(7 downto 0);
        o_wrt_mem_addr : STD_LOGIC_VECTOR(15 downto 0);
        o_wrt_mem_data : STD_LOGIC_VECTOR(7 downto 0);
        o_wrt_mem_we : STD_LOGIC
    );
end memory_loader;

architecture rtl of memory_loader is
    type t_byte_array is array (natural range <>) of std_logic_vector(7 downto 0);
    type t_state is (s_idle, s_recv_start, s_send_start_resp, s_recv_total,
        s_recv_start_addr, s_recv_data, s_write_data, s_send_checksum, s_cleanup);
    
    constant c_load_str : t_byte_array := (x"4C", x"4F", x"41", x"4D");
    constant c_ready_str : t_byte_array := (x"52", x"45", x"41", x"44", x"59");

    signal r_state : t_state := s_idle;
    signal r_total : STD_LOGIC_VECTOR(15 downto 0);
    signal r_counter : STD_LOGIC_VECTOR(15 downto 0);
    signal r_addr : STD_LOGIC_VECTOR(15 downto 0);
    signal r_data : STD_LOGIC_VECTOR(7 downto 0);
    signal r_receive_total : std_logic_vector(15 downto 0);
    signal r_receive_start_addr : std_logic_vector(15 downto 0);
    signal r_index : integer;
    signal r_checksum : unsigned(7 downto 0) := (others => '0');
begin
    p_memory_loader : process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            r_state <= s_idle;
            r_index <= 0;
            r_counter <= (others => '0');
            r_addr <=  (others => '0');
            r_data <= (others => '0');
        elsif rising_edge(i_clk) then
            case r_state is 
                when s_idle => 
                    if i_data_dv = '1' then     -- only receive if data valid 
                        if i_rx_data = c_load_str(r_index) then
                            r_index <= r_index + 1;
                            r_state <= s_revc_start;
                        else 
                            r_state <= s_idle;
                            r_index <= 0;
                        end if;
                    end if;

                when s_recv_start =>
                    if i_rx_data_dv = '1' then
                        if i_rx_data = c_load_str(r_index) then
                            if r_index = c_load_str'length-1 then
                                r_index <= 0;
                                r_state <= s_send_start_resp;
                            else
                                r_index <= r_index + 1;
                                r_state <= s_recv_start;
                            end if;
                        else
                            r_index <= 0;
                            r_state <= s_idle;
                        end if;
                    end if;
                
                when s_send_start_resp =>
                    if i_tx_active = '0' then   -- only transmit is upstream is not active
                        o_response <= c_ready_str(r_index);
                        if r_index = c_ready_str'length-1 then
                            r_index <= 0;
                            r_state <= s_revc_total;
                        else
                            r_index <= r_index + 1;
                            r_start <= s_send_start_resp;
                        end if;
                    end if;

                when s_revc_total =>
                    if i_rx_data_dv = '1' then
                        if r_index = 0 then
                            r_total(7 downto 0) <= i_rx_data;
                            r_index <= r_index + 1;
                            r_state <= s_revc_total;
                            r_counter <= r_counter + 1;
                        elsif r_index = 1 then
                            r_total(15 downto 8) <= i_rx_data;
                            r_index <= 0;
                            r_state <= s_revc_start_addr;
                            r_counter <= r_counter + 1;
                        end if;
                    else
                        r_state <= r_revc_total;
                    end if;

                when s_revc_start_addr =>
                    if i_rx_data_dv = '1' then
                        if r_index = 0 then
                            r_addr(7 downto 0) <= i_rx_data;
                            r_index <= r_index + 1;
                            r_state <= s_revc_start_addr;
                            r_counter <= r_counter + 1;
                        elsif r_index = 1 then
                            r_addr(15 downto 8) <= i_rx_data;
                            r_index <= 0;
                            r_state <= s_recv_data;
                            r_counter <= r_counter + 1;
                        end if;
                    else
                        r_state <= r_revc_total;
                    end if;

                when s_recv_data =>
                    if i_rx_data_dv = '1' then
                        r_data <= i_data;
                        r_checksum <= r_checksum xor unsigned(i_data);
                        r_counter <= r_counter + 1;
                        r_state <= s_write_data;
                        o_wrt_mem_addr <= r_addr;
                        o_wrt_mem_data <= i_data;
                        o_wrt_mem_we <= '1';
                    else 
                        r_state <= r_recv_data;
                    end if;

                when s_write_data =>
                    -- this is really a to give mem write at least one clock
                    -- and do the counter increments.
                    -- may need to hold for several clock cycles but assuming not    
                    o_wrt_mem_we <= '0';
                    if r_counter = r_total -1 then
                        r_state <= s_send_checksum;
                    else
                        r_counter <= r_counter + 1;
                        r_addr <= r_addr + 1;
                        r_state <= s_recv_data;
                    end if;

                when s_send_checksum =>
                    if i_tx_active = '0' then
                        o_response <= r_checksum;
                        r_state <= s_cleanup;
                    else
                        r_state <= s_send_checksum;
                    end if;

                when s_cleanup =>
                    r_counter <= 0;
                    r_index <= 0;
                    r_counter <= (others => '0');
                    r_addr <=  (others => '0');
                    r_data <= (others => '0');
                    r_state <= s_idle;
            end case;
        end if;
    end process;
end rtl;
    