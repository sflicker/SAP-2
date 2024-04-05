
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity accumulator is
    Port ( clk : in STD_LOGIC;
           load_acc_bar : in STD_LOGIC;
           acc_in : in STD_LOGIC_VECTOR (7 downto 0);
           acc_out : out STD_LOGIC_VECTOR (7 downto 0);
           );
end accumulator;

architecture Behavioral of accumulator is
    begin
    process(clk)
        variable internal_data : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
        begin
        if rising_edge(clk) and load_acc_bar = '0' then
            internal_data := acc_in;
        end if;
        acc_out <= internal_data;
    end process;
     
end Behavioral;
