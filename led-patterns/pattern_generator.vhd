-- Lucas Ritzdorf
-- 09/10/2023
-- EELE 467, Lab 4

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- Pattern generator interface
entity PatternGenerator is
    generic (WIDTH : natural);
    port (
        -- Pattern clock (likely slower than surrounding system)
        clk     : in  std_logic;
        -- NOTE: Active high reset
        reset   : in  std_logic;
        -- Initial bit pattern
        preset  : in  std_logic_vector(WIDTH-1 downto 0);
        -- Generated pattern output
        pattern : out std_logic_vector(WIDTH-1 downto 0));
end entity;


architecture PatternGenerator_Arch of PatternGenerator is

    component pattern_core is
        generic (WIDTH : natural);
        port (
            prev_step : in  std_logic_vector(WIDTH-1 downto 0);
            next_step : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    signal last_pattern, next_pattern : std_logic_vector(WIDTH-1 downto 0);

begin

    -- Configurable pattern generator
    pattern_step: pattern_core
        generic map(WIDTH)
        port map(
            prev_step => last_pattern,
            next_step => next_pattern);

    -- Pattern latch
    pattern_fsm: process(clk, reset)
    begin
        if reset then
            last_pattern <= preset;
        elsif rising_edge(clk) then
            last_pattern <= next_pattern;
        end if;
    end process;
    pattern <= last_pattern;

end architecture;
