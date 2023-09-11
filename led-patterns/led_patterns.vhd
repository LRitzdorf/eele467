-- Lucas Ritzdorf
-- 09/09/2023
-- EELE 467, Lab 4

use work.common.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- LED Patterns interface
entity LED_Patterns is
    generic (
        -- Number of system clock cycles per second
        SYS_CLKs_sec    : natural);
    port (
        clk   : in std_logic;
        -- NOTE: Active high reset
        reset : in std_logic;
        -- Active high state-change signal
        PB              : in  std_logic;
        -- Next-state selection switches
        SW              : in  std_logic_vector(3 downto 0);
        -- Asserted when software is in control
        HPS_LED_control : in  std_logic;
        -- Base transition period, in seconds (UQ4.4)
        Base_rate       : in  unsigned(7 downto 0);
        -- LED register
        LED_reg         : in  std_logic_vector(7 downto 0);
        -- LED outputs
        LED             : out std_logic_vector(7 downto 0));
end entity;


architecture LED_Patterns_Arch of LED_Patterns is

    -- Mux-able signal for HW-generated LED pattern
    signal LED_hw : std_logic_vector(7 downto 0);

    -- Pattern generator state machine signals
    signal pattern_clocks : std_logic_vector(5 downto 0);
    type pattern_t is (SWITCH, SHIFT_RIGHT, SHIFT_LEFT, COUNT_UP, COUNT_DOWN, CUSTOM);
    signal current_pattern, last_pattern : pattern_t;

    -- Internal pattern signals
    type pattern_array_t is array(natural range <>) of std_logic_vector(6 downto 0);
    signal patterns : pattern_array_t(5 downto 1);

begin


-- Clock generator instantiation
clockgen: entity work.ClockGenerator
    generic map (
        SYS_CLKs_sec,
        CLK_SCALES(0) => x"10",  -- Heartbeat: 1
        CLK_SCALES(1) => x"08",  -- Shift right: 1/2
        CLK_SCALES(2) => x"04",  -- Shift left: 1/4
        CLK_SCALES(3) => x"20",  -- Count up: 2
        CLK_SCALES(4) => x"02",  -- Count down: 1/8
        CLK_SCALES(5) => x"01")  -- Custom: 1/16
    port map (
        clk,
        reset,
        Base_rate,
        gen_clocks => pattern_clocks);


-- Mux between HPS signals and internal pattern, based on HPS control signal
hps_mux: with HPS_LED_control select
    LED <=
        LED_reg when '1',
        LED_hw when others;

-- Mux between internal patterns, based on internal pattern state
pattern_mux: with current_pattern select
    LED_hw(6 downto 0) <=
        b"000" & SW when SWITCH,
        patterns(1) when SHIFT_RIGHT,
        patterns(2) when SHIFT_LEFT,
        patterns(3) when COUNT_UP,
        patterns(4) when COUNT_DOWN,
        patterns(5) when CUSTOM,
        b"1111111"  when others;


-- Toggle the "heartbeat" LED every second
heartbeat: process(pattern_clocks(0), reset)
begin
    if reset then
        LED_hw(7) <= '0';
    else
        LED_hw(7) <= not LED_hw(7);
    end if;
end process;


-- Pattern state machine
-- NOTE: Uses its own counter system, because the required 1-second window is
-- asynchronous to the 1-second heartbeat
pattern_fsm: process(clk)
    variable ticks : natural;
begin
    if reset then
        current_pattern <= SHIFT_RIGHT;
        ticks := 0;
    elsif PB then
        current_pattern <= SWITCH;
        last_pattern <= current_pattern;
    elsif current_pattern = SWITCH then
        if ticks = (unsigned(Base_rate) * SYS_CLKs_sec) / 2**4 - 1 then
            -- Quartus doesn't like select statements inside of processes, even
            -- though they should be valid in VHDL-2008
            if    SW = x"0" then current_pattern <= SHIFT_RIGHT;
            elsif SW = x"1" then current_pattern <= SHIFT_LEFT;
            elsif SW = x"2" then current_pattern <= COUNT_UP;
            elsif SW = x"3" then current_pattern <= COUNT_DOWN;
            elsif SW = x"4" then current_pattern <= CUSTOM;
            else                 current_pattern <= last_pattern;
            end if;
            ticks := 0;
        else
            ticks := ticks + 1;
        end if;
    end if;
end process;


-- Pattern-generation state machines

-- One LED, shifting right
shift_right_fsm: process(pattern_clocks(1), reset)
    alias pattern_clock is pattern_clocks(1);
    alias pattern is patterns(1);
begin
    if reset then
        pattern <= b"1000000";
    elsif rising_edge(pattern_clock) then
        pattern <= std_logic_vector(unsigned(pattern) ror 1);
    end if;
end process;

-- Two LEDs, shifting left
shift_left_fsm: process(pattern_clocks(2), reset)
    alias pattern_clock is pattern_clocks(2);
    alias pattern is patterns(2);
begin
    if reset then
        pattern <= b"0000011";
    elsif rising_edge(pattern_clock) then
        pattern <= std_logic_vector(unsigned(pattern) rol 1);
    end if;
end process;

-- Binary up-counter
count_up_fsm: process(pattern_clocks(3), reset)
    alias pattern_clock is pattern_clocks(3);
    alias pattern is patterns(3);
begin
    if reset then
        pattern <= b"0000000";
    elsif rising_edge(pattern_clock) then
        pattern <= pattern + 1;
    end if;
end process;

-- Binary down-counter
count_down_fsm: process(pattern_clocks(4), reset)
    alias pattern_clock is pattern_clocks(4);
    alias pattern is patterns(4);
begin
    if reset then
        pattern <= b"1111111";
    elsif rising_edge(pattern_clock) then
        pattern <= pattern - 1;
    end if;
end process;

-- Custom pattern: KITT chaser lights
custom_fsm: process(pattern_clocks(5), reset)
    alias pattern_clock is pattern_clocks(5);
    alias pattern is patterns(5);
    variable full_pattern : std_logic_vector(8 downto 0);
    variable forward : std_logic;
begin
    if reset then
        full_pattern := b"000000011";
        forward := '0';
    elsif rising_edge(pattern_clock) then
        -- Direction switching
        if full_pattern(full_pattern'left) then
            forward := '1';
        elsif full_pattern(full_pattern'right) then
            forward := '0';
        end if;
        -- Pattern rotation
        if forward then
            full_pattern := std_logic_vector(unsigned(full_pattern) ror 1);
        else
            full_pattern := std_logic_vector(unsigned(full_pattern) rol 1);
        end if;
    end if;
    -- Cut off the two outermost bits, to produce a better-looking pattern
    pattern <= full_pattern(7 downto 1);
end process;


end architecture;
