library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Register is 
    generic (
        WIDTH : integer := 8;
    )
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        write_enable : in STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        data_out : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
    );

architecture Behavioral of Register is
    signal internal_data : STD_LOGIC_VECTOR(WIDTH-1 downto 0) 
        := (others => '0');
begin
    process(clk)
        if rising_edge(clk) then
            if rst = '1' then
                internal_data := (others => '0');
            elsif write_enable = '1' then
                internal_data := data_in;
            end if;
        end if;
        data_out <= internal_data;
    end process;
end behavioral;
