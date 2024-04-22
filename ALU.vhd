library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( clr : in STD_LOGIC;
           op : in STD_LOGIC_VECTOR(3 downto 0);
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
        elsif op = "0001" then -- ADD
            result := std_logic_vector(unsigned(input_1) + unsigned(input_2));
            update_flags(result, minus_flag, equal_flag, update_status_flags);
        elsif op = "0010" then  -- SUB
            result := std_logic_vector(unsigned(input_1) - unsigned(input_2));
            update_flags(result, minus_flag, equal_flag, update_status_flags);
        elsif op = "0011" then  -- INC
            result := std_logic_vector(unsigned(input_2) + 1);
            update_flags(result, minus_flag, equal_flag, update_status_flags);
        elsif op = "0100" then  -- DEC
            result := std_logic_vector(unsigned(input_2) - 1);
            update_flags(result, minus_flag, equal_flag, update_status_flags);
        elsif op = "0101" then  -- AND
            result := std_logic_vector(unsigned(input_1) AND unsigned(input_2));
            update_flags(result, minus_flag, equal_flag, update_status_flags);
        elsif op = "0110" then  -- OR
            result := std_logic_vector(unsigned(input_1) OR unsigned(input_2));
            update_flags(result, minus_flag, equal_flag, update_status_flags);
        elsif op = "0111" then  -- XOR
            result := std_logic_vector(unsigned(input_1) XOR unsigned(input_2));
            update_flags(result, minus_flag, equal_flag, update_status_flags);
        elsif op = "1000" then  -- Complement
            result := std_logic_vector(not unsigned(input_2));
            -- do not update flags in this case
        elsif op = "1001" then -- rotate left
            result := input_2(6 downto 0) & input_2(7);
        elsif op = "1010" then -- rotate right
            result := input_2(0) & input_2(7 downto 1);
        else
            result := result;
            -- no action. typically this would be op = 0
        end if;
        alu_out <= result;
    end process;
end Behavioral;
