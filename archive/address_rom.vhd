----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2024 04:44:04 PM
-- Design Name: 
-- Module Name: address_rom - Behavioral
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

entity address_rom is
    Port (
           addr_in : in STD_LOGIC_VECTOR(3 downto 0);
           data_out : out STD_LOGIC_VECTOR(3 downto 0)
    );
end address_rom;

architecture Behavioral of address_rom is
    function is_fully_assigned(v : std_logic_vector) return boolean is
    begin
        for i in v'range loop
            if not (v(i) = '0' or v(i) = '1') then
                return false; -- Found an unassigned bit
            end if;
        end loop;
        return true; -- All bits are assigned
    end function;
    type ADDRESS_ROM_TYPE is array(0 to 15) of std_logic_vector(3 downto 0);
    constant ROM_CONTENTS : ADDRESS_ROM_TYPE := (
        0 => "0011",     -- LDA
        1 => "0110",     -- ADD
        2 => "1001",     -- SUB
        14 => "1100",     -- OUT
        15 => "0000",       -- HLT
        others => "0000"
    );
begin
   data_out <= ROM_CONTENTS(to_integer(unsigned(addr_in))) when is_fully_assigned(addr_in)
        else "0000";
end Behavioral;
