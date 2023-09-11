-- Lucas Ritzdorf
-- 09/10/2023
-- EELE 467, Lab 4

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- Common LED pattern core interface
entity pattern_core is
    generic (WIDTH : natural);
    port (
        prev_step : in  std_logic_vector(WIDTH-1 downto 0);
        next_step : out std_logic_vector(WIDTH-1 downto 0));
end entity;


-- Individual pattern cores

architecture up_count of pattern_core is
begin
    next_step <= prev_step + 1;
end architecture;

architecture down_count of pattern_core is
begin
    next_step <= prev_step - 1;
end architecture;

architecture left_rotate of pattern_core is
begin
    next_step <= std_logic_vector(unsigned(prev_step) rol 1);
end architecture;

architecture right_rotate of pattern_core is
begin
    next_step <= std_logic_vector(unsigned(prev_step) ror 1);
end architecture;


-- Configurations to select each pattern core

configuration PatternUp of PatternGenerator is
    for PatternGenerator_Arch
        for pattern_step: pattern_core
            use entity work.pattern_core(up_count);
        end for;
    end for;
end configuration;

configuration PatternDown of PatternGenerator is
    for PatternGenerator_Arch
        for pattern_step: pattern_core
            use entity work.pattern_core(down_count);
        end for;
    end for;
end configuration;

configuration PatternLeft of PatternGenerator is
    for PatternGenerator_Arch
        for pattern_step: pattern_core
            use entity work.pattern_core(left_rotate);
        end for;
    end for;
end configuration;

configuration PatternRight of PatternGenerator is
    for PatternGenerator_Arch
        for pattern_step: pattern_core
            use entity work.pattern_core(right_rotate);
        end for;
    end for;
end configuration;


-- And a full replacement architecture for a sequential pattern
architecture PatternKITT of PatternGenerator is
    signal forward : std_logic;
begin
    process(clk)
    begin
        if reset then
            forward <= '0';
            pattern <= preset;
        else
            -- Direction switching
            if pattern(pattern'left) then
                forward <= '1';
            elsif pattern(pattern'right) then
                forward <= '0';
            end if;
            -- Pattern rotation
            if forward then
                pattern <= std_logic_vector(unsigned(pattern) ror 1);
            else
                pattern <= std_logic_vector(unsigned(pattern) rol 1);
            end if;
        end if;
    end process;
end architecture;
