library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity segment_decoder is
    Port ( i_data : in STD_LOGIC_VECTOR(3 downto 0);
           o_data : out STD_LOGIC_VECTOR(6 downto 0)
           );
end segment_decoder;

architecture Behavioral of segment_decoder is

begin
    process(i_data)
    begin
        case i_data is
            when "0000" => o_data <= "0000001"; -- zero
            when "0001" => o_data <= "1001111"; -- one
            when "0010" => o_data <= "0010010"; -- two 
            when "0011" => o_data <= "0000110"; -- three
            when "0100" => o_data <= "1001100"; -- four
            when "0101" => o_data <= "0100100"; -- five
            when "0110" => o_data <= "0100000"; -- six
            when "0111" => o_data <= "0001111"; -- seven
            when "1000" => o_data <= "0000000"; -- eight
            when "1001" => o_data <= "0000100"; -- nine
            when "1010" => o_data <= "0001000"; -- A
            when "1011" => o_data <= "1100000"; -- B
            when "1100" => o_data <= "0110001"; -- C
            when "1101" => o_data <= "1000010"; -- D
            when "1110" => o_data <= "0110000"; -- E
            when "1111" => o_data <= "0111000"; -- F            
            when others => o_data <= "1111111";
        end case;
    end process;
end Behavioral;
