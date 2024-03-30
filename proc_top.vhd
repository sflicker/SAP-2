library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity proc_top is
    generic (
        SIMULATION_MODE : boolean := false
    );
    port( clk_ext : in STD_LOGIC;  -- map to FPGA clock will be stepped down to 1HZ
                                -- for simulation TB should generate clk of 1HZ
          addr_in : STD_LOGIC_VECTOR(3 downto 0);       -- address setting - S1 in ref
          S2 : STD_LOGIC;       -- prog / run switch
          data_in : STD_LOGIC_VECTOR(7 downto 0);       -- data setting      S3 in ref
          S4 : STD_LOGIC;       -- read/write toggle   -- 1 to write values to ram. 0 to read. needs to be 0 for run mode
          S5_clear_start : STD_LOGIC;       -- start/clear (reset)  -- 
          S6_step : STD_LOGIC;       -- single step -- 1 for a single step
          S7_auto : STD_LOGIC;       -- manual/auto mode - 0 for manual, 1 for auto. 
          running : out STD_LOGIC;
          s7_anodes_out : out STD_LOGIC_VECTOR(3 downto 0);      -- maps to seven segment display
          s7_cathodes_out : out STD_LOGIC_VECTOR(6 downto 0);     -- maps to seven segment display
          phase_out : out STD_LOGIC_VECTOR(5 downto 0);
          clear_out : out STD_LOGIC;
          step_out : out STD_LOGIC
        );
        attribute MARK_DEBUG : string;
        attribute MARK_DEBUG of S5_clear_start : signal is "true";
        attribute MARK_DEBUG of S6_step : signal is "true";
        attribute MARK_DEBUG of S7_auto : signal is "true";
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
    signal wbus_sel_sig : STD_LOGIC_VECTOR(2 downto 0);       
    signal Cp_sig : STD_LOGIC;
    signal LMBar_sig : STD_LOGIC;
    signal LIBAR_sig : STD_LOGIC;
    signal LABAR_sig : std_logic;
    signal Su_sig : std_logic;
    signal LBBar_sig : std_logic;
    signal LOBar_sig : std_logic;
    signal pc_data_sig : STD_LOGIC_VECTOR(3 downto 0);
    signal acc_data_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal alu_data_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal IR_operand_sig : STD_LOGIC_VECTOR(3 downto 0);
    signal IR_opcode_sig : STD_LOGIC_VECTOR(3 downto 0);
    signal RAM_data_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal w_bus_data_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal mar_addr_sig: STD_LOGIC_VECTOR(3 downto 0);
    signal ram_data_in_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal b_data_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal display_data : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal stage_counter_sig : INTEGER;
    signal output_sig : STD_LOGIC_VECTOR(7 downto 0);
    
    attribute MARK_DEBUG of clk_ext_converted_sig : signal is "true";
    attribute MARK_DEBUG of clk_sys_sig : signal is "true";
    attribute MARK_DEBUG of clkbar_sys_sig : signal is "true";
    
    attribute MARK_DEBUG of hltbar_sig : signal is "true";
    attribute MARK_DEBUG of clrbar_sig : signal is "true";
    attribute MARK_DEBUG of clr_sig : signal is "true";
    attribute MARK_DEBUG of Su_sig : signal is "true";
    attribute MARK_DEBUG of pc_data_sig : signal is "true";
    attribute MARK_DEBUG of mar_addr_sig : signal is "true";
    attribute MARK_DEBUG of IR_opcode_sig : signal is "true";
    attribute MARK_DEBUG of IR_operand_sig : signal is "true";
    attribute MARK_DEBUG of acc_data_sig : signal is "true";
    attribute MARK_DEBUG of b_data_sig : signal is "true";
    attribute MARK_DEBUG of output_sig : signal is "true";

    
    

begin

    clr_sig <= '1' when S5_clear_start = '1' else '0';
    clrbar_sig <= not clr_sig;
    running <= S7_auto and hltbar_sig;
    clear_out <= S5_clear_start;
    step_out <= S6_step; 
     
    phase_out <= std_logic_vector(shift_left(unsigned'("000001"), stage_counter_sig - 1));
    
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
            step => S6_step,
            auto => S7_auto,
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
            sel => wbus_sel_sig,
            pc_data_in => pc_data_sig,
            acc_data_in => acc_data_sig,
            alu_data_in => alu_data_sig,
            IR_data_in => IR_operand_sig,
            RAM_data_in => ram_data_out_sig,
            data_out => w_bus_data_sig
        );

    PC : entity work.PC
        port map(
            clkbar => clkbar_sys_sig,
            clrbar => clrbar_sig,
            Cp => Cp_sig,
            pc_out => pc_data_sig
            );

    MAR : entity work.MAR
        port map(
            clk => clk_sys_sig,
            clr => clr_sig,
            LMBar => LMBar_sig,
            mar_in => w_bus_data_sig(3 downto 0),
            mar_out => mar_addr_sig
            );
            
    IR : entity work.IR
        port map(
            clk => clk_sys_sig,
            clr => clr_sig,
            LIBar => LIBar_sig,
            ir_in => w_bus_data_sig,
            opcode_out=> IR_opcode_sig,
            operand_out => IR_operand_sig
        
        );

    ram_bank : entity work.ram_bank
        port map(
            clk => clk_sys_sig,
            addr => mar_addr_sig,
            ram_data_in => ram_data_in_sig,
            LBar => LBBar_sig,
            ram_data_out => ram_data_out_sig
        );

    proc_controller : entity work.proc_controller
        port map(
            clk => clkbar_sys_sig,
            clrbar => clrbar_sig,
            opcode => IR_opcode_sig,
            wbus_sel => wbus_sel_sig,
            Cp => Cp_sig,
            LMBar => LMBar_sig,
            LIBar => LIBar_sig,
            LABar => LABar_sig,
            Su => Su_sig,
            LBBar => LBBar_sig,
            LOBar => LOBar_sig,
            hltbar => hltbar_sig,
            stage_out => stage_counter_sig
        );
        
      acc: entity work.accumulator
        Port map(
            clk => clk_sys_sig,
            LABar => LABar_sig,
            acc_in => w_bus_data_sig,
            acc_out => acc_data_sig
            ); 
        
      B : entity work.B
        port map (
            clk => clk_sys_sig,
            LBBar => LBBar_sig,
            b_in => w_bus_data_sig,
            b_out => b_data_sig
        );
        
      ALU : entity work.ALU
        port map (
            Su => Su_sig,
            a => acc_data_sig,
            b => b_data_sig,
            alu_out => alu_data_sig
            );

    OUTPUT_REG : entity work.output
            port map (
                clk => clk_sys_sig,
                clr => clr_sig,
                LOBar => LOBar_sig,
                output_in => w_bus_data_sig,
                output_out => output_sig
            );
        
    display_data <= ("00000000" & output_sig) when not running else
                    ("0000" & pc_data_sig & IR_opcode_sig & IR_operand_sig) when running;
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
    
          