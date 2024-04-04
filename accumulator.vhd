
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity accumulator is
    Port ( clk : in STD_LOGIC;
           load_acc_bar : in STD_LOGIC;
           acc_in : in STD_LOGIC_VECTOR (7 downto 0);
           acc_out : out STD_LOGIC_VECTOR (7 downto 0);
           zero_flag : out STD_LOGIC;
           minus_flag : out STD_LOGIC
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
        zero_flag <= '1' when internal_data = "00" else '0';
        minus_flag <= '1' when internal_data(7) = '1' else '0';
    end process;
     
end Behavioral;
