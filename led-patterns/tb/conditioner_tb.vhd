-- Lucas Ritzdorf
-- 09/02/2023
-- EELE 467, HW 3

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- Conditioner test bench
entity Conditioner_TB is end entity;

architecture Conditioner_TB_Arch of Conditioner_TB is
    signal clk, reset : std_logic;
    signal input, output : std_logic;
begin

    -- Conditioner DUT instance
    dut: entity work.Conditioner
        port map (clk,
                  reset,
                  input,
                  output);

    -- TODO: Clock driver

    -- TODO: Test driver

end architecture;
