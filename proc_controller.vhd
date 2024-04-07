library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
  
-- CONTROL WORD
-- BITS 0-3     W BUS Selector
                -- 0000 0H  All Zeros
                -- 0001 1H  PC
                -- 0010 2H  IR Operand
                -- 0011 3H  ALU Out
                -- 0100 4H  MDR Out
                -- 0101 5H  ACC Out
                -- 0110 6H  B Out
                -- 0111 7H  C Out
                -- 1000 8H  Tmp Out
                -- 1001 9H  Input Port 1
                -- 1002 AH  Input Port 2
--  BITS 4-6    ALU Operation
                -- 000 0H   ADD
                -- 001 1H   SUB
                -- 010 2H   INCREMENT
                -- 011 3H   DECREMENT
                -- 100 4H   AND
                -- 101 5H   OR
                -- 110 6H   XOR
                -- 111 7H   Complement                
--  BIT 7       ACCUMULATOR Write Enable
--  BIT 8       B Write Enable
--  BIT 9       C Write Enable
--  BIT A       TMP Write Enable
--  BIT B       MAR Write Enable
--  BIT C       PC Write Enable
--  BIT D       PC Increment
--  BIT E       MDR Write Enable
--  BIT F       MDR Direction             0 READ, 1 WRITE
--  BIT 10      IR Write Enable
--  BIT 11      IR Operand Low Write Enable
--  BIT 12      IR Operand High Write Enable
--  BIT 13      OUT Port 1 Write Enable
--  BIT 14      OUT Port 2 Write Enable
--  BITS 15-17  UNUSED

-- SAP-2 Opcodes
-- ADD B        80      ; Accum <= Accum + B ; includes flag updates
-- ADD C        81      ; Accum <= Accum + C ; includes flag updates
-- ANA B        A0      ; Accum <= Accum AND B ; includes flag updates
-- ANA C        A1      ; Accum <= Accum AND C ; includes flag updates
-- ANI byte     E6      ; Accum <= Accum AND byte ; includes flag updates
-- CALL address CD      ; PC <= address
-- CMA          2F      ; Accum <= NOT Accum
-- DCR A        3D      ; Accum <= Accum - 1 ; includes flag updates
-- DCR B        05      ; B <= B - 1 ; includes flag updates
-- DCR C        0D      ; C <= C - 1 ; includes flag updates
-- HLT          76      ; Stops processing
-- IN byte      DB      ; Acc <= INPUT PORT #byte
-- INR A        3C      ; Accum <= Accum + 1 ; flags updates
-- INR B        04      ; B <= B + 1 ; flags updates
-- INR C        0C      ; C <= C + 1 ; flags updates
-- JM address   FA      ; PC <= Address if Minus Flags set
-- JMP address  C3      ; PC <= Address
-- JNZ address  C2      ; PC <= Address if zero flag not set
-- JZ address   CA      ; PC <= Address if zero flag set
-- LDA address  3A      ; Acc <= RAM[address]
-- MOV A,B      78      ; Acc <= B
-- MOV A,C      79      ; Acc <= C
-- MOV B,A      47      ; B <= Acc
-- MOV B,C      41      ; B <= C
-- MOV C,A      4F      ; C <= Acc
-- MOV C,B      48      ; C <= B
-- NOP          00      ; do nothing. all counters should be set to default (low) positions
-- ORA B        B0      ; Acc <= Acc OR B   ; flags also set
-- ORA C        B1      ; Acc <= Acc OR C   ; flags also set
-- ORI Byte     F6      ; Acc <= Acc OR byte    ; flags also set
-- OUT byte     D3      ; OUTPUT PORT #byte <= Acc
-- RAL          17      ; shift accumulator bits left
-- RAR          1F      ; shift accumulator bits right
-- RET          C9      ; return from subroutine
-- STA address  32      ; RAM[address] <= Acc
-- SUB B        90      ; ACC <= Acc - B        ; flags also set
-- SUB C        91      ; ACC <= ACC - C        ; flags also set
-- XRA B        A8      ; ACC <= ACC XOR B      ; flags also set
-- XRA C        A9      ; ACC <= ACC XOR C      ; flags also set
-- XRI byte     EE      ; ACC <= ACC xor byte   ; flags also set





entity proc_controller is
  Port (
    -- inputs
    clk : in STD_LOGIC;
    clrbar : in STD_LOGIC;
    opcode : in STD_LOGIC_VECTOR(7 downto 0);          -- 8 bit opcodes
  
    -- outputs
    wbus_sel : out STD_LOGIC_VECTOR(3 downto 0);
    alu_op : out STD_LOGIC_VECTOR(2 downto 0);
    acc_write_enable : out STD_LOGIC;
    b_write_enable : out STD_LOGIC;
    c_write_enable : out STD_LOGIC;
    tmp_write_enable : out STD_LOGIC;
    mar_write_enable : out STD_LOGIC;
    pc_write_enable : out STD_LOGIC;
    pc_increment : out STD_LOGIC;
    mdr_write_enable : out STD_LOGIC;
    mdr_direction : out STD_LOGIC;
    ir_opcode_write_enable : out STD_LOGIC;
    ir_operand_low_write_enable : out STD_LOGIC;
    ir_operand_high_write_enable : out STD_LOGIC;
    out_1_write_enable : out STD_LOGIC;
    out_2_write_enable : out STD_LOGIC;
    
    HLTBar : out STD_LOGIC;
    stage_out : out integer
    );
