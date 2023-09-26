-- Lucas Ritzdorf
-- 09/02/2023
-- EELE 467, HW 3

use std.env.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.uniform;  -- For random number generation


-- Conditioner test bench
entity Conditioner_TB is
end entity;

architecture Conditioner_TB_Arch of Conditioner_TB is
    constant CLK_PER : time := 100 ns;

    signal clk,   reset  : std_logic;
    signal input, output : std_logic;
begin

    -- Conditioner DUT instance
    dut : entity work.Conditioner
        generic map (
            DEBOUNCE_CYCLES => 10
        )
        port map (
            clk       => clk,
            reset     => reset,
            input(0)  => input,
            output(0) => output
        );

    -- Clock driver
    clock : process is
    begin
        clk <= '1';
        while true loop
            wait for CLK_PER / 2;
            clk <= not clk;
        end loop;
    end process;

    -- Test driver
    -- NOTE: This testbench is NOT automated! This would be rather intensive to
    -- build, and would likely be rather fragile anyway. Instead, it simply
    -- produces a representative set of inputs, and requires that the DUT's
    -- outputs be manually verified.
    tester : process is

        -- Pseudorandom std_logic_vector provider
        -- Sourced from https://vhdlwhiz.com/random-numbers on 09/04/2023
        variable seed1, seed2 : integer := 42;
        impure function rand_slv (len : integer) return std_logic_vector is
            variable r   : real;
            variable slv : std_logic_vector(len - 1 downto 0);
        begin
            for i in slv'range loop
                uniform(seed1, seed2, r);
                slv(i) := '1' when r > 0.5 else '0';
            end loop;
            return slv;
        end function;

        variable bouncy : std_logic_vector(1 to 8);

    begin
        wait until falling_edge(clk);

        -- Initialization: reset system
        reset <= '0';
        input <= '0';
        for i in 1 to 5 loop
            wait until falling_edge(clk);
        end loop;
        reset <= '1';
        wait until falling_edge(clk);

        -- Basic test: input pulse faster than debounce time
        input <= '1';
        wait until falling_edge(clk);
        input <= '0';
        for i in 1 to 25 loop
            wait until falling_edge(clk);
        end loop;

        -- Basic test: input pulse longer than debounce time
        input <= '1';
        wait until falling_edge(clk);
        for i in 1 to 15 loop
            wait until falling_edge(clk);
        end loop;
        input <= '0';

        -- Randomized test series: noisy input pulse within debounce timeframe
        for test_num in 1 to 5 loop
            -- Allow DUT to settle back to idle state
            input <= '0';
            for i in 1 to 15 loop
                wait until falling_edge(clk);
            end loop;

            -- Supply bouncy input for a while
            bouncy := rand_slv(bouncy'length);
            for i in bouncy'range loop
                input <= bouncy(i);
                wait until falling_edge(clk);
            end loop;
            -- Wait for the rest of the test duration
            input <= '1';
            for i in 1 to (15 - bouncy'length) loop
                wait until falling_edge(clk);
            end loop;
        end loop;

        finish;
    end process;

end architecture;
