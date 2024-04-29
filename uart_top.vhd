library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UART_top is
    generic (
        SIMULATION_MODE : boolean := false
    );
    port (
        i_clk : in STD_LOGIC;
        i_reset : in STD_LOGIC;
        i_rx_serial : in STD_LOGIC;
        o_tx_serial : out STD_LOGIC;
        o_rx_dv : out STD_LOGIC;                        -- output data valid bit. high after succcessfully byte for one clock cycle
        o_rx_byte : out STD_LOGIC_VECTOR(7 downto 0);    -- output received byte
        o_anodes : out STD_LOGIC_VECTOR(3 downto 0);      -- maps to seven segment display
        o_cathodes : out STD_LOGIC_VECTOR(6 downto 0)     -- maps to seven segment display

    );
end UART_TOP;

architecture behavioral of UART_top is
    signal r_display_data : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal w_clk_disp_refresh_1KHZ_sig : STD_LOGIC;
    signal r_clr_sig : STD_LOGIC := '0';
    signal r_tx_byte : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal w_rx_dv : STD_LOGIC;
    signal w_tx_active : STD_LOGIC;
    signal w_tx_serial : STD_LOGIC;
    signal w_tx_done : STD_LOGIC;
begin

    r_tx_byte <= o_rx_byte when o_rx_dv = '1' else r_tx_byte;
          
    o_rx_dv <= w_rx_dv;
    o_tx_serial <= w_tx_serial;

    UART_TX_INST : entity work.UART_TX
    port map(
        i_clk => i_clk,
        i_tx_dv => w_rx_dv,
        i_tx_byte => r_tx_byte,
        o_tx_active => w_tx_active,
        o_tx_serial => w_tx_serial,
        o_tx_done => w_tx_done
    );

    UART_RX_INST: entity work.UART_RX
    port map (
        i_clk => i_clk,
        i_rx_serial => i_rx_serial,
        o_rx_dv => w_rx_dv,
        o_rx_byte => o_rx_byte
    );

--    process(w_rx_dv)
--    begin
--        if w_rx_dv = '1' then
--            r_display_data(7 downto 0) <= w_rx_byte;
--        else 
--            r_display_data(7 downto 0) <= r_display_data(7 downto 0);
--        end if;
--    end process;

    r_display_data(7 downto 0) <= o_rx_byte;

    DISP_CLOCK_DIVIDER : entity work.clock_divider
        generic map(g_DIV_FACTOR => 100000)
--        generic map(g_DIV_FACTOR => 10)
                port map(
            i_clk => i_clk,
            i_reset => i_reset,
            o_clk => w_clk_disp_refresh_1KHZ_sig
        );


    GENERATING_FPGA_OUTPUT : if SIMULATION_MODE = false
        generate  
            display_controller : entity work.display_controller
            port map(
               i_clk => w_clk_disp_refresh_1KHZ_sig,
               i_rst => i_reset,
               i_data => r_display_data,
               o_anodes => o_anodes,
               o_cathodes => o_cathodes
           );
       end generate;          

end behavioral;