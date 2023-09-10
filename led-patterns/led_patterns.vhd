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
begin

    -- TODO: Replace with actual logic
    LED <= b"01010101";

end architecture;
