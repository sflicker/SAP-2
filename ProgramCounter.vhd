library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- 16 bit program counter 
entity ProgramCounter is
    generic (
        WIDTH : integer := 16;
    )
    Port ( 
        clkbar : in STD_LOGIC;
        clr : in STD_LOGIC;
        increment : in STD_LOGIC;
        enable_write : in STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        data_out : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
        );
   
end pc;

architecture Behavioral of ProgramCounter is
    -- signal internal_value : STD_LOGIC_VECTOR(3 downto 0) := "0000";
begin

    process(clkbar, clr)
        variable internal_value : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    begin
        if clr = '1' then
            internal_value := (others => '0');
        elsif falling_edge(clkbar) then
            if increment = '1' then
                internal_value := STD_LOGIC_VECTOR(unsigned(internal_value) + 1);
            elsif enable_write = '1' then
                internal_value := data_in;
            end if;
        end if;
        data_out <= internal_value;
        
    end process;
end Behavioral;
