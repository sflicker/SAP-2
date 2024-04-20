library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity output_port_we_selector is
    port (
        output_port_we_select : in STD_LOGIC_VECTOR(7 downto 0);
        output_port_3_we : out STD_LOGIC;
        output_port_4_we : out STD_LOGIC;
    );
end output_port_we_selector;

architecture behavioral of output_port_we_selector is 
begin

    -- initialize outputs
    output_port_3_we <= '0';
    output_port_4_we <= '0';

    process(output_port_we_select)
    begin
        output_port_3_we <= '0';
        output_port_4_we <= '0';
        case output_port_we_select is
            when "00000011" =>    -- port 3
                output_port_3_we <= '1';
            when "00000100" =>    -- port 4
                output_port_4_we <= '1';
        end case;
        
    end process;

end behavioral;

     