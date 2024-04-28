library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UART_top is
    generic (
        SIMULATION_MODE : boolean := false
    );
    port (
        i_clk : in STD_LOGIC;
        i_rx_serial : in STD_LOGIC;
        o_data : out STD_LOGIC_VECTOR(7 downto 0);
        o_anodes : out STD_LOGIC_VECTOR(3 downto 0);      -- maps to seven segment display
        o_cathodes : out STD_LOGIC_VECTOR(6 downto 0)     -- maps to seven segment display

    );
end UART_TOP;

architecture behavioral of UART_top is
    signal w_rx_dv : std_logic;
    signal w_rx_byte : std_logic_vector(7 downto 0);
    signal r_display_data : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal w_clk_disp_refresh_1KHZ_sig : STD_LOGIC;
    signal r_clr_sig : STD_LOGIC := '0';
begin

    UART_RX_INST: entity work.UART_RX
    port map (
        i_clk => i_clk,
        i_rx_serial => i_rx_serial,
        o_rx_dv => w_rx_dv,
        o_rx_byte => w_rx_byte
    );

--    process(w_rx_dv)
--    begin
--        if w_rx_dv = '1' then
--            r_display_data(7 downto 0) <= w_rx_byte;
--        else 
--            r_display_data(7 downto 0) <= r_display_data(7 downto 0);
--        end if;
--    end process;

    r_display_data(7 downto 0) <= w_rx_byte;
    o_data <= w_rx_byte;

    DISP_CLOCK_DIVIDER : entity work.clock_divider
        generic map(g_DIV_FACTOR => 100000)
        port map(
            i_clk => i_clk,
            i_reset => '0',
            o_clk => w_clk_disp_refresh_1KHZ_sig
        );


    GENERATING_FPGA_OUTPUT : if SIMULATION_MODE = false
        generate  
            display_controller : entity work.display_controller
            port map(
               clk => w_clk_disp_refresh_1KHZ_sig,
               rst => r_clr_sig,
               data_in => r_display_data,
               anodes_out => o_anodes,
               cathodes_out => o_cathodes
           );
       end generate;          

end behavioral;