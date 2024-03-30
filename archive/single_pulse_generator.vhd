library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity single_pulse_generator is
    Port (
        clk : in std_logic;
        start : in std_logic;
        pulse_out : out std_logic
    );
end single_pulse_generator;

architecture behavioral of single_pulse_generator is
    type state_type is (IDLE_STATE, PULSE_STATE, WAIT_STATE);
    signal current_state, next_state : state_type := IDLE_STATE;
begin
    -- state transition process
    process(clk)
    begin
        if rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- next state logic
    process(current_state, start)
    begin
        case current_state is
            when IDLE_STATE =>
                if start = '1' then
                    next_state <= PULSE_STATE;
                else 
                    next_state <= IDLE_STATE;
                end if;
            when PULSE_STATE =>
                if start = '0' then -- wait for start to be released
                    next_state <= IDLE_STATE;
                else
                    next_state <= WAIT_STATE;
                end if;
            when others =>
                next_state <= IDLE_STATE;
        end case;
    end process;

    -- output logic
    process(current_state)
    begin
        case current_state is
            when PULSE_STATE =>
                pulse_out <= '1';
            when others =>
                pulse_out <= '0';
        end case;
    end process;
end behavioral;