
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity output is
    Port ( clk : in STD_LOGIC;
    clr : in STD_LOGIC;
    LOBar : in STD_LOGIC;
    output_in : in STD_LOGIC_VECTOR(7 downto 0);
    output_out : out STD_LOGIC_VECTOR(7 downto 0)
    );
end output;

architecture behavior of output is
begin
    process(clk)
        variable internal_data : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
        begin
        if clr = '1' then
            internal_data := "00000000";
        elsif rising_edge(clk) and LOBar = '0' then
            internal_data := output_in;
        end if;
    output_out <= internal_data;
    end process;
end behavior;