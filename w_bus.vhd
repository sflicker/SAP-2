library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity w_bus is
  Port (sel : in STD_LOGIC_VECTOR(3 downto 0); 
        pc_addr_in : in STD_LOGIC_VECTOR(15 downto 0);
        IR_operand_in : in STD_LOGIC_VECTOR(15 downto 0);
        acc_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        alu_data_in  : in STD_LOGIC_VECTOR(7 downto 0);
        MDR_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        B_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        C_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        tmp_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        input_1_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        input_2_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        bus_out : out STD_LOGIC_VECTOR(15 downto 0)
  );
end w_bus;

architecture Behavioral of w_bus is
begin
    process(sel)
    begin
        case sel is
            when "0000" => bus_out <= (others => '0');  -- zero
            when "0001" => bus_out <= pc_addr_in;
            when "0010" => bus_out <= IR_operand_in;
            when "0011" => bus_out <= ("00000000" & alu_data_in);
            when "0100" => bus_out <= ("00000000" & MDR_data_in);
            when "0101" => bus_out <= ("00000000" & B_data_in);
            when "0110" => bus_out <= ("00000000" & C_data_in);
            when "0111" => bus_out <= ("00000000" & tmp_data_in);
            when "1000" => bus_out <= ("00000000" & acc_data_in);
            when "1001" => bus_out <= ("00000000" & input_1_data_in);
            when "1010" => bus_out <= ("00000000" & input_2_data_in);
            when others => bus_out <= (others => '0');
        end case;
    end process;
end behavioral;
