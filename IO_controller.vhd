library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity IO_controller is
    Port(
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        opcode : IN STD_LOGIC_VECTOR(7 downto 0);
        portnum : IN STD_LOGIC_VECTOR(2 downto 0);      -- portnum (0 none, 1 input 1, 2 input 2, 3 output 1, 4 output 2)
        bus_selector : OUT STD_LOGIC_VECTOR(3 downto 0);
        bus_we_select : OUT STD_LOGIC_VECTOR(0 to 13);
        active : OUT STD_LOGIC
        
    );
end IO_controller;

architecture behavioral of IO_controller is
    constant IN_byte_OPCODE : STD_LOGIC_VECTOR(7 downto 0) := x"DB";
    constant OUT_byte_OPCODE : STD_LOGIC_VECTOR(7 downto 0) := x"D3";
    type State_Type is (IDLE, EXECUTE, COOL);
    signal state, next_state : State_Type;
begin
    process(clk, rst)
    begin
        if rst = '1' then
            Report "Resetting";
--            bus_selector <= (others => '0');
--            bus_we_select <= (others => '0');
--            output1_write_enable <= '0';
--            output2_write_enable <= '0';
  --          select_input_out <= (others => '0');
  --          output1 <= (others => '0');
  --          output2 <= (others => '0');
          --  active <= '0';
            state <= IDLE;

        elsif rising_edge(clk) then
            Report "Setting State to " & to_string(next_state);
            state <= next_state;
        end if;            
    end process;
            
    process(state, opcode, portnum)
    begin
        Report "Processing - state: " & to_string(state) & 
            ", opcode: " & to_string(opcode) & ", portnum: " & to_string(portnum);
        next_state <= state;  -- default next state to current
        case state is
            when IDLE =>
                if (opcode = IN_byte_OPCODE and (portnum = "001" or portnum = "010"))
                                or (opcode = OUT_byte_OPCODE and (portnum = "011" or portnum = "100")) then
                    Report "IO Opcode detected activating";
                    next_state <= EXECUTE;
                end if;
            
            when EXECUTE =>
                if opcode = IN_BYTE_OPCODE then
                    if portnum = "001" then
                        active <= '1';
                        bus_selector <= "1001";
                        bus_we_select <= "10000000000000";
                    elsif portnum = "010" then
                        active <= '1';
                        bus_selector <= "1010";
                        bus_we_select <= "10000000000000";
                    end if;
                elsif opcode = OUT_BYTE_OPCODE then
                    if portnum = "011" then
                        active <= '1';
                        bus_selector <= "0101";
                        bus_we_select <= "00000000001000";
                    elsif portnum = "100" then
                        active <= '1';
                        bus_selector <= "0101";
                        bus_we_select <= "00000000000100";
                    end if;
                end if;
                next_state <= COOL;

            when COOL =>
                -- cool down for a state while main controller resumes control
                next_state <= IDLE;
                active <= '0';
            when others =>
                next_state <= IDLE;
                active <= '0';
        end case;
    end process;

end behavioral;
