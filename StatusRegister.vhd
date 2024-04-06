library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- minus_flag  - bit 0
-- equal_flag  - bit 1
-- others bits are current zero

entity StatusRegister is
    Port (
        clk : in STD_LOGIC;
        clr : in STD_LOGIC;
        minus_flag_we : in STD_LOGIC;
        minus_flag_in : in STD_LOGIC;
        minus_flag_out : out STD_LOGIC;
        equal_flag_we : in STD_LOGIC;
        equal_flag_in : in STD_LOGIC;
        equal_flag_out : in STD_LOGIC;
        status_flags_we : in STD_LOGIC;
        status_flags_in : in STD_LOGIC_VECTOR(7 downto 0);
        status_flags_out : in STD_LOGIC_VECTOR(7 downto 0)
    );
end StatusRegister;

architecture behavior of StatusRegister is
    signal minus_flag : STD_LOGIC;
    signal equal_flag : STD_LOGIC;
    signal status_flags : STD_LOGIC_VECTOR(1 downto 0);
begin
    process(clk) 
        variable equal_flag_var : STD_LOGIC := '0';
        variable minus_flag_var : STD_LOGIC := '0';
    begin
        if rising_edge(clk) then
            if clr = '1' then
                minus_flag_var := '0';
                equal_flag_var := '0';
            end if;
            if status_flags_we = '1' then
                minus_flag_var := status_flags_in(0);
                equal_flag_var := status_flags_in(1);
            else 
                if minus_flag_we = '1' then
                    minus_flag_var := minus_flag_in;
                end if;
                if equal_flag_we = '1' then
                    equal_flag_var := equal_flag_in;
                end if;
            end if;
        end if;
        minus_flag <= std_logic(minus_flag_var);
        equal_flag <= std_logic(equal_flag_var);
        status_flags <= '0' & '0' & '0' & '0' & '0' & '0' &
             std_logic(equal_flag_var) & std_logic(minus_flag_var);
    end process;
end behavior;