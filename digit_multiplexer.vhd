library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity digit_multiplexer is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           o_digit_sel : out STD_LOGIC_VECTOR(3 downto 0) := "0001"
           );
end digit_multiplexer;

architecture Behavioral of digit_multiplexer is

begin
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            o_digit_sel <= "0001";
        elsif rising_edge(i_clk) then
            o_digit_sel <= o_digit_sel(2 downto 0) & o_digit_sel(3);  -- shift digits
        end if;
    end process;
end Behavioral;
