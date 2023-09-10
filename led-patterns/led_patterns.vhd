-- Lucas Ritzdorf
-- 09/09/2023
-- EELE 467, Lab 4

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- LED Patterns interface
entity LED_Patterns is
    port (clk   : in std_logic;
          -- NOTE: Active high reset
          reset : in std_logic;
          -- Active high state-change signal
          PB              : in  std_logic;
          -- Next-state selection switches
          SW              : in  std_logic_vector(3 downto 0);
          -- Asserted when software is in control
          HPS_LED_control : in  std_logic;
          -- Number of system clock cycles per second
          SYS_CLKs_sec    : in  std_logic_vector(31 downto 0);
          -- Base transition period, in seconds (UQ4.4)
          Base_rate       : in  std_logic_vector(7 downto 0);
          -- LED register
          LED_reg         : in  std_logic_vector(7 downto 0);
          -- LED outputs
          LED             : out std_logic_vector(7 downto 0));
end entity;


architecture LED_Patterns_Arch of LED_Patterns is

    -- Mux-able signal for HW-generated LED pattern
    signal LED_hw : std_logic_vector(7 downto 0);

    -- Pattern generator state machine signals
    type pattern_t is (SHIFT_RIGHT, SHIFT_LEFT, COUNT_UP, COUNT_DOWN, USER);
    signal current_pattern, next_pattern : pattern_t;

begin


-- Mux between HPS signals and internal pattern, based on HPS control signal
hps_mux: with HPS_LED_control select
    LED <=
        LED_reg when '1',
        LED_hw when others;

-- Mux between internal patterns, based on internal pattern state
pattern_mux: with current_pattern select
    LED_hw <=
        x"01" when SHIFT_RIGHT,
        x"02" when SHIFT_LEFT,
        x"03" when COUNT_UP,
        x"04" when COUNT_DOWN,
        x"05" when USER,
        x"00" when others;

end architecture;
