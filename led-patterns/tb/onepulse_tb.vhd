-- Lucas Ritzdorf
-- 09/02/2023
-- EELE 467, HW 3

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- OnePulse test bench
entity OnePulse_TB is end entity;

architecture OnePulse_TB_Arch of OnePulse_TB is
    signal clk, reset : std_logic;
    signal input, output : std_logic;
begin

    -- OnePulse DUT instance
    dut: entity work.OnePulse
        port map (clk,
                  input,
                  output);

    -- TODO: Clock driver

    -- TODO: Test driver

end architecture;
