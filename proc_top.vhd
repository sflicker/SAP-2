library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity proc_top is
    generic (
        SIMULATION_MODE : boolean := false
    );
    port( clk_ext : in STD_LOGIC;  -- map to FPGA clock will be stepped down to 1HZ
                                -- for simulation TB should generate clk of 1HZ
          S1_addr_in : in STD_LOGIC_VECTOR(15 downto 0);       -- address setting - S1 in ref
          S2_prog_run_switch : in STD_LOGIC;       -- prog / run switch (prog=0, run=1)
          S3_data_in : in STD_LOGIC_VECTOR(7 downto 0);       -- data setting      S3 in ref
          S4_read_write_switch : in STD_LOGIC;       -- read/write toggle   -- 1 to write values to ram. 0 to read. needs to be 0 for run mode
          S5_clear_start : in STD_LOGIC;       -- start/clear (reset)  -- 
          S6_step_toggle : in STD_LOGIC;       -- single step -- 1 for a single step
          S7_manual_auto_switch : in STD_LOGIC;       -- manual/auto mode - 0 for manual, 1 for auto. 
          memory_access_clk : in STD_LOGIC;  -- toogle memory write. if in program, write and manual mode. this is the ram clock for prog mode. execution mode should use the system clock.
          in_port_1 : in STD_LOGIC_VECTOR(7 downto 0);
          in_port_2 : in STD_LOGIC_VECTOR(7 downto 0);
          out_port_3 : out STD_LOGIC_VECTOR(7 downto 0);
          out_port_4 : out STD_LOGIC_VECTOR(7 downto 0);
          data_out : out STD_LOGIC_VECTOR(7 downto 0);
          running : out STD_LOGIC;
          s7_anodes_out : out STD_LOGIC_VECTOR(3 downto 0);      -- maps to seven segment display
          s7_cathodes_out : out STD_LOGIC_VECTOR(6 downto 0);     -- maps to seven segment display
          phase_out : out STD_LOGIC_VECTOR(5 downto 0);
          clear_out : out STD_LOGIC;
          step_out : out STD_LOGIC
    );
    attribute MARK_DEBUG : string;
    attribute MARK_DEBUG of S5_clear_start : signal is "true";
    attribute MARK_DEBUG of S6_step_toggle : signal is "true";
    attribute MARK_DEBUG of S7_manual_auto_switch : signal is "true";
    attribute MARK_DEBUG of running : signal is "true";

end proc_top;

architecture behavior of proc_top is

