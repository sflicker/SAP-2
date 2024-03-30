----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2024 07:44:13 PM
-- Design Name: 
-- Module Name: presettable_counter - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity presettable_counter is
    Port ( clk : in STD_LOGIC;
           load : in STD_LOGIC;
           clr : in STD_LOGIC;
           control_word_base_addr : in STD_LOGIC_VECTOR(3 downto 0);
           control_word_addr : out STD_LOGIC_VECTOR(3 downto 0)
    );
end presettable_counter;

architecture Behavioral of presettable_counter is

begin
    counter: 
    process(clk)
        variable internal_counter : std_logic_vector(3 downto 0) := "0000";
    begin
        if rising_edge(clk) then
            if clr = '1' then
                Report "Handling CLR signal setting counter to zero";
                internal_counter := "0000";
            elsif load = '1' then
                Report "Handling LOAD Signal. setting internal counter to instruction base";
                internal_counter := control_word_base_addr;
            else 
                Report "Increating Counter";
                internal_counter := STD_LOGIC_VECTOR(unsigned(internal_counter) + 1);
            end if;
            Report "Presettable Counter Internal Counter=" & to_string(internal_counter) & ", CLR=" & to_String(clr) & ", LOAD=" & to_string(load);
            control_word_addr <= internal_counter;
        end if;
    end process;
end Behavioral;
