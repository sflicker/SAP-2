library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory_loader is
    port(
        i_clk : in STD_LOGIC;                               -- system clock
        i_reset : in STD_LOGIC;                             -- reset loader
        i_prog_run_mode : in STD_LOGIC;                     -- system prog(low)/run(high) selecter. loader is active in prog mode only. 
        i_rx_data : in STD_LOGIC_VECTOR(7 downto 0);        -- receive a byte of data 
        i_rx_data_dv : in STD_LOGIC;                        -- byte of data is available to receive.
        i_tx_response_active : in STD_LOGIC;                -- response transmitter is active
        i_tx_response_done : in STD_LOGIC; 
        o_tx_response_data : out STD_LOGIC_VECTOR(7 downto 0);   -- response byte to transmit
        o_tx_response_dv : out STD_LOGIC;                   -- response byte is ready to transmit
        o_wrt_mem_addr : out STD_LOGIC_VECTOR(15 downto 0); -- address of mem to write
        o_wrt_mem_data : out STD_LOGIC_VECTOR(7 downto 0);  -- byte of data to write to mem
        o_wrt_mem_we : out STD_LOGIC                        -- ram we enable. must be high for one clock cycle to write a byte.
    );
end memory_loader;

architecture rtl of memory_loader is
    type t_byte_array is array (natural range <>) of std_logic_vector(7 downto 0);
    type t_state is (s_init, s_idle, s_rx_start, s_tx_start_resp, s_rx_total,
        s_rx_start_addr, s_rx_data, s_wrt_data, s_tx_checksum, s_tx_checksum_finish, s_cleanup);
    
    constant c_load_str : t_byte_array := (x"4C", x"4F", x"41", x"4D");
    constant c_ready_str : t_byte_array := (x"52", x"45", x"41", x"44", x"59");

    signal r_state : t_state := s_init;
--    signal r_total : STD_LOGIC_VECTOR(15 downto 0);
    signal r_counter : unsigned(15 downto 0);
    signal r_addr : STD_LOGIC_VECTOR(15 downto 0);
    signal r_data : STD_LOGIC_VECTOR(7 downto 0);
    signal r_rx_total : std_logic_vector(15 downto 0);
    signal r_rx_start_addr : std_logic_vector(15 downto 0);
    signal r_index : integer := 0;
    signal r_checksum : unsigned(7 downto 0) := (others => '0');
    signal r_state_pos : integer;
