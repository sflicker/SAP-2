library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mem_test_top is
    Port ( clk : in std_logic;
           rst : in std_logic;
           running : out std_logic;
           finished : out std_logic 
         );
end mem_test_top;

architecture Behavioral of mem_test_top is
    signal addr_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal data_in_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal data_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal data_counter : unsigned(7 downto 0) := (others => '0');
    signal addr_counter : unsigned(15 downto 0) := (others => '0');
    signal write_enable_sig : STD_LOGIC;
    signal hltbar : STD_LOGIC := '1';
    signal control_rom_addr_sig : STD_LOGIC_VECTOR(9 downto 0);
    signal control_rom_data_in_sig : STD_LOGIC_VECTOR(23 downto 0);
    signal control_rom_write_enable_sig : STD_LOGIC;
    signal control_rom_data_out_sig : STD_LOGIC_VECTOR(23 downto 0);
begin

    ram_bank : entity work.ram_bank
    port map(
        clk => clk,
        addr => addr_sig,
        data_in => data_in_sig,
        write_enable => write_enable_sig,
        data_out => data_out_sig
    );

    ctrl_rom : entity work.control_rom
    port map(
        clk => clk,
        addr => control_rom_addr_sig,
        data_in => control_rom_data_in_sig,
        write_enable => control_rom_write_enable_sig,
        data_out => control_rom_data_out_sig
    );

    mem_test : process(clk, rst, hltbar)
    variable toggle_write : integer := 1;
    variable data_read : std_logic_vector(7 downto 0);
    variable cycles_counter : integer := 0;
    begin
        if rst = '1' then
            data_counter <= (others => '0');
            addr_counter <= (others => '0');
            hltbar <= '1';
            running <= '1';
            finished <= '0';
        elsif hltbar = '0' then
            finished <= '1';
            running <= '0';
        elsif rising_edge(clk) then 
            if toggle_write = 1 then
                -- write a byte to ram
                write_enable_sig <= '1';
                toggle_write := 0;
                addr_sig <= std_logic_vector(addr_counter);
                data_in_sig <= std_logic_vector(data_counter);
            else
                -- read a byte from ram
                write_enable_sig <= '1';
                addr_sig <= std_logic_vector(addr_counter);
                data_read := data_out_sig;
                toggle_write := 1;
                if addr_counter = "1111111111111111" then
                    cycles_counter := cycles_counter + 1;
                end if;
                
                if cycles_counter >= 10 then
                    hltbar <= '0';
                else 
                    addr_counter <= addr_counter + 1;
                    data_counter <= data_counter + 1;
                end if;                
            end if;            
        end if;
    end process;
end Behavioral;