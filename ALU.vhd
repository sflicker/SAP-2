----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2024 11:00:19 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
    Port ( clr : in STD_LOGIC;
           op : in STD_LOGIC_VECTOR(2 downto 0);
           input_1 : in STD_LOGIC_VECTOR(7 downto 0);
           input_2 : in STD_LOGIC_VECTOR(7 downto 0);
           update_status_flags : in STD_LOGIC;
           alu_out : out STD_LOGIC_VECTOR(7 downto 0);
           minus_flag : out STD_LOGIC;
           equal_flag : out STD_LOGIC
    );
end ALU;

architecture Behavioral of ALU is
    procedure update_flags(
        variable result : STD_LOGIC_VECTOR(7 downto 0);
        signal minus_flag_sig : inout STD_LOGIC;
        signal equal_flag_sig : inout STD_LOGIC;
        signal update_status_flags_sig : STD_LOGIC) is
    begin
        if update_status_flags_sig = '1' then
            minus_flag_sig <= '1' when result(7) = '1' else '0';
            equal_flag_sig <= '1' when result = "00000000" else '0';
        end if;
    end procedure;
begin

    process (clr, input_1, input_2, op)
        variable result : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    begin
        if clr = '1' then
            result := (others => '0');
        elsif op = "000" then
            result := std_logic_vector(unsigned(input_1) + unsigned(input_2));
            update_flags(result, minus_flag, equal_flag, update_status_flags);
        elsif op = "001" then
            result := std_logic_vector(unsigned(input_1) - unsigned(input_2));
            update_flags(result, minus_flag, equal_flag, update_status_flags);
        elsif op = "010" then
            result := std_logic_vector(unsigned(input_2) + 1);
            update_flags(result, minus_flag, equal_flag, update_status_flags);
        elsif op = "011" then
            result := std_logic_vector(unsigned(input_2) - 1);
            update_flags(result, minus_flag, equal_flag, update_status_flags);
        elsif op = "100" then
            result := std_logic_vector(unsigned(input_1) AND unsigned(input_2));
            update_flags(result, minus_flag, equal_flag, update_status_flags);
        elsif op = "101" then
            result := std_logic_vector(unsigned(input_1) OR unsigned(input_2));
            update_flags(result, minus_flag, equal_flag, update_status_flags);
        elsif op = "110" then
            result := std_logic_vector(unsigned(input_1) XOR unsigned(input_2));
            update_flags(result, minus_flag, equal_flag, update_status_flags);
        elsif op = "111" then
            result := std_logic_vector(not unsigned(input_1));
            -- do not update flags in this case
        else
            result := (others => '0');
        end if;
        alu_out <= result;
    end process;
end Behavioral;