begin

    r_state_pos <= t_state'POS(r_state);

    p_memory_loader : process(i_clk, i_reset)
        variable v_start_addr : std_logic_vector(15 downto 0) := (others => '0');
    begin
        if i_reset = '1' then
            r_state <= s_init;
        elsif rising_edge(i_clk) then
            case r_state is 
                when s_init => 
                    r_index <= 0;
                    r_counter <= (others => '0');
                    v_start_addr := (others => '0');
                    r_addr <=  (others => '0');
                    r_data <= (others => '0');
                    r_rx_start_addr <= (others => '0');
                    r_rx_total <= (others => '0');
                    r_checksum <= (others => '0');
                    r_state <= s_idle;
                    o_tx_response_data <= (others => '0');
                    o_tx_response_dv <= '0';
                when s_idle =>
                    if i_rx_data_dv = '1' then     -- only receive if data valid 
                        if i_rx_data = c_load_str(r_index) then
                            r_index <= r_index + 1;
                            r_state <= s_rx_start;
                        else 
                            r_state <= s_idle;
                            r_index <= 0;
                        end if;
                    end if;

                when s_rx_start =>
                    if i_rx_data_dv = '1' then
                        if i_rx_data = c_load_str(r_index) then
                            r_data <= i_rx_data;
                            if r_index = c_load_str'length-1 then
                                r_index <= 0;
                                r_state <= s_tx_start_resp;
                            else
                                r_index <= r_index + 1;
                                r_state <= s_rx_start;
                            end if;
                        else
                            r_index <= 0;
                            r_state <= s_init;
                        end if;
                    end if;
                
                when s_tx_start_resp =>
                    if i_tx_response_done = '1' then
                        if r_index = c_ready_str'length-1 then
                            r_index <= 0;
                            r_state <= s_rx_total;
                        else
                            r_index <= r_index + 1;
                            r_state <= s_tx_start_resp;
                        end if;
                    elsif i_tx_response_active = '0' then   -- only transmit is upstream is not active
                        Report "Sending Start Response Byte " & to_string(r_index) & ", " & to_string(c_ready_str(r_index));
                        o_tx_response_data <= c_ready_str(r_index);
                        o_tx_response_dv <= '1';
                        r_state <= s_tx_start_resp;
                        -- if r_index = c_ready_str'length-1 then
                        --     r_index <= 0;
                        --     r_state <= s_rx_total;
                        -- else
                        --     r_index <= r_index + 1;
                        --     r_state <= s_tx_start_resp;
                        -- end if;
                    else
                        o_tx_response_dv <= '0';
                        r_state <= s_tx_start_resp;
                    end if;

                when s_rx_total =>
                    if i_rx_data_dv = '1' then
                        if r_index = 0 then
                            r_rx_total(7 downto 0) <= i_rx_data;
                            r_checksum <= r_checksum xor unsigned(i_rx_data);
                            r_index <= r_index + 1;
                            r_state <= s_rx_total;
                            r_counter <= r_counter + 1;
                        elsif r_index = 1 then
                            r_rx_total(15 downto 8) <= i_rx_data;
                            r_checksum <= r_checksum xor unsigned(i_rx_data);
                            r_index <= 0;
                            r_state <= s_rx_start_addr;
                            r_counter <= r_counter + 1;
                        end if;
                    else
                        r_state <= s_rx_total;
                    end if;

                when s_rx_start_addr =>
                    if i_rx_data_dv = '1' then
                        if r_index = 0 then
                            v_start_addr(7 downto 0) := i_rx_data;
                            r_checksum <= r_checksum xor unsigned(i_rx_data);
                            r_index <= r_index + 1;
                            r_state <= s_rx_start_addr;
                            r_counter <= r_counter + 1;
                        elsif r_index = 1 then
                            v_start_addr(15 downto 8) := i_rx_data;
                            r_rx_start_addr <= v_start_addr;
                            r_addr <= v_start_addr;
                            r_checksum <= r_checksum xor unsigned(i_rx_data);
                            r_index <= 0;
                            r_state <= s_rx_data;
                            r_counter <= r_counter + 1;
                        end if;
                    else
                        r_state <= s_rx_start_addr;
                    end if;

                when s_rx_data =>
                    if i_rx_data_dv = '1' then
                        r_data <= i_rx_data;
                        r_checksum <= r_checksum xor unsigned(i_rx_data);
                    --    r_counter <= r_counter + 1;
                        r_state <= s_wrt_data;
                        o_wrt_mem_addr <= r_addr;
                        o_wrt_mem_data <= i_rx_data;
                        o_wrt_mem_we <= '1';
                    else 
                        r_state <= s_rx_data;
                    end if;

                when s_wrt_data =>
                    -- this is really a to give mem write at least one clock
                    -- and do the counter increments.
                    -- may need to hold for several clock cycles but assuming not    
                    o_wrt_mem_we <= '0';
                    if r_counter = unsigned(r_rx_total) - 1 then
                        r_state <= s_tx_checksum;
                    else
                        r_counter <= r_counter + 1;
                        r_addr <= std_logic_vector(unsigned(r_addr) + 1);
                        r_state <= s_rx_data;
                    end if;

                when s_tx_checksum =>
                    if i_tx_response_active = '0' then
                        Report "Sending Checksum - " & to_string(r_checksum);
                        o_tx_response_data <= std_logic_vector(r_checksum);
                        o_tx_response_dv <= '1';
                        r_state <= s_tx_checksum_finish;
                    else
                        r_state <= s_tx_checksum;
                    end if;

                when s_tx_checksum_finish =>
                    if i_tx_response_active = '0' then
                        o_tx_response_dv <= '0';
                        r_state <= s_cleanup;
                    else 
                        r_state <= s_tx_checksum_finish;
                    end if;

                when s_cleanup =>
                    o_tx_response_data <= (others => '0');
                    o_tx_response_dv <= '0';
                    r_state <= s_init;
            end case;
        end if;
    end process;
end rtl;
    