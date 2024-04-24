library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- 16 bit program counter 
entity ProgramCounter is
    generic (
        WIDTH : integer := 16
    );
    Port ( 
        clk : in STD_LOGIC;
        clr : in STD_LOGIC;
        increment : in STD_LOGIC;
        write_enable_full : in STD_LOGIC;
        write_enable_low : in STD_LOGIC;
        write_enable_high :in STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        data_out : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
   
end ProgramCounter;

architecture Behavioral of ProgramCounter is
    -- signal internal_value : STD_LOGIC_VECTOR(3 downto 0) := "0000";
begin

    process(clk, clr)
        variable internal_value : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    begin
        if clr = '1' then
            internal_value := (others => '0');
        elsif rising_edge(clk) then
            if increment = '1' then
                internal_value := STD_LOGIC_VECTOR(unsigned(internal_value) + 1);
            elsif write_enable_full = '1' then
                internal_value := data_in;
            elsif write_enable_low = '1' then
                internal_value(7 downto 0) := data_in(7 downto 0);
            elsif write_enable_high = '1' then
                internal_value(15 downto 8) := data_in(7 downto 0);
            end if;
        end if;
        data_out <= internal_value;
        
    end process;
end Behavioral;
