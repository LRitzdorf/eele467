-- Lucas Ritzdorf
-- 09/02/2023
-- EELE 467, HW 3

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- OnePulse interface
entity OnePulse is
    port (
        clk    : in    std_logic;
        input  : in    std_logic;
        output : out   std_logic
    );
end entity;


-- Basic synchronous edge detector
architecture OnePulse_Arch of OnePulse is
    signal last_input : std_logic;
begin
    pulse : process (clk) is
    begin
        if rising_edge(clk) then
            if input and not last_input then
                output <= '1';
            else
                output <= '0';
            end if;
            last_input <= input;
        end if;
    end process;
end architecture;