end proc_controller;

architecture Behavioral of proc_controller is
    signal stage_sig : integer := 1;

    signal control_word_index_signal : std_logic_vector(3 downto 0);
    signal control_word_signal : std_logic_vector(0 to 23);

--    phase_out <= std_logic_vector(shift_left(unsigned'("000001"), stage_counter_sig - 1));

--    stage_counter : out integer


    type ADDRESS_ROM_TYPE is array(0 to 15) of std_logic_vector(3 downto 0);
    type CONTROL_ROM_TYPE is array(0 to 15) of STD_LOGIC_VECTOR(0 to 23);

    constant ADDRESS_ROM_CONTENTS : ADDRESS_ROM_TYPE := (
        0 => "0011",     -- LDA
        1 => "0110",     -- ADD
        2 => "1001",     -- SUB
        14 => "1100",     -- OUT
        15 => "0000",       -- HLT
        others => "0000"
    );

    constant NOP : STD_LOGIC_VECTOR(0 to 23) := "000000000000000000000000";

    constant CONTROL_ROM : CONTROL_ROM_TYPE := (
       -- FETCH
    --    0 =>  "0000011011",     -- Phase1:   PC -> MAR
    --    1 =>  "1111111011",     -- Phase2:   INC PC
    --    2 =>  "1000101011",     -- Phase3:   RAM -> IR
       0 =>  "000100000001000000000000",     -- Phase1:   PC -> MAR;
       1 =>  "000000000000010000000000",     -- Phase2:   INC PC; MDR READ
       2 =>  "001000000000000100000000",     -- Phase3:   MDR -> IR
       3 =>  "000000000000000000000000",     -- NOP
       4 =>  "000000000000000000000000",     -- NOP
       5 =>  "000000000000000000000000",     -- NOP
       6 =>  "000000000000000000000000",     -- NOP
       7 =>  "000000000000000000000000",     -- NOP
       8 =>  "000000000000000000000000",     -- NOP
       9 =>  "000000000000000000000000",     -- NOP
       10 =>  "000000000000000000000000",     -- NOP
       11 =>  "000000000000000000000000",     -- NOP
       12 =>  "000000000000000000000000",     -- NOP
       13 =>  "000000000000000000000000",     -- NOP
       14 =>  "000000000000000000000000",     -- NOP
       15 =>  "000000000000000000000000"     -- NOP

    --    -- LDA
    --    3 =>  "0110011011",     -- LDA Phase4: IR (operand portion) -> MAR
    --    4 =>  "1000110011",     -- LDA Phase5: RAM -> A
    --    5 =>  NOP,     -- LDA Phase6: NOP
    --    -- ADD
    --    6 =>  "0110011011",      -- ADD Phase4: IR(operand portion) -> MAR
    --    7 =>  "1000111001",      -- ADD Phase5: RAM -> B, SU -> 0
    --    8 =>  "0100110011",      -- ADD Phase6: ALU -> A
    --    -- SUB
    --    9 =>  "0110011111",      -- SUB Phase4: IR(operand portion) -> MAR
    --    10 => "1000111101",      -- SUB Phase5: RAM -> B, SU => 1
    --    11 => "0100110111",      -- --SUB phase6: ALU => A
    --    -- OUT
    --    12 => "0010111010",      -- OUT phase 4  A => OUT
    --    13 => NOP,      -- OUT phase 5 NOP
    --    14 => NOP,      -- OUT phase 5 NOP
    --    -- unused
    --    15 => NOP       --NOP
       
       );

begin
    HLTBAR <= '0' when opcode = x"76" else
        '1';
    stage_out <= stage_sig;

    run_mode_process:
        process(clk, clrbar, opcode)
            variable stage_var : integer := 1;
            variable control_word_index : std_logic_vector(3 downto 0);
            variable control_word : std_logic_vector(0 to 20);
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
                    --TODO bits need updating for SAP-2 architecture
                    control_word_signal <= control_word;
                    control_word_index_signal <= control_word_index;
                    wbus_sel <= control_word(0 to 3);
                    alu_op <= control_word(4 to 6);
                    acc_write_enable <= control_word(7);
                    b_write_enable <= control_word(8);
                    c_write_enable <= control_word(9);
                    tmp_write_enable <= control_word(10);
                    pc_write_enable <= control_word(11);
                    mar_write_enable <= control_word(12);
                    pc_increment <= control_word(13);
                    mdr_write_enable <= control_word(14);
                    mdr_direction <= control_word(15);
                    ir_opcode_write_enable <= control_word(16);
                    ir_operand_low_write_enable <= control_word(17);
                    ir_operand_high_write_enable <= control_word(18);
                    out_1_write_enable <= control_word(19);
                    out_2_write_enable <= control_word(20);

                    -- pc_increment <= control_word(3);
                    -- mar_write_enble <= control_word(4);
                    -- ir_opcode_write_enable <= control_word(5);
                    -- acc_write_enable <= control_word(6);
                    -- alu_op <= control_word(7);
                    -- b_write_enable <= control_word(8);
                    -- out_1_write_enable <= control_word(9);

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
