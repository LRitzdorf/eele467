-- altera vhdl_input_version vhdl_2008

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
        SYS_CLKs_sec : unsigned
    );
    port (
        clk             : in    std_logic;
        -- NOTE: Active high reset
        reset           : in    std_logic;
        -- Active high state-change signal
        PB              : in    std_logic;
        -- Next-state selection switches
        SW              : in    std_logic_vector(3 downto 0);
        -- Asserted when software is in control
        HPS_LED_control : in    std_logic;
        -- Base transition period, in seconds (UQ4.4)
        Base_rate       : in    unsigned(7 downto 0);
        -- LED register
        LED_reg         : in    std_logic_vector(7 downto 0);
        -- LED outputs
        LED             : out   std_logic_vector(7 downto 0)
    );
end entity;


architecture LED_Patterns_Arch of LED_Patterns is

    -- Mux-able signal for HW-generated LED pattern
    signal LED_hw : std_logic_vector(7 downto 0);

    -- Pattern generator state machine signals
    signal pattern_clocks : std_logic_vector(0 to 5);

    type   pattern_t is (SWITCH, SHIFT_RIGHT, SHIFT_LEFT, COUNT_UP, COUNT_DOWN, CUSTOM);
    signal current_pattern, last_pattern : pattern_t;

    -- Internal pattern signals
    type   pattern_array_t is array(natural range <>) of std_logic_vector(6 downto 0);
    signal patterns : pattern_array_t(1 to 5);

begin


    -- Clock generator instantiation
    clockgen : entity work.ClockGenerator
        generic map (
            SYS_CLKs_sec  => SYS_CLKs_sec,
            CLK_SCALES(0) => x"10",
            CLK_SCALES(1) => x"08",
            CLK_SCALES(2) => x"04",
            CLK_SCALES(3) => x"20",
            CLK_SCALES(4) => x"02",
            CLK_SCALES(5) => x"01"
        )
        port map (
            clk        => clk,
            reset      => reset,
            Base_rate  => Base_rate,
            gen_clocks => pattern_clocks
        );


    -- Mux between HPS signals and internal pattern, based on HPS control signal
    with HPS_LED_control select LED <=
        LED_reg when '1',
        LED_hw when others;

    -- Mux between internal patterns, based on internal pattern state
    with current_pattern select LED_hw(6 downto 0) <=
        b"000" & SW when SWITCH,
        patterns(1) when SHIFT_RIGHT,
        patterns(2) when SHIFT_LEFT,
        patterns(3) when COUNT_UP,
        patterns(4) when COUNT_DOWN,
        patterns(5) when CUSTOM,
        b"1111111"  when others;


    -- Toggle the "heartbeat" LED every second
    heartbeat : process (pattern_clocks(0), reset) is
    begin
        if reset then
            LED_hw(7) <= '0';
        elsif rising_edge(pattern_clocks(0)) then
            LED_hw(7) <= not LED_hw(7);
        end if;
    end process;


    -- Pattern-control state machine
    -- NOTE: Uses its own counter system, because the required 1-second window
    -- is asynchronous to the 1-second heartbeat
    pattern_fsm : process (clk, reset) is
        variable limit : unsigned(
                SYS_CLKs_sec'length
                    + Base_rate'length
                    - 1
                downto 0
            );
        variable ticks : unsigned(
                SYS_CLKs_sec'length
                    + Base_rate'length - 4
                    - 1
                downto 0
            );
    begin
        if reset then
            current_pattern <= SHIFT_RIGHT;
            ticks           := to_unsigned(0, ticks'length);
        elsif rising_edge(clk) then
            if PB then
                current_pattern <= SWITCH;
                if current_pattern /= SWITCH then
                    last_pattern <= current_pattern;
                end if;
                ticks := to_unsigned(0, ticks'length);
            elsif current_pattern = SWITCH then
                limit := unsigned(Base_rate) * SYS_CLKs_sec;
                if ticks >= limit(limit'high downto limit'low + 4) - 1 then
                    -- Quartus doesn't like select statements inside of processes,
                    -- even though they should be valid in VHDL-2008
                    if    SW = x"0" then current_pattern <= SHIFT_RIGHT;
                    elsif SW = x"1" then current_pattern <= SHIFT_LEFT;
                    elsif SW = x"2" then current_pattern <= COUNT_UP;
                    elsif SW = x"3" then current_pattern <= COUNT_DOWN;
                    elsif SW = x"4" then current_pattern <= CUSTOM;
                    else                 current_pattern <= last_pattern;
                    end if;
                else
                    ticks := ticks + 1;
                end if;
            end if;
        end if;
    end process;


    -- Pattern-generation state machines

    -- One LED, shifting right
    shift_right_pattern : configuration work.PatternRight_Conf
        generic map (
            WIDTH => 7
        )
        port map (
            clk     => pattern_clocks(1),
            reset   => reset,
            preset  => b"1000000",
            pattern => patterns(1)
        );

    -- Two LEDs, shifting left
    shift_left_pattern : configuration work.PatternLeft_Conf
        generic map (
            WIDTH => 7
        )
        port map (
            clk     => pattern_clocks(2),
            reset   => reset,
            preset  => b"0000011",
            pattern => patterns(2)
        );

    -- Binary up-counter
    count_up_pattern : configuration work.PatternUp_Conf
        generic map (
            WIDTH => 7
        )
        port map (
            clk     => pattern_clocks(3),
            reset   => reset,
            preset  => b"0000000",
            pattern => patterns(3)
        );

    -- Binary down-counter
    count_down_pattern : configuration work.PatternDown_Conf
        generic map (
            WIDTH => 7
        )
        port map (
            clk     => pattern_clocks(4),
            reset   => reset,
            preset  => b"1111111",
            pattern => patterns(4)
        );

    -- Custom pattern: KITT chaser lights
    kitt_pattern : entity work.PatternGenerator(PatternKITT_Arch)
        generic map (
            WIDTH => 9
        )
        port map (
            clk                 => pattern_clocks(5),
            reset               => reset,
            preset              => b"000000011",
            pattern(7 downto 1) => patterns(5)
        );


end architecture;
