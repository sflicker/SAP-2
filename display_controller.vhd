library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display_controller is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR(15 downto 0);
           o_anodes : out STD_LOGIC_VECTOR(3 downto 0);
           o_cathodes : out STD_LOGIC_VECTOR(6 downto 0)
           );
end display_controller;

architecture Behavioral of display_controller is
signal r_data_for_digit : STD_LOGIC_VECTOR(3 downto 0);
signal w_digit_sel : STD_LOGIC_VECTOR(3 downto 0);
begin
    seg_decoder : entity work.segment_decoder 
        Port Map(
            i_data => r_data_for_digit,
            o_data => o_cathodes);
            
    digit_mux : entity work.digit_multiplexer
        Port Map(i_clk => i_clk,
                i_rst => i_rst,
                o_digit_sel => w_digit_sel
                );
        
     digit_refresh :
        process(w_digit_sel)
        begin
            case w_digit_sel is
                when "0001" => r_data_for_digit <= i_data(3 downto 0);
                when "0010" => r_data_for_digit <= i_data(7 downto 4);
                when "0100" => r_data_for_digit <= i_data(11 downto 8);
                when "1000" => r_data_for_digit <= i_data(15 downto 12);
                when others => r_data_for_digit <= (others => '0');
            end case;
            o_anodes <= not w_digit_sel;
        end process;

end Behavioral;
