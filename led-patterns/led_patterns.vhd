-- Lucas Ritzdorf
-- 09/09/2023
-- EELE 467, Lab 4

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
    type pattern_t is (SWITCH, SHIFT_RIGHT, SHIFT_LEFT, COUNT_UP, COUNT_DOWN, CUSTOM);
    signal current_pattern, next_pattern : pattern_t;

    -- Internal pattern signals
    type pattern_array_t is array(natural range <>) of std_logic_vector(6 downto 0);
    signal patterns : pattern_array_t(4 downto 0);

begin


-- Mux between HPS signals and internal pattern, based on HPS control signal
hps_mux: with HPS_LED_control select
    LED <=
        LED_reg when '1',
        LED_hw when others;

-- Mux between internal patterns, based on internal pattern state
pattern_mux: with current_pattern select
    LED_hw(6 downto 0) <=
        b"000" & SW when SWITCH,
        patterns(0) when SHIFT_RIGHT,
        patterns(1) when SHIFT_LEFT,
        patterns(2) when COUNT_UP,
        patterns(3) when COUNT_DOWN,
        patterns(4) when CUSTOM,
        b"1111111"  when others;


-- Toggle the "heartbeat" LED every second
heartbeat: process(clk)
    variable ticks : natural;
begin
    if reset then
        LED_hw(7) <= '0';
        ticks := 0;
    elsif ticks = (to_integer(Base_rate) * SYS_CLKs_sec) / 2**4 - 1 then
        LED_hw(7) <= not LED_hw(7);
        ticks := 0;
    else
        ticks := ticks + 1;
    end if;
end process;


-- Pattern state machine
pattern_fsm: process(clk)
    variable ticks : natural;
begin
    if reset then
        current_pattern <= SHIFT_RIGHT;
        ticks := 0;
    elsif PB then
        current_pattern <= SWITCH;
        -- Why the heck can't I use a select statement here, Quartus?
        if    SW = x"1" then next_pattern <= SHIFT_RIGHT;
        elsif SW = x"1" then next_pattern <= SHIFT_LEFT;
        elsif SW = x"2" then next_pattern <= COUNT_UP;
        elsif SW = x"3" then next_pattern <= COUNT_DOWN;
        elsif SW = x"4" then next_pattern <= CUSTOM;
        else                 next_pattern <= current_pattern;
        end if;
    elsif current_pattern = SWITCH then
        if ticks = (to_integer(Base_rate) * SYS_CLKs_sec) / 2**4 - 1 then
            current_pattern <= next_pattern;
            ticks := 0;
        else
            ticks := ticks + 1;
        end if;
    end if;
end process;


-- Pattern-generation state machines

-- One LED, shifting right
shift_right_fsm: process(clk)
    alias pattern is patterns(0);
    variable ticks : natural;
begin
    if reset then
        pattern <= b"1000000";
        ticks := 0;
    elsif ticks = (to_integer(Base_rate) * SYS_CLKs_sec / 2) / 2**4 - 1 then
        pattern <= std_logic_vector(unsigned(pattern) ror 1);
        ticks := 0;
    else
        ticks := ticks + 1;
    end if;
end process;

-- Two LEDs, shifting left
shift_left_fsm: process(clk)
    alias pattern is patterns(1);
    variable ticks : natural;
begin
    if reset then
        pattern <= b"0000011";
        ticks := 0;
    elsif ticks = (to_integer(Base_rate) * SYS_CLKs_sec / 4) / 2**4 - 1 then
        pattern <= std_logic_vector(unsigned(pattern) rol 1);
        ticks := 0;
    else
        ticks := ticks + 1;
    end if;
end process;

-- Binary up-counter
count_up_fsm: process(clk)
    alias pattern is patterns(2);
    variable ticks : natural;
begin
    if reset then
        pattern <= b"0000000";
        ticks := 0;
    elsif ticks = (to_integer(Base_rate) * SYS_CLKs_sec * 2) / 2**4 - 1 then
        pattern <= pattern + 1;
        ticks := 0;
    else
        ticks := ticks + 1;
    end if;
end process;

-- Binary down-counter
count_down_fsm: process(clk)
    alias pattern is patterns(3);
    variable ticks : natural;
begin
    if reset then
        pattern <= b"1111111";
        ticks := 0;
    elsif ticks = (to_integer(Base_rate) * SYS_CLKs_sec / 8) / 2**4 - 1 then
        pattern <= pattern - 1;
        ticks := 0;
    else
        ticks := ticks + 1;
    end if;
end process;

-- Custom pattern: KITT chaser lights
custom_fsm: process(clk)
    alias pattern is patterns(4);
    variable ticks : natural;
    variable full_pattern : std_logic_vector(8 downto 0);
    variable forward : std_logic;
begin
    if reset then
        full_pattern := b"000000011";
        forward := '0';
        ticks := 0;
    elsif ticks = (to_integer(Base_rate) * SYS_CLKs_sec / 8) / 2**4 - 1 then
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
        ticks := 0;
    else
        ticks := ticks + 1;
    end if;
    -- Cut off the two outermost bits, to produce a better-looking pattern
    pattern <= full_pattern(7 downto 1);
end process;


end architecture;
