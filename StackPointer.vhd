library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- 16 bit program counter 
entity StackPointer is
    generic (
        WIDTH : integer := 16
    );
    Port ( 
        clk : in STD_LOGIC;
        clr : in STD_LOGIC;
        increment : in STD_LOGIC;
        decrement : in STD_LOGIC;
        data_out : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)

    );
end StackPointer;

architecture Behavioral of StackPointer is
begin
    process(clk, clr)
        variable internal_value : STD_LOGIC_VECTOR(15 downto 0) := (others => '1');
    begin
        if clr = '1' then
            internal_value := (others => '1');
        elsif rising_edge(clk) then
            if increment = '1' then
                internal_value := STD_LOGIC_VECTOR(unsigned(internal_value) + 1);
            elsif decrement = '1' then
                internal_value := STD_LOGIC_VECTOR(unsigned(internal_value) - 1);
            end if;
        end if;
        data_out <= internal_value;
    end process;
end Behavioral;

         