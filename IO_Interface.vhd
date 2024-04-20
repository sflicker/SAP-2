library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity IO_interface is
    Port(
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        opcode : IN STD_LOGIC_VECTOR(7 downto 0);
        portnum : IN STD_LOGIC_VECTOR(2 downto 0);      -- portnum (0 none, 1 input 1, 2 input 2, 3 output 1, 4 output 2)
--        input1 : IN STD_LOGIC_VECTOR(7 downto 0);
--        input2 : IN STD_LOGIC_VECTOR(7 downto 0);
--        bus_input : IN STD_LOGIC_VECTOR(7 downto 0);
--        bus_output : OUT STD_LOGIC_VECTOR(7 downto 0);
--        output1 : OUT STD_LOGIC_VECTOR(7 downto 0);
--        output2 : OUT STD_LOGIC_VECTOR(7 downto 0);
        bus_selector : OUT STD_LOGIC_VECTOR(3 downto 0);
        acc_write_enable : OUT STD_LOGIC;
        output1_write_enable : OUT STD_LOGIC;
        output2_write_enable : OUT STD_LOGIC;
        active : OUT STD_LOGIC
    );
end IO_interface;

architecture behavioral of IO_interface is
    constant IN_byte_OPCODE : STD_LOGIC_VECTOR(7 downto 0) := x"DB";
    constant OUT_byte_OPCODE : STD_LOGIC_VECTOR(7 downto 0) := x"D3";
begin
    process(clk, rst)
    begin
        if rst = '1' then
            output1_write_enable <= '0';
            output2_write_enable <= '0';
  --          select_input_out <= (others => '0');
  --          output1 <= (others => '0');
  --          output2 <= (others => '0');
            active <= '0';
        elsif rising_edge(clk) then
            -- DB is opcode for IN byte
            -- D3 is opcode for OUT byte
            if opcode = IN_byte_OPCODE then 
                case portnum is
                    -- port 1
                    when "001" =>
--                        bus_output <= input1;
                        bus_selector <= "1001";
                        acc_write_enable <= '1';
                    -- port 2
                    when "010" =>
--                        bus_output <= input2;
                        bus_selector <= "1010";
                        acc_write_enable <= '1';
                    when others =>
--                        select_input_out <= (others => '0');
--                        acc_write_enable <= '0';
--                        output1_write_enable <= '0';
--                        output2_write_enable <= '1';
                end case;
            elsif opcode = OUT_byte_OPCODE then
                active <= '1';
                case portnum is
                    -- port 3
                    when "011" =>
                        bus_selector <= "0101";
--                        output1 <= bus_output;
--                        output2 <= (others => '0');
                        output1_write_enable <= '1';
                        output2_write_enable <= '0';
                    when "100" =>
                        bus_selector <= "0101";
  --                      output2 <= bus_output;
  --                      output1 <= (others => '0');
                        output1_write_enable <= '0';
                        output2_write_enable <= '1';
                    when others =>
                        output1_write_enable <= '0';
                        output2_write_enable <= '0';
--                        output1 <= (others => '0');
--                        output2 <= (others => '0');
                end case;
            else
                active <= '0';
            end if;

        end if;
    end process;
end behavioral;
