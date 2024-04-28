library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity clock_divider is
    generic (
        g_DIV_FACTOR : integer := 2
    );
    port (
        i_clk : in STD_LOGIC;
        i_reset : in STD_LOGIC;
        o_clk : out STD_LOGIC
    );
end clock_divider;

architecture behavior of clock_divider is

    function log2ceil(n : integer) return integer is 
      variable result : real;
        begin
            result := ceil(log2(real(n)));
            return integer(result);
        end function;

    signal r_counter : unsigned((log2ceil(g_DIV_FACTOR)-1) downto 0) 
        := (others => '0');

    signal r_div_clk : std_logic := '0';
begin
    process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            r_counter <= (others => '0');
            r_div_clk <= '0';
        elsif rising_edge(i_clk) then
            if r_counter = g_DIV_FACTOR/2 - 1 then
                r_div_clk <= not r_div_clk;
                r_counter <= (others => '0');
            else 
                r_counter <= r_counter + 1;
            end if;
        end if;
    end process;

    o_clk <= r_div_clk;
end behavior;