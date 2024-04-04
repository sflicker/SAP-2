library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity IR_operand_latch is
    Port (
        clk : in STD_LOGIC;
        clr : in STD_LOGIC;
        ir_operand_in : in STD_LOGIC_VECTOR(7 downto 0);
        Load_IR_Operand_Low_Bar : in STD_LOGIC;
        Load_IR_Operand_High_Bar : in STD_LOGIC;
        operand_low_out : out STD_LOGIC_VECTOR(7 downto 0);
        operand_high_out : out STD_LOGIC_VECTOR(7 downto 0)
    );
end IR_operand_latch;

architecture rtl of IR_operand_latch is
    
begin
    process(clk, clr)
    begin
        -- this should probably be cleared at the beginning
        -- of every fetch cycle
        if clr = '1' then
            operand_low_out <= "00000000";
            operand_high_out <= "00000000";
        elsif clk = '1' then
            if Load_IR_OPERAND_LOW_Bar = '0' then
                operand_low_out <= ir_operand_in;
            elsif LOAD_IR_OPERAND_HIGH_Bar = '0' then
                operand_high_out <= ir_operand_in;
            end if;
        end if;
    end process;
    
end architecture rtl;