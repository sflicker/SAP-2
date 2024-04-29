library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UART_TX is
    generic (
        g_CLKS_PER_BIT : integer := 10416         -- (for basys3 100mhz / 9600)
    );
    port (
        i_clk : in STD_LOGIC;
        i_tx_dv : in STD_LOGIC;
        i_tx_byte : in STD_LOGIC_VECTOR(7 downto 0);
        o_tx_active : out STD_LOGIC;
        o_tx_serial : out STD_LOGIC;
        o_tx_done : out STD LOGIC;
    );
    end UART_TX;

    