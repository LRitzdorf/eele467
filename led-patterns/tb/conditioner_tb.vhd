-- Lucas Ritzdorf
-- 09/02/2023
-- EELE 467, HW 3

use std.env.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- Conditioner test bench
entity Conditioner_TB is end entity;

architecture Conditioner_TB_Arch of Conditioner_TB is
    constant CLK_PER : time := 100 ns;
    signal clk, reset : std_logic;
    signal input, output : std_logic;
begin

    -- Conditioner DUT instance
    dut: entity work.Conditioner
        port map (clk,
                  reset,
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
