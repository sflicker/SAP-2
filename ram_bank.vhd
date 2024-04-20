library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 16 bit RAM
-- asynchronous
entity ram_bank is
    Port ( 
           clk : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR(15 downto 0);     -- 8 bit addr
           data_in : in STD_LOGIC_VECTOR(7 downto 0);   -- 8 bit data
           write_enable : in STD_LOGIC;                 -- load data at addr - active hit
           data_out : out STD_LOGIC_VECTOR(7 downto 0)  -- data out from addr
           ); 
end ram_bank;

architecture Behavioral of ram_bank is
    attribute ram_style : string;
    type RAM_TYPE is array(0 to 2**16-1) of STD_LOGIC_VECTOR(7 downto 0);
    signal RAM : RAM_TYPE := (
        others => (others => '0'));

    attribute ram_style of RAM : signal is "block";
begin
    -- dont use clock for ram

    process(clk, addr, write_enable, data_in)
        variable data_var : STD_LOGIC_VECTOR(7 downto 0);
    begin
        if rising_edge(clk) then
            Report "Ram_Bank - write_enable: " & to_string(write_enable) &
                ", addr: " & to_string(addr) & ", data_in: " & to_string(data_in);
            if write_enable = '1' then
                Report "Writing Data to Memory";
                RAM(to_integer(unsigned(addr))) <= data_in;
            else 
                data_var := RAM(to_integer(unsigned(addr)));
                data_out <= data_var;
                Report "Reading Data from Memory - data: " & to_string(data_var);
            end if;
--            Report "Ram_Bank - data_out: " & to_string(data_out);
        end if;
    end process;
end Behavioral;
