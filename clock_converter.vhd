----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2024 08:37:59 PM
-- Design Name: 
-- Module Name: Clock_converter - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock_converter is
    port(
       clrbar : in STD_LOGIC; 
       clk_in_100MHZ : in std_logic;
       clk_out_1HZ : out std_logic;
       clk_out_1KHZ : out std_logic
       );
end clock_converter;

architecture Behavioral of clock_converter is
    signal counter_1HZ : unsigned(26 downto 0) := (others => '0');
    signal counter_1KHZ : unsigned(16 downto 0) := (others => '0');
    
    signal clk_out_int_1HZ : std_logic := '0';
    signal clk_out_int_1KHZ : std_logic := '0';

begin
    process(clk_in_100MHZ)
    begin
         if clrbar = '0' then
             counter_1HZ <= (others => '0');
             counter_1KHZ <= (others => '0');
             clk_out_int_1HZ <= '0';
             clk_out_int_1KHZ <= '0';
        elsif rising_edge(clk_in_100MHZ) then
            -- handle 1 HZ counter
            if counter_1HZ = 50000000-1 then
                clk_out_int_1HZ <= not clk_out_int_1HZ;
                counter_1HZ <= (others => '0');
            else
                counter_1HZ <= counter_1HZ + 1;
            end if;
            
            -- handle 1 KHZ counter
            if counter_1KHZ = 50000-1 then
                clk_out_int_1KHZ <= not clk_out_int_1KHZ;
                counter_1KHZ <= (others => '0');
            else
                counter_1KHZ <= counter_1KHZ + 1;
            end if;
        end if;
    end process;
    
    clk_out_1HZ <= clk_out_int_1HZ;
    clk_out_1KHZ <= clk_out_int_1KHZ;

end Behavioral;