--    attribute MARK_DEBUG : string;

    signal clk_ext_converted_sig : STD_LOGIC;
    signal clk_sys_sig : std_logic;
    signal clkbar_sys_sig : std_logic;
    signal clk_disp_refresh_1KHZ_sig : std_logic;
    signal hltbar_sig : std_logic := '1';
    signal clr_sig : STD_LOGIC;
    signal clrbar_sig : STD_LOGIC;
    signal wbus_sel_sig : STD_LOGIC_VECTOR(3 downto 0);
    signal wbus_sel_io_sig : STD_LOGIC_VECTOR(3 downto 0);       
    signal alu_op_sig : std_logic_vector(3 downto 0);
    signal acc_data_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal alu_data_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal IR_operand_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal IR_opcode_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal ir_clear_sig : STD_LOGIC;
    signal RAM_data_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal w_bus_data_out_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal mar_addr_sig: STD_LOGIC_VECTOR(15 downto 0);
    signal ram_addr_in_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal ram_data_in_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal b_data_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal c_data_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal tmp_data_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal display_data : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal stage_counter_sig : INTEGER;
    signal output_1_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal output_2_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal write_enable_PC_sig : STD_LOGIC;
    signal pc_increment_sig : STD_LOGIC;
    signal write_enable_ir_opcode_sig : STD_LOGIC;
    signal write_enable_low_sig : STD_LOGIC;
    signal write_enable_high_sig : STD_LOGIC;
    signal operand_low_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal operand_high_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal ram_write_enable_sig : STD_LOGIC;
    signal selected_ram_write_enable_sig : STD_LOGIC;
    signal ram_clk_in_sig : STD_LOGIC;
    signal write_enable_acc_sig : STD_LOGIC;
    signal write_enable_mar_sig : STD_LOGIC;
    signal write_enable_B_sig: STD_LOGIC;
    signal write_enable_C_sig : STD_LOGIC;
    signal write_enable_output_sig : STD_LOGIC;
    signal write_enable_tmp_sig : STD_LOGIC;
    signal out_port_3_write_enable_sig : STD_LOGIC;
    signal out_port_4_write_enable_sig : STD_LOGIC;
    signal pc_data_out_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal minus_flag_sig : STD_LOGIC;
    signal equal_flag_sig : STD_LOGIC;
    signal alu_buffer_out : STD_LOGIC_VECTOR(7 downto 0);
    signal mdr_data_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal mdr_direction_sig : STD_LOGIC;
    signal write_enable_mdr_sig : STD_LOGIC;
    signal write_enable_alu_out_sig : STD_LOGIC;
    signal alu_data_out : STD_LOGIC_VECTOR(7 downto 0);
    signal update_status_flags_sig : STD_LOGIC;
    signal data_out_signal : STD_LOGIC_VECTOR(7 downto 0); 
    signal input_port_1_data_in_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal input_port_2_data_in_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal controller_wait_sig : STD_LOGIC;
    signal io_active_sig : STD_LOGIC;
    signal mdr_fm_data_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal wbus_output_connected_components_write_enable_sig : STD_LOGIC_VECTOR(0 to 11);
    signal wbus_output_we_default_sig : STD_LOGIC_VECTOR(0 to 13);
    signal wbus_output_we_io_sig : STD_LOGIC_VECTOR(0 to 13);
    signal write_enable_mdr_fm_sig : STD_LOGIC;
    signal mdr_tm_data_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal acc_write_enable : STD_LOGIC;
    signal write_enable_mdr_tm_sig : STD_LOGIC;
    signal sp_increment_sig : STD_LOGIC;
    signal sp_decrement_sig : STD_LOGIC;
    signal sp_data_out_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal pc_write_enable_low_sig : STD_LOGIC;
    signal pc_write_enable_high_sig : STD_LOGIC;

    attribute MARK_DEBUG of clk_ext_converted_sig : signal is "true";
    attribute MARK_DEBUG of clk_sys_sig : signal is "true";
    attribute MARK_DEBUG of clkbar_sys_sig : signal is "true";
    
    attribute MARK_DEBUG of hltbar_sig : signal is "true";
    attribute MARK_DEBUG of clrbar_sig : signal is "true";
    attribute MARK_DEBUG of clr_sig : signal is "true";
    attribute MARK_DEBUG of alu_op_sig : signal is "true";
    attribute MARK_DEBUG of mar_addr_sig : signal is "true";
    attribute MARK_DEBUG of IR_opcode_sig : signal is "true";
    attribute MARK_DEBUG of IR_operand_sig : signal is "true";
    attribute MARK_DEBUG of acc_data_sig : signal is "true";
    attribute MARK_DEBUG of b_data_sig : signal is "true";
    attribute MARK_DEBUG of output_1_sig : signal is "true";
