library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_rom is
    Port (
        clk : in STD_LOGIC;
        addr : in STD_LOGIC_VECTOR(9 downto 0);
        data_in : in STD_LOGIC_VECTOR(23 downto 0);
        write_enable : STD_LOGIC;
        data_out : out STD_LOGIC_VECTOR(23 downto 0)
    );
end control_rom;

architecture behavior of control_rom is
    attribute ram_style : string;
    type CONTROL_ROM_TYPE is array (0 to 2**10-1) of STD_LOGIC_VECTOR(23 downto 0);
    signal CTRL_ROM : CONTROL_ROM_TYPE := (
        others => (others => '0')
    );
attribute ram_style of CTRL_ROM : signal is "block";
begin
    process(addr, write_enable, data_in)
    begin
        if rising_edge(clk) then
            if write_enable = '1' then
                CTRL_ROM(to_integer(unsigned(addr))) <= data_in;
                data_out <= data_in;
            else 
                data_out <= CTRL_ROM(to_integer(unsigned(addr)));
            end if;
        end if;
    end process;
end behavior;