----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2024 10:13:16 PM
-- Design Name: 
-- Module Name: proc_controller - Behavioral
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




entity proc_controller is
  Port (
    -- inputs
    clk : in STD_LOGIC;
    clrbar : in STD_LOGIC;
    opcode : in STD_LOGIC_VECTOR(3 downto 0);          -- 5 opcodes in model, 4 bits of instruction form the opcode
  
    -- outputs
    wbus_sel : out STD_LOGIC_VECTOR(2 downto 0);
    Cp  : out STD_LOGIC;                          -- increment program counter by one
    LMBar : out STD_LOGIC;                        -- Load MAR register from WBus - enable low
    LIBar : out STD_LOGIC;                        -- LOAD IR register from WBus - enable low
    LABar : out STD_LOGIC;                        -- LOAD Accumulator register from WBus -- enable low
    Su : out STD_LOGIC;                           -- operation for ALU. 0 - ADD, 1 - Subtract
    LBBar : out STD_LOGIC;                        -- LOAD B register from WBus - eanble low
    LOBar : out STD_LOGIC;
    HLTBar : out STD_LOGIC;
    stage_out : out integer
    );
end proc_controller;

architecture Behavioral of proc_controller is
    signal stage_sig : integer := 1;

    signal control_word_index_signal : std_logic_vector(3 downto 0);
    signal control_word_signal : std_logic_vector(0 to 9);

--    phase_out <= std_logic_vector(shift_left(unsigned'("000001"), stage_counter_sig - 1));

--    stage_counter : out integer


    type ADDRESS_ROM_TYPE is array(0 to 15) of std_logic_vector(3 downto 0);
    type CONTROL_ROM_TYPE is array(0 to 15) of STD_LOGIC_VECTOR(0 to 9);

    constant ADDRESS_ROM_CONTENTS : ADDRESS_ROM_TYPE := (
        0 => "0011",     -- LDA
        1 => "0110",     -- ADD
        2 => "1001",     -- SUB
        14 => "1100",     -- OUT
        15 => "0000",       -- HLT
        others => "0000"
    );

    constant NOP : STD_LOGIC_VECTOR(0 to 9) := "1110111011";

    constant CONTROL_ROM : CONTROL_ROM_TYPE := (
       -- FETCH
       0 =>  "0000011011",     -- Phase1:   PC -> MAR
       1 =>  "1111111011",     -- Phase2:   INC PC
       2 =>  "1000101011",     -- Phase3:   RAM -> IR
       -- LDA
       3 =>  "0110011011",     -- LDA Phase4: IR (operand portion) -> MAR
       4 =>  "1000110011",     -- LDA Phase5: RAM -> A
       5 =>  NOP,     -- LDA Phase6: NOP
       -- ADD
       6 =>  "0110011011",      -- ADD Phase4: IR(operand portion) -> MAR
       7 =>  "1000111001",      -- ADD Phase5: RAM -> B, SU -> 0
       8 =>  "0100110011",      -- ADD Phase6: ALU -> A
       -- SUB
       9 =>  "0110011111",      -- SUB Phase4: IR(operand portion) -> MAR
       10 => "1000111101",      -- SUB Phase5: RAM -> B, SU => 1
       11 => "0100110111",      -- --SUB phase6: ALU => A
       -- OUT
       12 => "0010111010",      -- OUT phase 4  A => OUT
       13 => NOP,      -- OUT phase 5 NOP
       14 => NOP,      -- OUT phase 5 NOP
       -- unused
       15 => NOP       --NOP
       
       );

begin
    HLTBAR <= '0' when opcode = "1111" else
        '1';
    stage_out <= stage_sig;

    run_mode_process:
        process(clk, clrbar, opcode)
            variable stage_var : integer := 1;
            variable control_word_index : std_logic_vector(3 downto 0);
            variable control_word : std_logic_vector(0 to 9);
        begin

            if CLRBAR = '0' then
                stage_var := 1;
                stage_sig <= stage_var;
            elsif rising_edge(clk) then
                if stage_var = 1 then
                    control_word_index := "0000";
                elsif stage_var = 4 then
                    control_word_index := ADDRESS_ROM_CONTENTS(to_integer(unsigned(opcode)));
                else 
                    control_word_index := std_logic_vector(unsigned(control_word_index) + 1);
                end if;

                control_word := CONTROL_ROM(to_integer(unsigned(control_word_index)));


                Report "Stage: " & to_string(stage_var) 
                    & ", control_word_index: " & to_string(control_word_index) 
                    & ", control_word: " & to_string(control_word) & ", opcode: " & to_string(opcode);

                if control_word = NOP then
                    Report "NOP detected moving to next instruction";
                    stage_var := 1;
                    stage_sig <= stage_var;
--                    stage_counter <= stage;
                else

                    control_word_signal <= control_word;
                    control_word_index_signal <= control_word_index;
                    wbus_sel <= control_word(0 to 2);
                    Cp <= control_word(3);
                    LMBar <= control_word(4);
                    LIBar <= control_word(5);
                    LABar <= control_word(6);
                    Su <= control_word(7);
                    LBBar <= control_word(8);
                    LOBar <= control_word(9);

--                    stage_counter <= stage;
        
                    if stage_var >= 6 then
                        stage_var := 1;
                        stage_sig <= stage_var;
                    else
                        stage_var := stage_var + 1; 
                        stage_sig <= stage_var;
                    end if;
                end if;
            end if;
--        phase_out <= std_logic_vector(shift_left(unsigned'("000001"), stage - 1));
        end process;

end Behavioral;
