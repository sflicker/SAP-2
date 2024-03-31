library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- 16 bit program counter 
entity pc is
    Port ( 
        clkbar : in STD_LOGIC;
        clrbar : in STD_LOGIC;
        Cp : in STD_LOGIC;
        LPBar : in STD_LOGIC;
        pc_in : out STD_LOGIC_VECTOR(15 downto 0);
        pc_out : out STD_LOGIC_VECTOR(15 downto 0)
        );
   
end pc;

architecture Behavioral of pc is
    -- signal internal_value : STD_LOGIC_VECTOR(3 downto 0) := "0000";
begin

    process(clkbar, clrbar)
        variable internal_value : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
    begin
        if clrbar = '0' then
            internal_value := (others => '0');
        elsif falling_edge(clkbar) then
            if Cp = '1' then
                internal_value := STD_LOGIC_VECTOR(unsigned(internal_value) + 1);
            elsif LPBar = '0' then
                internal_value := pc_in;
            end if;
        end if;
        pc_out <= internal_value;
        
    end process;
end Behavioral;
