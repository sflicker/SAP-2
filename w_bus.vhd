library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity w_bus is
  Port (sel_default : in STD_LOGIC_VECTOR(3 downto 0); 
        sel_io : in STD_LOGIC_VECTOR(3 downto 0);
        we_sel_default : in STD_LOGIC_VECTOR(0 to 13);
        we_sel_io : in STD_LOGIC_VECTOR(0 to 13);
        io_active : in STD_LOGIC;
        pc_addr_in : in STD_LOGIC_VECTOR(15 downto 0);
        stack_pointer_in : in STD_LOGIC_VECTOR(15 downto 0);
        IR_operand_in : in STD_LOGIC_VECTOR(15 downto 0);
        acc_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        alu_data_in  : in STD_LOGIC_VECTOR(7 downto 0);
        MDR_fm_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        B_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        C_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        tmp_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        input_port_1_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        input_port_2_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        bus_out : out STD_LOGIC_VECTOR(15 downto 0);
        acc_write_enable : out STD_LOGIC;
        b_write_enable : out STD_LOGIC;
        c_write_enable : out STD_LOGIC;
        tmp_write_enable : out STD_LOGIC;
        mar_write_enable : out STD_LOGIC;
        pc_write_enable : out STD_LOGIC;
        mdr_tm_write_enable : out STD_LOGIC;
        ir_opcode_write_enable : out STD_LOGIC;
        ir_operand_low_write_enable : out STD_LOGIC;
        ir_operand_high_write_enable : out STD_LOGIC;
        out_port_3_write_enable : out STD_LOGIC;
        out_port_4_write_enable : out STD_LOGIC;
        pc_write_enable_low : out STD_LOGIC;
        pc_write_enable_high : out STD_LOGIC
  );
end w_bus;

architecture Behavioral of w_bus is
    signal sel_active_sig : STD_LOGIC_VECTOR(3 downto 0);
    signal we_sel_active_sig : STD_LOGIC_VECTOR(0 to 13);
begin

    sel_active_sig <= sel_io when io_active = '1' else sel_default;
    we_sel_active_sig <= we_sel_io when io_active = '1' else we_sel_default;    

    process(sel_active_sig)
    begin
        case sel_active_sig is
            when "0000" => bus_out <= (others => '0');  -- zero
            when "0001" => bus_out <= pc_addr_in;
            when "0010" => bus_out <= IR_operand_in;
            when "0011" => bus_out <= ("00000000" & alu_data_in);
            when "0100" => bus_out <= ("00000000" & MDR_fm_data_in);
            when "0101" => bus_out <= ("00000000" & acc_data_in);
            when "0110" => bus_out <= ("00000000" & B_data_in);
            when "0111" => bus_out <= ("00000000" & C_data_in);
            when "1000" => bus_out <= ("00000000" & tmp_data_in);
            when "1001" => bus_out <= ("00000000" & input_port_1_data_in);
            when "1010" => bus_out <= ("00000000" & input_port_2_data_in);
            when "1011" => bus_out <= ("00000000" & pc_addr_in(7 downto 0));
            when "1100" => bus_out <= ("00000000" & pc_addr_in(15 downto 8));
            when "1101" => bus_out <= stack_pointer_in;
            when others => bus_out <= (others => '0');
        end case;
    end process;

    process(we_sel_active_sig)
    begin
        acc_write_enable <= we_sel_active_sig(0);
        b_write_enable <= we_sel_active_sig(1);
        c_write_enable <= we_sel_active_sig(2);
        tmp_write_enable <= we_sel_active_sig(3);
        mar_write_enable <= we_sel_active_sig(4);
        pc_write_enable <= we_sel_active_sig(5);
        mdr_tm_write_enable <= we_sel_active_sig(6);
        ir_opcode_write_enable <= we_sel_active_sig(7);
        ir_operand_low_write_enable <= we_sel_active_sig(8);
        ir_operand_high_write_enable <= we_sel_active_sig(9);
        out_port_3_write_enable <= we_sel_active_sig(10);
        out_port_4_write_enable <= we_sel_active_sig(11);
        pc_write_enable_low <= we_sel_active_sig(12);
        pc_write_enable_high <= we_sel_active_sig(13);
    end process;
end behavioral;
