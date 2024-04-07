library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MemoryDataRegister is
    generic (
        WIDTH : integer := 8
    );
    Port (
        clk : in STD_LOGIC;
        clr : in STD_LOGIC;
        write_enable : in STD_LOGIC;
        direction : in STD_LOGIC;       -- 1 BUS->MDR->RAM ; 0 RAM->MDR->BUS
        bus_data_in : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        mem_data_in : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        data_out : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
end MemoryDataRegister;

architecture behavior of MemoryDataRegister is
begin
    process(clk, clr)
        variable internal_data : STD_LOGIC_VECTOR(WIDTH-1 downto 0) := (others => '0');
    begin
        if clr = '1' then
            internal_data := (others => '0');
        elsif rising_edge(clk) then
            if write_enable = '1' then
                if direction = '1' then
                    internal_data := bus_data_in;
                else 
                    internal_data := mem_data_in;
                end if;
            end if;
        end if;
        data_out <= internal_data;
    end process;
end behavior;

    