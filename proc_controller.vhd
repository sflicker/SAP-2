library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use std.textio.all;
  
-- CONTROL WORD
-- BITS 0-3     W BUS Selector  - these are for components whose outputs are bus connected
                -- 0000 0H  All Zeros
                -- 0001 1H  PC
                -- 0010 2H  IR Operand
                -- 0011 3H  ALU Out
                -- 0100 4H  MDR Out
                -- 0101 5H  ACC Out
                -- 0110 6H  B Out
                -- 0111 7H  C Out
                -- 1000 8H  Tmp Out
                -- 1001 9H  Input 1
                -- 1002 AH  Input 2
                -- WE Selector
--  BITS 4-7    ALU Operation
                -- 0000 OH   ALU NOP
                -- 0001 1H   ADD
                -- 0010 2H   SUB
                -- 0011 3H   INCREMENT
                -- 0100 4H   DECREMENT
                -- 0101 5H   AND
                -- 0110 6H   OR
                -- 0111 7H   XOR
                -- 1000 8H   Complement
                -- 1001 9H   RAL
                -- 1010 AH   RAR
--  BIT 8       PC Increment
--  BIT 9       IR Clear
--  BIT A       ACCUMULATOR Write Enable         -- next 12 bits are WE for components whose inputs are bus connected
--  BIT B       B Write Enable
--  BIT C       C Write Enable
--  BIT D       TMP Write Enable
--  BIT E       MAR Write Enable
--  BIT F       PC Write Enable
--  BIT 10      MDR-TM Write Enable
--  BIT 11      IR Write Enable
--  BIT 12      IR Operand Low Write Enable
--  BIT 14      IR Operand High Write Enable
--  BIT 15      OUT Port 1 Write Enable
--  BIT 16      OUT Port 2 Write Enable
--  BIT 17      MDR-FM WE                       -- WE for components not connected to 
--  BIT 18      RAM WE
--  BIT 19      Update Status Flags
--  BIT 1A      NOT M NEXT
--  BIT 1B      NOT Z Next
--  BIT 1C      NOT NZ next
--  BIT 1D      WAIT        -- use this if an another controller is running

-- SAP-2 Opcodes
-- ADD B        80      ; Accum <= Accum + B ; includes flag updates
-- ADD C        81      ; Accum <= Accum + C ; includes flag updates
-- ANA B        A0      ; Accum <= Accum AND B ; includes flag updates
-- ANA C        A1      ; Accum <= Accum AND C ; includes flag updates
-- ANI byte     E6      ; Accum <= Accum AND byte ; includes flag updatesm
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
    minus_flag : in STD_LOGIC;
    equal_flag : in STD_LOGIC;

    -- outputs
    wbus_sel : out STD_LOGIC_VECTOR(3 downto 0);
    alu_op : out STD_LOGIC_VECTOR(3 downto 0);
    acc_write_enable : out STD_LOGIC;
    b_write_enable : out STD_LOGIC;
    c_write_enable : out STD_LOGIC;
    tmp_write_enable : out STD_LOGIC;
    mar_write_enable : out STD_LOGIC;
    pc_write_enable : out STD_LOGIC;
    pc_increment : out STD_LOGIC;
    mdr_write_enable : out STD_LOGIC;
    mdr_direction : out STD_LOGIC;
    ram_write_enable : out STD_LOGIC;
    ir_opcode_write_enable : out STD_LOGIC;
    ir_operand_low_write_enable : out STD_LOGIC;
    ir_operand_high_write_enable : out STD_LOGIC;
    ir_clear : out STD_LOGIC;
    out_port_3_write_enable : out STD_LOGIC;
    out_port_4_write_enable : out STD_LOGIC;
    update_status_flags : out STD_LOGIC;
    controller_wait : out STD_LOGIC;
    
    HLTBar : out STD_LOGIC;
    stage_out : out integer
    );
end proc_controller;

architecture Behavioral of proc_controller is
    signal stage_sig : integer := 1;

    signal control_word_index_signal : std_logic_vector(9 downto 0);
    signal control_word_signal : std_logic_vector(0 to 28);

