library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity w_bus is
  Port (sel : in STD_LOGIC_VECTOR(2 downto 0); 
        pc_data_in : in STD_LOGIC_VECTOR(15 downto 0);
        acc_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        alu_data_in  : in STD_LOGIC_VECTOR(7 downto 0);
        IR_data_in : in STD_LOGIC_VECTOR(3 downto 0);
        RAM_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        data_out : out STD_LOGIC_VECTOR(15 downto 0)
  );
end w_bus;

architecture Behavioral of w_bus is
begin
    process(sel)
    begin
        case sel is
            when "000" => data_out(15 downto 0) <= pc_data_in;
            when "001" => data_out <= ("00000000" & acc_data_in);
            when "010" => data_out <= ("00000000" & alu_data_in);
            when "011" => data_out(3 downto 0) <= IR_data_in;
                          data_out(7 downto 4) <= (others => '0');
            when "100" => data_out <= ("00000000" & RAM_data_in);
            when others => data_out <= (others => '0');
        end case;
    end process;
end behavioral;
