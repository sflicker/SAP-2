----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/10/2024 07:27:07 PM
-- Design Name: 
-- Module Name: segment_decoder - Behavioral
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

entity segment_decoder is
    Port ( data_in : in STD_LOGIC_VECTOR(3 downto 0);
           data_out : out STD_LOGIC_VECTOR(6 downto 0)
           );
end segment_decoder;

architecture Behavioral of segment_decoder is

begin
    process(data_in)
    begin
        case data_in is
            when "0000" => data_out <= "0000001"; -- zero
            when "0001" => data_out <= "1001111"; -- one
            when "0010" => data_out <= "0010010"; -- two 
            when "0011" => data_out <= "0000110"; -- three
            when "0100" => data_out <= "1001100"; -- four
            when "0101" => data_out <= "0100100"; -- five
            when "0110" => data_out <= "0100000"; -- six
            when "0111" => data_out <= "0001111"; -- seven
            when "1000" => data_out <= "0000000"; -- eight
            when "1001" => data_out <= "0000100"; -- nine
            when "1010" => data_out <= "0001000"; -- A
            when "1011" => data_out <= "1100000"; -- B
            when "1100" => data_out <= "0110001"; -- C
            when "1101" => data_out <= "1000010"; -- D
            when "1110" => data_out <= "0110000"; -- E
            when "1111" => data_out <= "0111000"; -- F            
            when others => data_out <= "1111111";
        end case;
    end process;
end Behavioral;
