----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/10/2024 09:06:04 PM
-- Design Name: 
-- Module Name: display_controller - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display_controller is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR(15 downto 0);
           anodes_out : out STD_LOGIC_VECTOR(3 downto 0);
           cathodes_out : out STD_LOGIC_VECTOR(6 downto 0)
           );
end display_controller;

architecture Behavioral of display_controller is
signal data_for_digit : STD_LOGIC_VECTOR(3 downto 0);
signal digit_sel : STD_LOGIC_VECTOR(3 downto 0);
begin
    seg_decoder : entity work.segment_decoder 
        Port Map(
            data_in => data_for_digit,
            data_out => cathodes_out);
            
    digit_mux : entity work.digit_multiplexer
        Port Map(clk => clk,
                rst => rst,
                digit_sel => digit_sel
                );
        
     digit_refresh :
        process(digit_sel)
        begin
            case digit_sel is
                when "0001" => data_for_digit <= data_in(3 downto 0);
                when "0010" => data_for_digit <= data_in(7 downto 4);
                when "0100" => data_for_digit <= data_in(11 downto 8);
                when "1000" => data_for_digit <= data_in(15 downto 12);
                when others => data_for_digit <= (others => '0');
            end case;
            anodes_out <= not digit_sel;
        end process;

end Behavioral;
