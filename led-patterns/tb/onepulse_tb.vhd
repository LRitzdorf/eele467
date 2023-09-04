-- Lucas Ritzdorf
-- 09/02/2023
-- EELE 467, HW 3

use std.env.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- OnePulse test bench
entity OnePulse_TB is end entity;

architecture OnePulse_TB_Arch of OnePulse_TB is
    constant CLK_PER : time := 100 ns;
    signal clk : std_logic;
    signal input, output : std_logic;
begin

    -- OnePulse DUT instance
    dut: entity work.OnePulse
        port map (clk,
                  input,
                  output);

    -- Clock driver
    clock: process begin
        clk <= '1';
        while true loop
            wait for CLK_PER/2;
            clk <= not clk;
        end loop;
    end process;

    -- Test driver
    tester: process begin
        -- TODO: Test driver body
        wait;

        finish;
    end process;

end architecture;
