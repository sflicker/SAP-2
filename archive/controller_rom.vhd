----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2024 11:34:56 AM
-- Design Name: 
-- Module Name: controller_rom - Behavioral
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

-- CONTROL WORD
-- BITS 0-2    -- W BUS Selector
                -- 000 0H PC
                -- 001 1H Accumulator
                -- 010 2H ALU
                -- 011 3H IR
                -- 100 4H RAM
-- BIT 3        Cp - Program Counter increment. active high
-- BIT 4        LMBar - Load MAR from W bus. active Low
-- BIT 5        LIBar - Load IR from W Bus. active Low
-- BIT 6        LABar - Load Accumulator from W bus. active low
-- BIT 7        Su - ALU mode. 0 add, 1 sub
-- BIT 8        LBBar - Load B register from W bus. active low
-- BIT 9        LOBar - Load output register from W Bus. active Low


entity controller_rom is
  Port ( control_word : in STD_LOGIC_VECTOR(3 downto 0);  -- 4 bit control signal
        wbus_sel : out STD_LOGIC_VECTOR(2 downto 0);      -- 3 bit selector for input to WBUS
        Cp  : out STD_LOGIC;                          -- increment program counter by one
        LMBar : out STD_LOGIC;                        -- Load MAR register from WBus - enable low
        LIBar : out STD_LOGIC;                        -- LOAD IR register from WBus - enable low
        LABar : out STD_LOGIC;                        -- LOAD Accumulator register from WBus -- enable low
        Su : out STD_LOGIC;                           -- operation for ALU. 0 - ADD, 1 - Subtract
        LBBar : out STD_LOGIC;                        -- LOAD B register from WBus - eanble low
        LOBar : out STD_LOGIC                         -- LOAD Output register from WBus - enable low
        );
end controller_rom;

architecture Behavioral of controller_rom is
    type CONTROL_ROM_TYPE is array(0 to 15) of STD_LOGIC_VECTOR(0 to 9);
    constant CONTROL_ROM : CONTROL_ROM_TYPE := (
       -- FETCH
       0 =>  "0000011011",     -- Phase1:   PC -> MAR
       1 =>  "1111111011",     -- Phase2:   INC PC
       2 =>  "1000101011",     -- Phase3:   RAM -> IR
       -- LDA
       3 =>  "0110011011",     -- LDA Phase4: IR (operand portion) -> MAR
       4 =>  "1000110011",     -- LDA Phase5: RAM -> A
       5 =>  "1110111011",     -- LDA Phase6: NOP
       -- ADD
       6 =>  "0110011011",      -- ADD Phase4: IR(operand portion) -> MAR
       7 =>  "1000111001",      -- ADD Phase5: RAM -> B, SU -> 0
       8 =>  "0100110011",      -- ADD Phase6: ALU -> A
       -- SUB
       9 =>  "0110011011",      -- SUB Phase4: IR(operand portion) -> MAR
       10 => "1000111101",      -- SUB Phase5: RAM -> B, SU => 1
       11 => "0100110011",      -- --SUB phase6: ALU => A
       -- OUT
       12 => "0010111010",      -- OUT phase 4  A => OUT
       13 => "1110111011",      -- OUT phase 5 NOP
       14 => "1110111011",      -- OUT phase 5 NOP
       -- unused
       15 => "1110111011"       --NOP
       
       );

begin
    process(control_word)
    variable control_bits : STD_LOGIC_VECTOR(0 to 9);
    begin
        control_bits := CONTROL_ROM(to_integer(unsigned(control_word)));
        wbus_sel <= control_bits(0 to 2);
        Cp <= control_bits(3);
        LMBar <= control_bits(4);
        LIBar <= control_bits(5);
        LABar <= control_bits(6);
        Su <= control_bits(7);
        LBBar <= control_bits(8);
        LOBar <= control_bits(9);
    end process;

end Behavioral;
