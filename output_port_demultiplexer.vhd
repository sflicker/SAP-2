library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity output_port_demultiplexer is
    port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        output_port_select_in : in STD_LOGIC_VECTOR(7 downto 0);
        --output_port_select_we : in STD_LOGIC;
        output_port_in : in STD_LOGIC_VECTOR(7 downto 0);
        output_port_3_out : out STD_LOGIC_VECTOR(7 downto 0);
        output_port_3_we : out STD_LOGIC;
        output_port_4_out : out STD_LOGIC_VECTOR(7 downto 0);
        output_port_4_we : out STD_LOGIC;
    );
end output_port_demultiplexer;

architecture behavioral of output_port_demultiplexer is 
begin

    -- initialize outputs
    output_port_3_out <= (others => '0');
    output_port_3_we <= '0';
    output_port_4_out <= (others => '0');
    output_port_4_we <= '0';

    process(output_port_in, output_port_select_in)
    begin
        output_port_3_out <= (others => '0');
        output_port_3_we <= '0';
        output_port_4_out <= (others => '0');
        output_port_4_we <= '0';
        case output_port_select_in is
            when "00000011" =>
                output_port_3_we <= '1';
                output_port_3_out <= output_port_in;
            when "00000100" =>
                output_port_4_we <= '1';
                output_port_4_out <= output_port_in;
        end case;
        
    end process;

end behavioral;

     