--    phase_out <= std_logic_vector(shift_left(unsigned'("000001"), stage_counter_sig - 1));

--    stage_counter : out integer


    type ADDRESS_ROM_TYPE is array(0 to 255) of std_logic_vector(9 downto 0);
    type CONTROL_ROM_TYPE is array(0 to 1023) of STD_LOGIC_VECTOR(0 to 28);

    impure function init_address_rom return ADDRESS_ROM_TYPE is
        file text_file : text open read_mode is "instruction_index.txt";
        variable text_line : line;
        variable rom_content : ADDRESS_ROM_TYPE;
    begin
        for i in 0 to 255 loop 
            readline(text_file, text_line);
            bread(text_line, rom_content(i));
        end loop;

        return rom_content;
    end function;

    impure function init_control_rom return CONTROL_ROM_TYPE is
        file text_file : text open read_mode is "control_rom.txt";
        variable text_line : line;
        variable rom_content : CONTROL_ROM_TYPE;
    begin
        for i in 0 to 1023 loop 
            readline(text_file, text_line);
            bread(text_line, rom_content(i));
        end loop;

        return rom_content;
    end function;

    constant ADDRESS_ROM_CONTENTS : ADDRESS_ROM_TYPE := init_address_rom;

    constant NOP : STD_LOGIC_VECTOR(0 to 28) := "00000000000000000000000000000";

    constant CONTROL_ROM : CONTROL_ROM_TYPE := init_control_rom;

    procedure output_control_word(
        variable stage_var : integer := 1;
        variable control_word : std_logic_vector(0 to 28)) is
    begin
        Report "Stage: " & to_string(stage_var) 
            & ", wbus_sel: " & to_string(control_word(0 to 3))
            & ", alu_op: " & to_string(control_word(4 to 7))
            & ", acc_write_enable: " & to_string(control_word(8))
            & ", b_write_enable: " & to_string(control_word(9))
            & ", c_write_enable: " & to_string(control_word(10))
            & ", tmp_write_enable: " & to_string(control_word(11))
            & ", mar_write_enable: " & to_string(control_word(12))
            & ", pc_write_enable: " & to_string(control_word(13))
            & ", pc_increment: " & to_string(control_word(14))
            & ", mdr_write_enable: " & to_string(control_word(15))
            & ", mdr_direction: " & to_string(control_word(16))
            & ", ram_write_enable: " & to_string(control_word(17))
            & ", ir_opcode_write_enable: " & to_string(control_word(18))
            & ", ir_operand_low_write_enable: " & to_string(control_word(19))
            & ", ir_operand_high_write_enable: " & to_string(control_word(20))
            & ", ir_clear: " & to_string(control_word(21))
            & ", out_1_write_enable: " & to_string(control_word(22))
            & ", out_2_write_enable: " & to_string(control_word(23))
            & ", update_status_flags: " & to_string(control_word(24))
            & ", not_m_next: " & to_string(control_word(25))
            & ", not_z_next: " & to_string(control_word(26))
            & ", not_nz_next: " & to_string(control_word(27))
            & ", controller_wait: " & to_string(control_word(28));

    end procedure;

begin
    HLTBAR <= '0' when opcode = x"76" else
        '1';
    stage_out <= stage_sig;

    run_mode_process:
        process(clk, clrbar, opcode)
            variable stage_var : integer := 1;
            variable control_word_index : std_logic_vector(9 downto 0);
            variable control_word : std_logic_vector(0 to 28);
        begin

            if CLRBAR = '0' then
                stage_var := 1;
                stage_sig <= stage_var;
            elsif rising_edge(clk) then
                if stage_var = 1 then
                    control_word_index := "0000000000";
                elsif stage_var = 5 then
                    control_word_index := ADDRESS_ROM_CONTENTS(to_integer(unsigned(opcode)));
                else 
                    control_word_index := std_logic_vector(unsigned(control_word_index) + 1);
                end if;

                Report "Control Word Index: " & to_string(control_word_index);
                control_word := CONTROL_ROM(to_integer(unsigned(control_word_index)));

                Report "Stage: " & to_string(stage_var) 
                    & ", control_word_index: " & to_string(control_word_index) 
                    & ", control_word: " & to_string(control_word) & ", opcode: " & to_string(opcode);

                if control_word = NOP or 
                    (control_word(25) = '1' and minus_flag = '0') or
                    (control_word(26) = '1' and equal_flag = '0') or
                    (control_word(27) = '1' and equal_flag = '1')  then
                        Report "NOP detected moving to next instruction";
                        stage_var := 1;
                        stage_sig <= stage_var;
    --                    stage_counter <= stage;
                else
                    --TODO bits need updating for SAP-2 architecture
                    output_control_word(stage_var, control_word);
                    control_word_signal <= control_word;
                    control_word_index_signal <= control_word_index;

                    wbus_sel <= control_word(0 to 3);
                    alu_op <= control_word(4 to 7);
                    acc_write_enable <= control_word(8);
                    b_write_enable <= control_word(9);
                    c_write_enable <= control_word(10);
                    tmp_write_enable <= control_word(11);
                    mar_write_enable <= control_word(12);
                    pc_write_enable <= control_word(13);
                    pc_increment <= control_word(14);
                    mdr_write_enable <= control_word(15);
                    mdr_direction <= control_word(16);
                    ram_write_enable <= control_word(17);                    
                    ir_opcode_write_enable <= control_word(18);
                    ir_operand_low_write_enable <= control_word(19);
                    ir_operand_high_write_enable <= control_word(20);
                    ir_clear <= control_word(21);
                    out_port_3_write_enable <= control_word(22);
                    out_port_4_write_enable <= control_word(23);
                    update_status_flags <= control_word(24);
                    controller_wait <= control_word(28);

                    -- pc_increment <= control_word(3);
                    -- mar_write_enble <= control_word(4);
                    -- ir_opcode_write_enable <= control_word(5);
                    -- acc_write_enable <= control_word(6);
                    -- alu_op <= control_word(7);
                    -- b_write_enable <= control_word(8);
                    -- out_1_write_enable <= control_word(9);

--                    stage_counter <= stage;
        
                    if stage_var >= 20 then
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
