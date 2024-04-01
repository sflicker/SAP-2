library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mem_test_top is
    Port ( clk : in std_logic );
end mem_test_top;

architecture Behavioral of mem_test_top is
    signal mar_addr_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal ram_data_in_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal ram_data_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal data_counter : unsigned(7 downto 0) := (others => '0');
    signal addr_counter : unsigned(15 downto 0) := (others => '0');
begin

    ram_bank : entity work.ram_bank
    port map(
        addr => mar_addr_sig,
        data_in => ram_data_in_sig,
        write_enable => '1',
        data_out => ram_data_out_sig
    );

    mem_test : process(clk)
    begin
        if rising_edge(clk) then 
            mar_addr_sig <= std_logic_vector(addr_counter);
            ram_data_in_sig <= std_logic_vector(data_counter);
            addr_counter <= addr_counter + 1;
            data_counter <= data_counter + 1;
        end if;
    end process;
end Behavioral;