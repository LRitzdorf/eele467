-- Lucas Ritzdorf
-- 09/02/2023
-- EELE 467, HW 3

use std.env.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- Debouncer test bench
entity Debouncer_TB is
end entity;

architecture Debouncer_TB_Arch of Debouncer_TB is
    constant CLK_PER : time := 100 ns;

    signal clk,   reset  : std_logic;
    signal input, output : std_logic;
begin

    -- Debouncer DUT instance
    dut : entity work.Debouncer
        generic map (
            DELAY_CYCLES => 10
        )
        port map (
            clk    => clk,
            reset  => reset,
            input  => input,
            output => output
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
    tester : process is
    begin
        wait until falling_edge(clk);

        reset <= '0';
        input <= '0';
        wait until falling_edge(clk);
        assert output = '0'
            severity error;

        reset <= '1';
        wait until falling_edge(clk);
        assert output = '0'
            severity error;

        input <= '1';
        wait until falling_edge(clk);
        input <= '0';
        -- This momentary HIGH input should result in a sequence of two
        -- debounce cycles: one when the input goes high (and it latched at the
        -- next clock edge), and another immediately afterward, when the first
        -- cycle ends and the now-LOW input is latched again.
        for i in 1 to 10 loop
            assert output = '1'
                severity error;
            wait until falling_edge(clk);
        end loop;
        for i in 1 to 10 loop
            assert output = '0'
                severity error;
            wait until falling_edge(clk);
        end loop;

        -- Ensure that a consistently HIGH input continues to be presented at
        -- output after debouncing completes
        input <= '1';
        wait until falling_edge(clk);
        for i in 1 to 15 loop
            assert output = '1'
                severity error;
            wait until falling_edge(clk);
        end loop;

        finish;
    end process;

end architecture;
