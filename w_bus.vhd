----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2024 07:16:47 PM
-- Design Name: 
-- Module Name: w_bus - Behavioral
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

entity w_bus is
  Port (sel : in STD_LOGIC_VECTOR(2 downto 0); 
        pc_data_in : in STD_LOGIC_VECTOR(3 downto 0);
        acc_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        alu_data_in  : in STD_LOGIC_VECTOR(7 downto 0);
        IR_data_in : in STD_LOGIC_VECTOR(3 downto 0);
        RAM_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        data_out : out STD_LOGIC_VECTOR(7 downto 0)
  );
end w_bus;

architecture Behavioral of w_bus is
begin
    process(sel)
    begin
        case sel is
            when "000" => data_out(3 downto 0) <= pc_data_in;
                          data_out(7 downto 4) <= (others => '0');
            when "001" => data_out <= acc_data_in;
            when "010" => data_out <= alu_data_in;
            when "011" => data_out(3 downto 0) <= IR_data_in;
                          data_out(7 downto 4) <= (others => '0');
            when "100" => data_out <= RAM_data_in;
            when others => data_out <= (others => '0');
        end case;
    end process;
end behavioral;
