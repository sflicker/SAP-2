library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DataRegister is 
    generic (
        WIDTH : integer := 8
    );
    Port (
        clk : in STD_LOGIC;
        clr : in STD_LOGIC;
        write_enable : in STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        data_out : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
end DataRegister;

architecture Behavioral of DataRegister is

begin
    process(clk)
    variable internal_data : STD_LOGIC_VECTOR(WIDTH-1 downto 0) 
        := (others => '0');
    begin
        if rising_edge(clk) then
            if clr = '1' then
                internal_data := (others => '0');
            elsif write_enable = '1' then
                internal_data := data_in;
            end if;
        end if;
        data_out <= internal_data;
    end process;
end behavioral;