begin

    clr_sig <= '1' when S5_clear_start = '1' else '0';
    clrbar_sig <= not clr_sig;
    running <= S7_manual_auto_switch and hltbar_sig;
    clear_out <= S5_clear_start;
    step_out <= S6_step_toggle; 
    data_out <= ram_data_out_sig;

    IR_operand_sig <= operand_high_out_sig & operand_low_out_sig;
     
   -- phase_out <= std_logic_vector(shift_left(unsigned'("000001"), stage_counter_sig - 1));
    
    GENERATING_CLOCK_CONVERTER:
        if SIMULATION_MODE
        generate
            passthrough_clock_converter : entity work.passthrough_clock_converter
            port map (
                clrbar => clrbar_sig,
                clk_in => clk_ext,   -- simulation test bench should generate a 1HZ clock
                clk_out => clk_ext_converted_sig
            );
        else generate
            FPGA_clock_converter : entity work.clock_converter
            port map (
                clrbar => clrbar_sig,
                clk_in_100MHZ => clk_ext,
                clk_out_1HZ => clk_ext_converted_sig,
                clk_out_1KHZ => clk_disp_refresh_1KHZ_sig
            );
        end generate;

    CLOCK_CTRL : entity work.clock_controller 

        port map (
            clk_in => clk_ext_converted_sig,
            prog_run_switch => S2_prog_run_switch,
            step_toggle => S6_step_toggle,
            manual_auto_switch => S7_manual_auto_switch,
            hltbar => hltbar_sig,
            clrbar => clrbar_sig,
            clk_out => clk_sys_sig,
            clkbar_out => clkbar_sys_sig
        );

    
    -- single_pulse_generator : entity work.single_pulse_generator
    --     port map(
    --         clk => clk_out_1HZ,
    --         start => pulse,
    --         pulse_out => clock_pulse
    --     );

    w_bus : entity work.w_bus
        port map(
            sel_default => wbus_sel_sig,
            sel_io => wbus_sel_io_sig, 
            we_sel_default => wbus_output_we_default_sig,
            we_sel_io => wbus_output_we_io_sig,
            io_active => io_active_sig,
            pc_addr_in => pc_data_out_sig,
            stack_pointer_in => sp_data_out_sig,
            IR_operand_in => IR_operand_sig,
            acc_data_in => acc_data_sig,
            alu_data_in => alu_data_sig,
            MDR_fm_data_in => mdr_fm_data_out_sig,
            B_data_in => b_data_sig,
            C_data_in => c_data_sig, 
            tmp_data_in => tmp_data_sig,
            input_port_1_data_in => input_port_1_data_in_sig,
            input_port_2_data_in => input_port_2_data_in_sig,
            bus_out => w_bus_data_out_sig,
            acc_write_enable => write_enable_acc_sig,
            b_write_enable => write_enable_B_sig,
            c_write_enable => write_enable_C_sig,
            tmp_write_enable => write_enable_tmp_sig,
            mar_write_enable => write_enable_mar_sig,
            pc_write_enable => write_enable_PC_sig,
            mdr_tm_write_enable => write_enable_mdr_tm_sig,
            ir_opcode_write_enable => write_enable_ir_opcode_sig,
            ir_operand_low_write_enable => write_enable_low_sig,
            ir_operand_high_write_enable => write_enable_high_sig,
            out_port_3_write_enable => out_port_3_write_enable_sig,
            out_port_4_write_enable => out_port_4_write_enable_sig,
            pc_write_enable_low => pc_write_enable_low_sig,
            pc_write_enable_high => pc_write_enable_high_sig
        );

    PC : entity work.ProgramCounter
        Generic Map(16)
        port map(
            clk => clkbar_sys_sig,
            clr => clr_sig,
            write_enable_full => write_enable_PC_sig,
            write_enable_low => pc_write_enable_low_sig,
            write_enable_high => pc_write_enable_high_sig,
            increment => pc_increment_sig,
            data_in => w_bus_data_out_sig,
            data_out => pc_data_out_sig
        );

    -- MEMORY ADDRESS REGISTER
    MAR : entity work.DataRegister
        Generic Map(16)
        port map(
            clk => clk_sys_sig,
            clr => clr_sig,
            write_enable => write_enable_mar_sig,
            data_in => w_bus_data_out_sig,
            data_out => mar_addr_sig
            );
            
    -- MEMORY DATA_REGISTER - From Ram        
    MDR_FM : entity work.DataRegister
        Generic Map(8)
        port map(
            clk => clk_sys_sig,
            clr => clr_sig,
            -- write enable for both modes
            write_enable => write_enable_mdr_fm_sig,
            -- bus to mem (write) mode ports (write to memory)
            data_in => ram_data_out_sig,
            -- mem to bus (read) mode ports (read from memory)
            data_out => mdr_fm_data_out_sig
        );              

            -- MEMORY DATA_REGISTER - To Ram        
    MDR_TM : entity work.DataRegister
    Generic Map(8)
    port map(
        clk => clk_sys_sig,
        clr => clr_sig,
        -- write enable for both modes
        write_enable => write_enable_mdr_tm_sig,
        -- bus to mem (write) mode ports (write to memory)
        data_in => w_bus_data_out_sig(7 downto 0),
        -- mem to bus (read) mode ports (read from memory)
        data_out => mdr_tm_data_out_sig
    );              

    IR : entity work.DataRegister
        generic map(8)
        port map(
            clk => clk_sys_sig,
            clr => ir_clear_sig,
            write_enable => write_enable_ir_opcode_sig,
            data_in => w_bus_data_out_sig(7 downto 0),
            data_out => IR_opcode_sig        
        );

    IR_Operand : entity work.IR_operand_latch
            port map(
                clk => clk_sys_sig,
                clr => ir_clear_sig,
                ir_operand_in => w_bus_data_out_sig(7 downto 0),
                write_enable_low => write_enable_low_sig,
                write_enable_high => write_enable_high_sig,
                operand_low_out => operand_low_out_sig,
                operand_high_out => operand_high_out_sig
            );

    SP : entity work.StackPointer
            port map(
                clk => clk_sys_sig,
                clr => clr_sig,
                increment => sp_increment_sig,
                decrement => sp_decrement_sig,
                data_out => sp_data_out_sig
            );


    -- input_port_multipler : entity work.input_port_multiplexer
    --     port map(
    --         input_port_select_in => ,
    --         input_port_1 => in_port_1,
    --         input_port_2 => in_port_2,
    --         input_port_out => input_port_data_in_sig);

    ram_bank_input : entity work.memory_input_multiplexer            
         port map(prog_run_select => S2_prog_run_switch,
                 prog_data_in => S3_data_in,
                 run_data_in => mdr_tm_data_out_sig,
                 prog_addr_in => S1_addr_in,
                 run_addr_in => mar_addr_sig,
                 prog_clk_in => memory_access_clk,
                 run_clk_in => clk_sys_sig,
                 prog_write_enable => S4_read_write_switch,
                 run_write_enable => ram_write_enable_sig,
                 select_data_in => ram_data_in_sig,
                 select_addr_in => ram_addr_in_sig,
                 select_clk_in => ram_clk_in_sig,
                 select_write_enable => selected_ram_write_enable_sig
             );

    ram_bank : entity work.ram_bank
        port map(
            clk => ram_clk_in_sig,
            addr => ram_addr_in_sig,
            data_in => ram_data_in_sig,
            write_enable => selected_ram_write_enable_sig,
            data_out => ram_data_out_sig
        );

    proc_controller : entity work.proc_controller
        port map(
            clk => clkbar_sys_sig,
            clrbar => clrbar_sig,
            opcode => IR_opcode_sig,
            minus_flag => minus_flag_sig,
            equal_flag => equal_flag_sig,
            wbus_sel => wbus_sel_sig,
            alu_op => alu_op_sig,
            wbus_output_connected_components_write_enable => wbus_output_we_default_sig,
            pc_increment => pc_increment_sig,
            mdr_fm_write_enable => write_enable_mdr_fm_sig,
            ram_write_enable => ram_write_enable_sig,
            ir_clear => ir_clear_sig,
            update_status_flags => update_status_flags_sig,
            controller_wait => controller_wait_sig,
            stack_pointer_inc => sp_increment_sig,
            stack_pointer_dec => sp_decrement_sig,
            hltbar => hltbar_sig,
            stage_out => stage_counter_sig
        );
        
    acc : entity work.DataRegister 
        Generic Map(8)
        Port Map (
            clk => clk_sys_sig,
            clr => clr_sig,
            write_enable => write_enable_acc_sig,
            data_in => w_bus_data_out_sig(7 downto 0),
            data_out => acc_data_sig
        ); 

    B : entity work.DataRegister 
    Generic Map(8)
    Port Map (
        clk => clk_sys_sig,
        clr => clr_sig,
        write_enable => write_enable_B_sig,
        data_in => w_bus_data_out_sig(7 downto 0),
        data_out => b_data_sig
    );


    C : entity work.DataRegister 
    Generic Map(8)
    Port Map (
        clk => clk_sys_sig,
        clr => clr_sig,
        write_enable => write_enable_C_sig,
        data_in => w_bus_data_out_sig(7 downto 0),
        data_out => c_data_sig
    );


    TMP : entity work.DataRegister 
    Generic Map(8)
    Port Map (
        clk => clk_sys_sig,
        clr => clr_sig,
        write_enable => write_enable_tmp_sig,
        data_in => w_bus_data_out_sig(7 downto 0),
        data_out => tmp_data_sig
    );
        
    ALU : entity work.ALU
        port map (
            clr => clr_sig,
            op => alu_op_sig,
            input_1 => acc_data_sig,
            input_2 => tmp_data_sig,
            alu_out => alu_data_sig,
            update_status_flags => update_status_flags_sig,
            minus_flag => minus_flag_sig,
            equal_flag => equal_flag_sig
            );

    OUTPUT_PORT_3 : entity work.DataRegister
    Generic Map(8)
    port map (
        clk => clk_sys_sig,
        clr => clr_sig,
        write_enable => out_port_3_write_enable_sig,
        data_in => w_bus_data_out_sig(7 downto 0),
        data_out => output_1_sig
    );

    OUTPUT_PORT_4 : entity work.DataRegister
    Generic Map(8)
    port map (
        clk => clk_sys_sig,
        clr => clr_sig,
        write_enable => out_port_4_write_enable_sig,
        data_in => w_bus_data_out_sig(7 downto 0),
        data_out => output_2_sig
    );

    IO : entity work.IO_controller
        Port map(
            clk => clkbar_sys_sig,
            rst => clr_sig,
            opcode => IR_opcode_sig,
            portnum => IR_operand_sig(2 downto 0),
            bus_selector => wbus_sel_io_sig,
            bus_we_select => wbus_output_we_io_sig,
            active => io_active_sig
        );

    REGISTER_LOG : process(clk_sys_sig)
    begin
        Report "Current Simulation Time: " & time'image(now)
            & ", PC: " & to_string(pc_data_out_sig)
            & ", MAR: " & to_string(mar_addr_sig)
            & ", MDR: " & to_string(mdr_data_out_sig)
            & ", OPCODE: " & to_string(IR_opcode_sig)
            & ", ACC: " & to_string(acc_data_sig)
            & ", B: " & to_string(b_data_sig)
            & ", C: " & to_string(c_data_sig);
    end process;

    -- OUTPUT_REG : entity work.output
    --         port map (
    --             clk => clk_sys_sig,
    --             clr => clr_sig,
    --             load_OUT_bar => enable_write_output_sig,
    --             output_in => w_bus_data_out_sig(7 downto 0),
    --             output_out => output_sig
    --         );
        
    -- display_data <= ("00000000" & output_sig) when not running else
    --                 ("0000" & pc_data_sig & IR_opcode_sig & IR_operand_sig) when running;
    -- TODO use a multiplexer so different types of output can be used on the seven segment displays
--    display_data(7 downto 4) <= IR_opcode_sig when running;
--    display_data(3 downto 0) <= IR_operand_sig when running;
--    display_data(11 downto 8) <= pc_data_sig when running;
        
    GENERATING_FPGA_OUTPUT : if SIMULATION_MODE = false
        generate  
            display_controller : entity work.display_controller
            port map(
               clk => clk_disp_refresh_1KHZ_sig,
               rst => clr_sig,
               data_in => display_data,
               anodes_out => s7_anodes_out,
               cathodes_out => s7_cathodes_out
           );
       end generate;                        

end behavior;
    
          