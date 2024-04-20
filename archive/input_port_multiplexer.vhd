library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity input_port_multiplexer is
    port (
        input_port_select_in : in STD_LOGIC_VECTOR(2 downto 0);
        input_port_1 : in STD_LOGIC_VECTOR(7 downto 0);
        input_port_2 : in STD_LOGIC_VECTOR(7 downto 0);
        input_port_out : out STD_LOGIC_VECTOR(7 downto 0)
    );
end input_port_multiplexer;

architecture behavioral of input_port_multiplexer is
    signal input_port_select_sig : STD_LOGIC_VECTOR(7 downto 0);
begin
    process(input_port_select_in)
    begin

    end process;

    input_port_out <= input_port_1 when input_port_select_sig = "00000001" else
                      input_port_2 when input_port_select_sig = "00000010" else
                      input_port_0;
end behavioral;                    



