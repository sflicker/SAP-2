library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ring_counter_6bit is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        count : out STD_LOGIC_VECTOR(5 downto 0)
     --   clk_out_1HZ : out STD_LOGIC;
     --   anodes : out STD_LOGIC_VECTOR(3 downto 0);
     --   cathodes : out STD_LOGIC_VECTOR(6 downto 0)
    );
end ring_counter_6bit;

architecture Behavioral of ring_counter_6bit is
--    signal ff_inputs : STD_LOGIC_VECTOR(5 downto 0);
--    signal ff_outputs : STD_LOGIC_VECTOR(5 downto 0);
  --  signal clk_local : STD_LOGIC;
  
--  signal clk_out_1KHZ : STD_LOGIC;
--  signal display_data : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
  
begin

--    clk_local <= clk;

    -- cc : entity work.Clock_converter
    --     Port map(
    --         clk_in_100MHZ => clk,
    --         rst => rst,
    --         clk_out_1HZ => clk_out_1HZ,
    --         clk_out_1KHZ => clk_out_1KHZ
    --         );

--    -- when reset (rst='1')
--    -- the first ff's input is set to 1. the other ff's inputs are set to zero.
--    -- for non reset (rst='0')
--    -- the first ff's input is set to the last ff output.
--    -- the other ff's input is set to the previous ff's output.
--    ff_inputs(0) <= '1' when rst = '1' else ff_outputs(5);
--    ff_inputs(5 downto 1) <= ff_outputs(4 downto 0) when rst = '0' else (others => '0');

--    -- generate the ffs

--    gen_ffs: for i in 0 to 5 generate
--        DFF:
--            entity work.d_flip_flop
--                generic Map (
--                    ID =>  to_string(i)
--                )
--                port Map (
--                    clk => clk_out,
--                    rst => rst,
--                    d => ff_inputs(i),
--                    q => ff_outputs(i),
--                    q_bar => open
--                );
--    end generate gen_ffs;

--   count <= ff_outputs;
--    count <= (others => '1');  
--    count <= (others => '0');

    stage_counter : process(clk, rst) 
        variable stage : integer range 0 to 5 := 0;
        variable single_digit_data : STD_LOGIC_VECTOR(3 downto 0);
        begin
            if rst = '1' then
                Report "Reset - Setting stage to 1";
                stage := 0;
            elsif rising_edge(clk) then
                if stage >= 5 then
                    Report "Rolling stage over back to zero";
                    stage := 0;
                else 
                    Report "Incrementng Stage";
                    stage := stage + 1;
                end if;
            end if;
            count <= (others => '0');
            count(stage) <= '1';
--            single_digit_data := std_logic_vector(to_unsigned(stage+1, single_digit_data'length));
--            display_data(3 downto 0) <= single_digit_data;
        end process;
        
    --   display_controller : entity work.display_controller
    --         port map(
    --             clk => clk_out_1KHZ,
    --             rst => rst,
    --             data_in => display_data,
    --             anodes_out => anodes,
    --             cathodes_out => cathodes
    --         );
                  
        
end behavioral;

