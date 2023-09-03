-- Lucas Ritzdorf
-- 09/02/2023
-- EELE 467, HW 3

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- Debouncer test bench
entity Debouncer_TB is end entity;

architecture Debouncer_TB_Arch of Debouncer_TB is
    signal clk, reset : std_logic;
    signal input, output : std_logic;
begin

    -- Debouncer DUT instance
    dut: entity work.Debouncer
        generic map (DELAY_CYCLES => 10)
        port map (clk,
                  reset,
                  input,
                  output);

    -- TODO: Clock driver

    -- TODO: Test driver

end architecture;
