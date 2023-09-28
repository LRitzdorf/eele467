-- altera vhdl_input_version vhdl_2008

-- Lucas Ritzdorf
-- 09/10/2023
-- EELE 467, Lab 4

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- Pattern generator interface
entity PatternGenerator is
    generic (
        WIDTH : natural
    );
    port (
        -- Pattern clock (likely slower than surrounding system)
        clk     : in    std_logic;
        -- NOTE: Active high reset
        reset   : in    std_logic;
        -- Initial bit pattern
        preset  : in    std_logic_vector(WIDTH - 1 downto 0);
        -- Generated pattern output
        pattern : out   std_logic_vector(WIDTH - 1 downto 0)
    );
end entity;


-- Pattern generator architecture
architecture PatternGenerator_Arch of PatternGenerator is

    component pattern_core is
        generic (
            WIDTH : natural
        );
        port (
            prev_step : in    std_logic_vector(WIDTH - 1 downto 0);
            next_step : out   std_logic_vector(WIDTH - 1 downto 0)
        );
    end component;

    signal prev_step, next_step : std_logic_vector(WIDTH - 1 downto 0);

begin

    -- Configurable pattern generator
    pattern_step : component pattern_core
        generic map (
            WIDTH
        )
        port map (
            prev_step,
            next_step
        );

    -- Pattern latch
    pattern_fsm : process (clk, reset) is
    begin
        if reset then
            prev_step <= preset;
        elsif rising_edge(clk) then
            prev_step <= next_step;
        end if;
    end process;
    pattern <= prev_step;

end architecture;
